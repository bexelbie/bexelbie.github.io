#!/bin/bash
# ABOUTME: Pre-talk setup: creates Azure infra, control plane, and first worker.
# ABOUTME: Uses Tailscale on the control plane for all connectivity (no public IPs).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"
source "${SCRIPT_DIR}/tailscale.env"

SSH_PUBKEY="$(cat "${SSH_KEY_PATH}.pub")"
JOIN_INFO="${SCRIPT_DIR}/join-info.env"

# Abort if stale Tailscale entries exist for our hostnames
STALE_NODES=$(tailscale status 2>/dev/null \
  | awk '$2 == "flatcar-cp" || $2 ~ /^flatcar-worker/' || true)
if [[ -n "${STALE_NODES}" ]]; then
  echo "ERROR: Stale Tailscale entries found for demo hostnames:"
  echo "${STALE_NODES}" | sed 's/^/    /'
  echo "    Remove them in the Tailscale admin console before running setup."
  exit 1
fi

echo "==> Creating resource group: ${RESOURCE_GROUP}"
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}" -o none

echo "==> Creating virtual network and subnet"
az network vnet create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VNET_NAME}" \
  --address-prefix "${VNET_CIDR}" \
  --subnet-name "${SUBNET_NAME}" \
  --subnet-prefix "${SUBNET_CIDR}" \
  -o none

echo "==> Creating network security group (deny all inbound)"
az network nsg create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${NSG_NAME}" \
  -o none

# No inbound rules — all access via Tailscale

# --- Accept marketplace terms ---
echo "==> Accepting Flatcar marketplace terms"
az vm image terms accept \
  --publisher kinvolk \
  --offer flatcar-container-linux-free \
  --plan stable-gen2 \
  -o none 2>/dev/null || true

# --- Control Plane ---
echo "==> Generating control plane Ignition"
CP_IGN=$(mktemp)
sed -e "s|SSH_PUBKEY|${SSH_PUBKEY}|" \
    -e "s|TS_AUTHKEY|${TS_KEY}|" \
    -e "s|VNET_CIDR|${VNET_CIDR}|" \
    "${SCRIPT_DIR}/control-plane.bu" \
  | butane --strict > "${CP_IGN}"

echo "==> Creating control plane VM: ${CP_VM_NAME} (no public IP)"
az vm create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${CP_VM_NAME}" \
  --image "${FLATCAR_IMAGE}" \
  --size "${VM_SIZE}" \
  --admin-username "${ADMIN_USER}" \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --custom-data "${CP_IGN}" \
  --vnet-name "${VNET_NAME}" \
  --subnet "${SUBNET_NAME}" \
  --nsg "${NSG_NAME}" \
  --public-ip-address "" \
  -o table
rm -f "${CP_IGN}"

# --- Wait for Tailscale to come up ---
# Match exactly "flatcar-cp" (tab-delimited, second field) to avoid stale flatcar-cp-N entries
echo "==> Waiting for control plane to appear on Tailscale (hostname: flatcar-cp)..."
for i in $(seq 1 180); do
  if tailscale status 2>/dev/null | awk '$2 == "flatcar-cp"' | grep -q 'flatcar-cp'; then
    echo "    Control plane is on the tailnet!"
    break
  fi
  if [ "$i" -eq 180 ]; then
    echo "ERROR: Control plane did not appear on Tailscale after 3 minutes"
    exit 1
  fi
  sleep 1
done

# Resolve the tailnet IP for SSH
CP_TAILSCALE_IP=$(tailscale status 2>/dev/null | awk '$2 == "flatcar-cp" {print $1; exit}' || true)
if [ -z "${CP_TAILSCALE_IP}" ]; then
  echo "ERROR: Could not resolve Tailscale IP for flatcar-cp"
  echo "    Hint: stale nodes may exist. Check 'tailscale status | grep flatcar'"
  exit 1
fi

echo "    Control plane Tailscale IP: ${CP_TAILSCALE_IP}"

