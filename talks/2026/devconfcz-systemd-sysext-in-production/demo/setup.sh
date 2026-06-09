#!/bin/bash
# ABOUTME: Starts the full coreos-demo cluster: file server, control plane, all workers.
# ABOUTME: Leaves the cluster ready for the manual sysext upgrade demo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

# --- Prerequisites ---
for cmd in qemu-system-x86_64 qemu-img butane curl python3; do
  command -v "$cmd" &>/dev/null || { echo "ERROR: $cmd not found"; exit 1; }
done
[ -f "${SSH_KEY_PATH}" ]     || { echo "ERROR: SSH key not found: ${SSH_KEY_PATH}"; exit 1; }
[ -f "${SSH_KEY_PATH}.pub" ] || { echo "ERROR: SSH pubkey not found: ${SSH_KEY_PATH}.pub"; exit 1; }
sudo virsh net-info default &>/dev/null || { echo "ERROR: libvirt default network not running (sudo virsh net-start default)"; exit 1; }

# Sysext cache must be populated before starting (run ./cache-sysexts.sh once)
for f in \
  "${SYSEXT_CACHE_DIR}/flatcar/kubernetes-v1.33.2-x86-64.raw" \
  "${SYSEXT_CACHE_DIR}/flatcar/kubernetes-v1.33.10-x86-64.raw" \
  "${SYSEXT_CACHE_DIR}/flatcar/kubernetes-v1.33.12-x86-64.raw" \
  "${SYSEXT_CACHE_DIR}/fedora/kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw" \
  "${SYSEXT_CACHE_DIR}/fedora/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw"; do
  [ -f "$f" ] || { echo "ERROR: Missing cache file: $f"; echo "Run ./cache-sysexts.sh first."; exit 1; }
done

SSH_PUBKEY="$(cat "${SSH_KEY_PATH}.pub")"

mkdir -p "${IMAGES_DIR}" "${IGN_DIR}" "${PID_DIR}" "${LOG_DIR}"

# --- Start local sysext file server ---
# Serves cached sysext files on virbr0 so VMs never need internet access.
echo "==> Starting local sysext file server on ${FILESERVER_IP}:${FILESERVER_PORT}..."
setsid python3 -m http.server "${FILESERVER_PORT}" \
  --bind "${FILESERVER_IP}" \
  --directory "${SYSEXT_CACHE_DIR}" \
  > "${LOG_DIR}/fileserver.log" 2>&1 &
FILESERVER_PID=$!
echo "${FILESERVER_PID}" > "${PID_DIR}/fileserver.pid"
sleep 1
if ! kill -0 "${FILESERVER_PID}" 2>/dev/null; then
  echo "ERROR: File server failed to start. Check ${LOG_DIR}/fileserver.log"
  exit 1
fi
echo "    File server PID ${FILESERVER_PID} — serving ${SYSEXT_CACHE_DIR}"

# --- Download Flatcar QEMU base image ---
FLATCAR_BASE="${IMAGES_DIR}/flatcar_production_qemu_image.img"
if [ ! -f "${FLATCAR_BASE}" ]; then
  echo "==> Downloading Flatcar stable QEMU image..."
  FLATCAR_BZ2="${FLATCAR_BASE}.bz2"
  curl -L --progress-bar \
    -o "${FLATCAR_BZ2}" \
    "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2"
  echo "==> Decompressing Flatcar image (this may take a minute)..."
  bunzip2 "${FLATCAR_BZ2}"
else
  echo "==> Flatcar base image already present: ${FLATCAR_BASE}"
fi

# --- Download Fedora CoreOS QEMU base image ---
FCOS_BASE="${IMAGES_DIR}/fcos-base.qcow2"
if [ ! -f "${FCOS_BASE}" ]; then
  echo "==> Fetching Fedora CoreOS stable QEMU image URL..."
  FCOS_URL=$(curl -fsSL https://builds.coreos.fedoraproject.org/streams/stable.json | \
    python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d['architectures']['x86_64']['artifacts']['qemu']['formats']['qcow2.xz']['disk']['location'])
