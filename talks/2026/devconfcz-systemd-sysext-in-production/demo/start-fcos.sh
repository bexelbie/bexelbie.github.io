#!/bin/bash
# ABOUTME: Boots just the FCoOS VM for exploration — no cluster needed.
# ABOUTME: The sysext load service runs normally; kubeadm-join will fail (no CP), which is fine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

for cmd in qemu-system-x86_64 qemu-img butane curl python3 xz; do
  command -v "$cmd" &>/dev/null || { echo "ERROR: $cmd not found"; exit 1; }
done
[ -f "${SSH_KEY_PATH}.pub" ] || { echo "ERROR: SSH pubkey not found: ${SSH_KEY_PATH}.pub"; exit 1; }

SSH_PUBKEY="$(cat "${SSH_KEY_PATH}.pub")"

mkdir -p "${IMAGES_DIR}" "${IGN_DIR}" "${PID_DIR}" "${LOG_DIR}"

# --- Download FCoOS base image if needed ---
FCOS_BASE="${IMAGES_DIR}/fcos-base.qcow2"
if [ ! -f "${FCOS_BASE}" ]; then
  echo "==> Fetching FCoOS stable QEMU image URL..."
  FCOS_URL=$(curl -fsSL https://builds.coreos.fedoraproject.org/streams/stable.json | \
    python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d['architectures']['x86_64']['artifacts']['qemu']['formats']['qcow2.xz']['disk']['location'])
")
  FCOS_XZ="${IMAGES_DIR}/$(basename "${FCOS_URL}")"
  echo "==> Downloading FCoOS: $(basename "${FCOS_URL}")"
  curl -L --progress-bar -o "${FCOS_XZ}" "${FCOS_URL}"
  echo "==> Decompressing..."
  xz -d "${FCOS_XZ}"
  mv "${FCOS_XZ%.xz}" "${FCOS_BASE}"
else
  echo "==> FCoOS base image already present."
fi

# --- Generate Ignition ---
# Use placeholder join info — kubeadm-join will fail gracefully (no cluster yet)
echo "==> Generating FCoOS Ignition..."
sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|FCOS_IP|${FCOS_IP}|g" \
  -e "s|FCOS_GATEWAY|${GATEWAY}|g" \
  -e "s|CP_IP|${CP_IP}|g" \
  -e "s|JOIN_TOKEN|placeholder.placeholder00000|g" \
  -e "s|CA_HASH|sha256:0000000000000000000000000000000000000000000000000000000000000000|g" \
  "${SCRIPT_DIR}/fcos-worker.bu" \
  | butane --strict > "${IGN_DIR}/fcos-worker-1.ign"

# --- Fresh overlay (wipe any previous state) ---
rm -f "${IMAGES_DIR}/fcos-worker-1.qcow2"
echo "==> Creating fresh FCoOS disk overlay..."
qemu-img create -F qcow2 -b "${FCOS_BASE}" -f qcow2 "${IMAGES_DIR}/fcos-worker-1.qcow2"

# --- TAP device ---
echo "==> Setting up TAP device..."
sudo ip tuntap add tap-fcos-w1 mode tap 2>/dev/null || true
sudo ip link set tap-fcos-w1 master virbr0
sudo ip link set tap-fcos-w1 up

# --- Host firewall: allow virbr0 forwarding ---
# Docker sets FORWARD policy DROP; add explicit rules so VMs can reach the internet.
# These are temporary (lost on reboot) — add to /etc/iptables if persistence needed.
WAN_IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
if [ -n "${WAN_IFACE}" ]; then
  sudo iptables -C FORWARD -i virbr0 -o "${WAN_IFACE}" -j ACCEPT 2>/dev/null || \
    sudo iptables -I FORWARD -i virbr0 -o "${WAN_IFACE}" -j ACCEPT
  sudo iptables -C FORWARD -i "${WAN_IFACE}" -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    sudo iptables -I FORWARD -i "${WAN_IFACE}" -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
fi

# --- Boot ---
echo "==> Starting FCoOS VM (${FCOS_IP})..."
sudo qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -drive if=virtio,file="${IMAGES_DIR}/fcos-worker-1.qcow2",format=qcow2 \
  -netdev tap,id=net0,ifname=tap-fcos-w1,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:12 \
  -fw_cfg name=opt/com.coreos/config,file="${IGN_DIR}/fcos-worker-1.ign" \
  -display none \
  -serial file:"${LOG_DIR}/fcos-worker-1.log" \
  -pidfile "${PID_DIR}/fcos-worker-1.pid" \
  -daemonize

echo ""
echo "==> FCoOS VM booting. Give it ~60 seconds for first boot."
echo ""
echo "    SSH:         ssh ${FCOS_ADMIN}@${FCOS_IP}"
echo "    Serial log:  tail -f ${LOG_DIR}/fcos-worker-1.log"
echo ""
echo "    Once in, check sysext status:"
echo "      journalctl -fu load-flatcar-k8s-sysext.service"
echo "      systemd-sysext status"
echo ""
echo "    Stop with:   ./stop.sh"