# Use Tailscale IP for all SSH to control plane
CP_SSH="${CP_TAILSCALE_IP}"

# --- Wait for kubeadm init ---
echo "==> Waiting for kubeadm init to complete (this takes 2-5 minutes)..."
for i in $(seq 1 300); do
  if ssh ${SSH_OPTS} -o ConnectTimeout=5 "${ADMIN_USER}@${CP_SSH}" \
    'test -f /home/core/.kube/config' 2>/dev/null; then
    echo "    kubeadm init complete!"
    break
  fi
  if [ "$i" -eq 300 ]; then
    echo "ERROR: kubeadm init did not complete after 5 minutes"
    exit 1
  fi
  sleep 1
done

# --- Install CNI (Calico) ---
echo "==> Installing Calico CNI"
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml'

# Tailscale interface confuses Calico IP autodetection — force eth0
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=eth0'

# --- Deploy Headlamp dashboard ---
echo "==> Deploying Headlamp dashboard (NodePort 30080 on control plane)"
scp ${SSH_OPTS} "${SCRIPT_DIR}/headlamp.yaml" "${ADMIN_USER}@${CP_SSH}:/tmp/headlamp.yaml"
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'kubectl apply -f /tmp/headlamp.yaml && rm /tmp/headlamp.yaml'

# --- Deploy demo workload ---
echo "==> Deploying demo workload (nginx x3 with topology spread)"
scp ${SSH_OPTS} "${SCRIPT_DIR}/demo-workload.yaml" "${ADMIN_USER}@${CP_SSH}:/tmp/demo-workload.yaml"
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'kubectl apply -f /tmp/demo-workload.yaml && rm /tmp/demo-workload.yaml'

# --- Extract join info ---
echo "==> Extracting kubeadm join information"
CP_INTERNAL_IP=$(ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'ip -4 addr show eth0 | grep -oP "(?<=inet )[\d.]+"')

JOIN_COMMAND=$(ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'kubeadm token create --print-join-command')

JOIN_TOKEN=$(echo "${JOIN_COMMAND}" | grep -oP '(?<=--token )\S+')
CA_HASH=$(echo "${JOIN_COMMAND}" | grep -oP '(?<=--discovery-token-ca-cert-hash )\S+')

cat > "${JOIN_INFO}" <<EOF
# Generated by setup.sh — do not edit
CP_SSH=${CP_SSH}
CP_INTERNAL_IP=${CP_INTERNAL_IP}
JOIN_TOKEN=${JOIN_TOKEN}
CA_HASH=${CA_HASH}
EOF

echo "    Join info saved to: ${JOIN_INFO}"

# --- Worker 1 (pre-staged) ---
echo "==> Generating worker-1 Ignition"
W1_IGN=$(mktemp)
sed -e "s|SSH_PUBKEY|${SSH_PUBKEY}|" \
    -e "s|WORKER_HOSTNAME|${WORKER1_VM_NAME}|" \
    -e "s|CP_IP|${CP_INTERNAL_IP}|" \
    -e "s|JOIN_TOKEN|${JOIN_TOKEN}|" \
    -e "s|CA_HASH|${CA_HASH}|" \
    "${SCRIPT_DIR}/worker.bu" \
  | butane --strict > "${W1_IGN}"

echo "==> Creating worker-1 VM: ${WORKER1_VM_NAME} (no public IP)"
az vm create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${WORKER1_VM_NAME}" \
  --image "${FLATCAR_IMAGE}" \
  --size "${VM_SIZE}" \
  --admin-username "${ADMIN_USER}" \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --custom-data "${W1_IGN}" \
  --vnet-name "${VNET_NAME}" \
  --subnet "${SUBNET_NAME}" \
  --nsg "${NSG_NAME}" \
  --public-ip-address "" \
  -o table
WORKER1_IP=$(az vm show -g "${RESOURCE_GROUP}" -n "${WORKER1_VM_NAME}" \
  --show-details --query privateIps -o tsv)