")
  FCOS_XZ="${IMAGES_DIR}/$(basename "${FCOS_URL}")"
  echo "==> Downloading FCoOS: $(basename "${FCOS_URL}")"
  curl -L --progress-bar -o "${FCOS_XZ}" "${FCOS_URL}"
  echo "==> Decompressing FCoOS image..."
  xz -d "${FCOS_XZ}"
  mv "${FCOS_XZ%.xz}" "${FCOS_BASE}"
else
  echo "==> FCoOS base image already present: ${FCOS_BASE}"
fi

# --- Host firewall: allow virbr0 forwarding ---
# Docker sets FORWARD policy DROP; add explicit rules so VMs can reach the internet.
# These are temporary (lost on reboot).
WAN_IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
if [ -n "${WAN_IFACE}" ]; then
  sudo iptables -C FORWARD -i virbr0 -o "${WAN_IFACE}" -j ACCEPT 2>/dev/null || \
    sudo iptables -I FORWARD -i virbr0 -o "${WAN_IFACE}" -j ACCEPT
  sudo iptables -C FORWARD -i "${WAN_IFACE}" -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    sudo iptables -I FORWARD -i "${WAN_IFACE}" -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
fi

# --- TAP device for control plane ---
echo "==> Setting up TAP device for control plane..."
sudo ip tuntap add tap-flatcar-cp mode tap 2>/dev/null || true
sudo ip link set tap-flatcar-cp master virbr0
sudo ip link set tap-flatcar-cp up

# --- Generate control plane Ignition ---
echo "==> Generating control plane Ignition..."
sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|CP_IP|${CP_IP}|g" \
  -e "s|GATEWAY|${GATEWAY}|g" \
  -e "s|FILESERVER|${FILESERVER_IP}:${FILESERVER_PORT}|g" \
  "${SCRIPT_DIR}/control-plane.bu" \
  | butane --strict > "${IGN_DIR}/flatcar-cp.ign"

# --- Create CP disk overlay (always fresh) ---
echo "==> Creating control plane disk overlay..."
rm -f "${IMAGES_DIR}/flatcar-cp.qcow2"
qemu-img create -F qcow2 -b "${FLATCAR_BASE}" -f qcow2 "${IMAGES_DIR}/flatcar-cp.qcow2"

# --- Start control plane VM ---
echo "==> Starting control plane VM (flatcar-cp at ${CP_IP})..."
sudo qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -drive if=virtio,file="${IMAGES_DIR}/flatcar-cp.qcow2",format=qcow2 \
  -netdev tap,id=net0,ifname=tap-flatcar-cp,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:10 \
  -fw_cfg name=opt/org.flatcar-linux/config,file="${IGN_DIR}/flatcar-cp.ign" \
  -display none \
  -serial file:"${LOG_DIR}/flatcar-cp.log" \
  -pidfile "${PID_DIR}/flatcar-cp.pid" \
  -daemonize

echo "    Control plane booting — kubeadm init takes ~3 minutes."
echo ""

# --- Wait for control plane SSH ---
echo "==> Waiting for control plane SSH at ${CP_IP}..."
for i in $(seq 1 120); do
  if ssh ${SSH_OPTS} -o ConnectTimeout=3 "${ADMIN}@${CP_IP}" true 2>/dev/null; then
    echo "    Control plane is reachable!"
    break
  fi
  [ "$i" -eq 120 ] && { echo "ERROR: CP SSH not available after 2 minutes"; exit 1; }
  sleep 2
done

# --- Wait for kubeadm init ---
echo "==> Waiting for kubeadm init to complete (up to 15 minutes)..."
for i in $(seq 1 900); do
  if ssh ${SSH_OPTS} -o ConnectTimeout=5 "${ADMIN}@${CP_IP}" \
      'test -f /home/core/.kube/config' 2>/dev/null; then
    echo "    kubeadm init complete!"
    break
  fi
  [ "$i" -eq 900 ] && { echo "ERROR: kubeadm init did not complete"; exit 1; }
  sleep 1
done

# --- Install Calico CNI ---
echo "==> Installing Calico CNI..."
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
  'kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml'
# Detect by CIDR so this works on both Flatcar (eth0) and FCoOS (ens3) nodes.
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
  'kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=cidr=192.168.122.0/24'

# --- Extract kubeadm join info ---
echo "==> Extracting kubeadm join information..."
JOIN_COMMAND=$(ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
  'kubeadm token create --print-join-command')
JOIN_TOKEN=$(echo "${JOIN_COMMAND}" | grep -oP '(?<=--token )\S+')
CA_HASH=$(echo "${JOIN_COMMAND}" | grep -oP '(?<=--discovery-token-ca-cert-hash )\S+')

cat > "${JOIN_INFO}" <<EOF
# Generated by setup.sh
CP_INTERNAL_IP=${CP_IP}
JOIN_TOKEN=${JOIN_TOKEN}
CA_HASH=${CA_HASH}
EOF
echo "    Join info saved to: ${JOIN_INFO}"

# --- Deploy Headlamp dashboard (early — runs on CP, no workers needed) ---
echo "==> Deploying Headlamp dashboard (NodePort 30080 on control plane)..."
scp ${SSH_OPTS} "${SCRIPT_DIR}/headlamp.yaml" "${ADMIN}@${CP_IP}:/tmp/headlamp.yaml"
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
  'kubectl apply -f /tmp/headlamp.yaml && rm /tmp/headlamp.yaml'

# --- worker-1 (Flatcar) ---
echo "==> Setting up TAP device for worker-1..."
sudo ip tuntap add tap-w1 mode tap 2>/dev/null || true
sudo ip link set tap-w1 master virbr0
sudo ip link set tap-w1 up

echo "==> Generating worker-1 Ignition..."
sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|W1_HOSTNAME|${W1_HOSTNAME}|g" \
  -e "s|W1_IP|${W1_IP}|g" \
  -e "s|GATEWAY|${GATEWAY}|g" \
  -e "s|FILESERVER|${FILESERVER_IP}:${FILESERVER_PORT}|g" \
  -e "s|CP_IP|${CP_IP}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|CA_HASH|${CA_HASH}|g" \
  "${SCRIPT_DIR}/worker-1.bu" \
  | butane --strict > "${IGN_DIR}/worker-1.ign"

echo "==> Creating fresh worker-1 disk overlay..."
FLATCAR_BASE="${IMAGES_DIR}/flatcar_production_qemu_image.img"
rm -f "${IMAGES_DIR}/worker-1.qcow2"
qemu-img create -F qcow2 -b "${FLATCAR_BASE}" -f qcow2 "${IMAGES_DIR}/worker-1.qcow2"

echo "==> Starting worker-1 VM (${W1_HOSTNAME} at ${W1_IP})..."
sudo qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -drive if=virtio,file="${IMAGES_DIR}/worker-1.qcow2",format=qcow2 \
  -netdev tap,id=net0,ifname=tap-w1,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:11 \
  -fw_cfg name=opt/org.flatcar-linux/config,file="${IGN_DIR}/worker-1.ign" \
  -display none \
  -serial file:"${LOG_DIR}/worker-1.log" \
  -pidfile "${PID_DIR}/worker-1.pid" \
  -daemonize

# --- worker-2 (FCoOS, Flatcar bakery sysext) ---
echo "==> Setting up TAP device for worker-2..."
sudo ip tuntap add tap-w2 mode tap 2>/dev/null || true
sudo ip link set tap-w2 master virbr0
sudo ip link set tap-w2 up

echo "==> Generating worker-2 Ignition..."
sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|W2_IP|${W2_IP}|g" \
  -e "s|GATEWAY|${GATEWAY}|g" \
  -e "s|FILESERVER|${FILESERVER_IP}:${FILESERVER_PORT}|g" \
  -e "s|CP_IP|${CP_IP}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|CA_HASH|${CA_HASH}|g" \
  "${SCRIPT_DIR}/worker-2.bu" \
  | butane --strict > "${IGN_DIR}/worker-2.ign"

echo "==> Creating fresh worker-2 disk overlay..."
rm -f "${IMAGES_DIR}/worker-2.qcow2"
qemu-img create -F qcow2 -b "${IMAGES_DIR}/fcos-base.qcow2" -f qcow2 "${IMAGES_DIR}/worker-2.qcow2"