echo "WORKER1_IP=${WORKER1_IP}" >> "${JOIN_INFO}"
rm -f "${W1_IGN}"

# --- Wait for worker to join ---
echo "==> Waiting for worker-1 to join the cluster..."
for i in $(seq 1 180); do
  NODE_COUNT=$(ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
    'kubectl get nodes --no-headers 2>/dev/null | wc -l' 2>/dev/null || echo "0")
  if [ "${NODE_COUNT}" -ge 2 ]; then
    echo "    Worker-1 joined the cluster!"
    break
  fi
  if [ "$i" -eq 180 ]; then
    echo "WARNING: Worker-1 not yet visible after 3 minutes. Check manually."
  fi
  sleep 1
done

# --- Pre-stage OS update on worker-1 ---
echo "==> Pre-staging OS update on worker-1 (download to inactive partition)..."
SETUP_LOG="${SCRIPT_DIR}/setup-background.log"
ssh ${SSH_OPTS} "${ADMIN_USER}@${WORKER1_IP}" \
  'sudo systemctl unmask update-engine && \
   sudo systemctl start update-engine && \
   sudo update_engine_client -update' >> "${SETUP_LOG}" 2>&1 &
UPDATE_PID=$!
echo "    Update downloading in background (PID ${UPDATE_PID})"

# --- Pre-cache kubernetes sysext for Demo 3 ---
echo "==> Pre-caching kubernetes sysext v1.33.12 on worker-1..."
ssh ${SSH_OPTS} "${ADMIN_USER}@${WORKER1_IP}" \
  'curl -sL -o ~/kubernetes-v1.33.12-x86-64.raw \
   https://extensions.flatcar.org/extensions/kubernetes-v1.33.12-x86-64.raw' >> "${SETUP_LOG}" 2>&1 &
SYSEXT_PID=$!
echo "    Sysext downloading in background (PID ${SYSEXT_PID})"

HEADLAMP_TOKEN=$(ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" \
  'kubectl create token headlamp -n headlamp --duration=24h')
TOKEN_FILE="${SCRIPT_DIR}/../token"
echo "${HEADLAMP_TOKEN}" > "${TOKEN_FILE}"

# --- Wait for background tasks ---
echo "==> Waiting for background downloads to complete..."
WAIT_FAILED=0
wait "${UPDATE_PID}" || WAIT_FAILED=1
if [ "${WAIT_FAILED}" -eq 1 ]; then
  echo "    WARNING: OS update pre-staging may have failed. Check ${SETUP_LOG}"
else
  echo "    OS update pre-staged successfully."
fi

WAIT_FAILED=0
wait "${SYSEXT_PID}" || WAIT_FAILED=1
if [ "${WAIT_FAILED}" -eq 1 ]; then
  echo "    WARNING: Sysext download may have failed. Check ${SETUP_LOG}"
else
  echo "    Kubernetes sysext cached successfully."
fi

echo ""
echo "==> Setup complete!"
echo "    Control plane: ssh ${ADMIN_USER}@${CP_SSH} (via Tailscale)"
echo "    Headlamp:      http://${CP_TAILSCALE_IP}:30080"
echo "    Headlamp token saved to: ${TOKEN_FILE}"
echo "    ${HEADLAMP_TOKEN}"
echo "    Cluster status:"
sleep 2
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_SSH}" 'kubectl get nodes -o wide' 2>/dev/null

# --- Presentation environment ---
echo "==> Opening slides in LibreOffice..."
libreoffice --impress "${SCRIPT_DIR}/../slides/slides.pptx" &

echo "==> Opening tmux demo session..."
TMUX_SESSION="demo"
ptyxis --new-window -- tmux new-session -s "${TMUX_SESSION}"
sleep 2
ptyxis --new-window -- tmux attach-session -t "${TMUX_SESSION}"

echo ""
echo "==> Run monitor-setup.sh manually in a separate terminal:"
echo "    ${SCRIPT_DIR}/../monitor-setup.sh"