echo "==> Starting worker-2 VM (${W2_HOSTNAME} at ${W2_IP})..."
sudo qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -drive if=virtio,file="${IMAGES_DIR}/worker-2.qcow2",format=qcow2 \
  -netdev tap,id=net0,ifname=tap-w2,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:12 \
  -fw_cfg name=opt/com.coreos/config,file="${IGN_DIR}/worker-2.ign" \
  -display none \
  -serial file:"${LOG_DIR}/worker-2.log" \
  -pidfile "${PID_DIR}/worker-2.pid" \
  -daemonize

# --- worker-3 (FCoOS, fedora-sysexts kubernetes-1.33) ---
echo "==> Setting up TAP device for worker-3..."
sudo ip tuntap add tap-w3 mode tap 2>/dev/null || true
sudo ip link set tap-w3 master virbr0
sudo ip link set tap-w3 up

echo "==> Generating worker-3 Ignition..."
sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|W3_IP|${W3_IP}|g" \
  -e "s|GATEWAY|${GATEWAY}|g" \
  -e "s|FILESERVER|${FILESERVER_IP}:${FILESERVER_PORT}|g" \
  -e "s|CP_IP|${CP_IP}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|CA_HASH|${CA_HASH}|g" \
  "${SCRIPT_DIR}/worker-3.bu" \
  | butane --strict > "${IGN_DIR}/worker-3.ign"

echo "==> Creating fresh worker-3 disk overlay..."
rm -f "${IMAGES_DIR}/worker-3.qcow2"
qemu-img create -F qcow2 -b "${IMAGES_DIR}/fcos-base.qcow2" -f qcow2 "${IMAGES_DIR}/worker-3.qcow2"

echo "==> Starting worker-3 VM (${W3_HOSTNAME} at ${W3_IP})..."
sudo qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -drive if=virtio,file="${IMAGES_DIR}/worker-3.qcow2",format=qcow2 \
  -netdev tap,id=net0,ifname=tap-w3,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:13 \
  -fw_cfg name=opt/com.coreos/config,file="${IGN_DIR}/worker-3.ign" \
  -display none \
  -serial file:"${LOG_DIR}/worker-3.log" \
  -pidfile "${PID_DIR}/worker-3.pid" \
  -daemonize

# --- Wait for all workers ---
echo ""
echo "==> Waiting for all workers to join (up to 5 minutes)..."
for i in $(seq 1 300); do
  NODE_COUNT=$(ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
    'kubectl get nodes --no-headers 2>/dev/null | wc -l' 2>/dev/null || echo "0")
  if [ "${NODE_COUNT}" -ge 4 ]; then
    echo "    All 4 nodes visible!"
    break
  fi
  [ "$i" -eq 300 ] && echo "WARNING: Not all nodes joined after 5 minutes. Check status.sh."
  sleep 1
done

echo ""
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" 'kubectl get nodes -o wide' 2>/dev/null || true

# --- Wait for Headlamp rollout (started earlier, should be ready by now) ---
echo ""
echo "==> Waiting for Headlamp rollout to complete..."
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
  'kubectl rollout status deployment/headlamp -n headlamp --timeout=180s' || true

HEADLAMP_TOKEN=$(ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" \
  'kubectl create token headlamp -n headlamp --duration=24h')
echo "${HEADLAMP_TOKEN}" > "${TOKEN_FILE}"

echo ""
echo "==> Deploying demo workload (nginx x3 with topology spread)..."
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" "kubectl apply -f -" < "${SCRIPT_DIR}/demo-workload.yaml"

echo ""
echo "==> Setup complete!"
echo "    Worker sysext logs: ${LOG_DIR}/worker-{1,2,3}.log"
echo "    (FCoOS sysext download can take a few extra minutes)"
echo ""
echo "==> Headlamp is ready!"
echo "    URL:   http://${CP_IP}:30080"
echo "    Token: ${HEADLAMP_TOKEN}"
echo "    Token also saved to: ${TOKEN_FILE}"

