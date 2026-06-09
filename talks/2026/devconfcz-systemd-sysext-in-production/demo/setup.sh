#!/bin/bash
# ABOUTME: Creates all Azure VMs, boots the Kubernetes cluster, and pre-stages demo files.
# ABOUTME: Requires prep-infra.sh to have been run at least once beforehand.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"
source "${SCRIPT_DIR}/tailscale.env"

# -----------------------------------------------------------------------
# Prerequisites
# -----------------------------------------------------------------------
for cmd in az butane curl openssl; do
  command -v "$cmd" &>/dev/null || { echo "ERROR: $cmd not found"; exit 1; }
done

az account show -o none 2>/dev/null || { echo "ERROR: Not logged in to Azure. Run: az login"; exit 1; }

[ -f "${SSH_KEY_PATH}" ]     || { echo "ERROR: SSH key not found: ${SSH_KEY_PATH}"; exit 1; }
[ -f "${SSH_KEY_PATH}.pub" ] || { echo "ERROR: SSH pubkey not found: ${SSH_KEY_PATH}.pub"; exit 1; }

# Verify infra resources exist
az group show --name "${AZ_RG_INFRA}" -o none 2>/dev/null || {
  echo "ERROR: Infra resource group '${AZ_RG_INFRA}' not found."
  echo "       Run ./prep-infra.sh first."
  exit 1
}

az image show --resource-group "${AZ_RG_INFRA}" --name "${FCOS_IMAGE_NAME}" -o none 2>/dev/null || {
  echo "ERROR: FCoOS managed image '${FCOS_IMAGE_NAME}' not found in ${AZ_RG_INFRA}."
  echo "       Run ./prep-infra.sh first."
  exit 1
}

# Check for stale Tailscale node — only block if it's actually reachable
STALE_TS_OUT=$(tailscale status 2>/dev/null || true)
STALE_IP=$(echo "${STALE_TS_OUT}" | awk '$2 ~ /^flatcar-cp/ {print $1; exit}')
if [ -n "${STALE_IP}" ]; then
  if ssh ${SSH_OPTS} -o ConnectTimeout=3 -o BatchMode=yes \
      "${ADMIN_USER}@${STALE_IP}" true 2>/dev/null; then
    echo "ERROR: flatcar-cp is still live at ${STALE_IP}. Run ./stop.sh first."
    exit 1
  else
    echo "    Note: stale Tailscale entry for flatcar-cp (not reachable) — proceeding."
    echo "          Clean it up at https://login.tailscale.com/admin/machines when convenient."
  fi
fi

SSH_PUBKEY="$(cat "${SSH_KEY_PATH}.pub")"

# Blob base URLs (constructed from common.env)
BLOB_BASE="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}"
BLOB_FLATCAR="${BLOB_BASE}/flatcar"
BLOB_FEDORA="${BLOB_BASE}/fedora"

FCOS_IMAGE_ID=$(az image show \
  --resource-group "${AZ_RG_INFRA}" \
  --name "${FCOS_IMAGE_NAME}" \
  --query "id" -o tsv)

echo "==> setup.sh"
echo "    VMs RG:    ${AZ_RG_VMS}"
echo "    Location:  ${AZ_LOCATION}"
echo "    VM size:   ${VM_SIZE}"
echo "    Blob base: ${BLOB_BASE}"
echo ""

# -----------------------------------------------------------------------
# VMs resource group + networking
# -----------------------------------------------------------------------
ts() { echo "[$(date '+%H:%M:%S')] $*"; }

# Derive static IPs from subnet (Azure reserves .1-.3)
SUBNET_BASE="${SUBNET_CIDR%.*}"
CP_INTERNAL_IP="${SUBNET_BASE}.4"
W1_IP="${SUBNET_BASE}.5"
W2_IP="${SUBNET_BASE}.6"
W3_IP="${SUBNET_BASE}.7"

# Pre-generate kubeadm join token — format: [a-z0-9]{6}.[a-z0-9]{16}
# openssl rand avoids SIGPIPE issues with tr|head under set -euo pipefail
JOIN_TOKEN="$(openssl rand -hex 3).$(openssl rand -hex 8)"

ts "Creating VMs resource group: ${AZ_RG_VMS}"
az group create --name "${AZ_RG_VMS}" --location "${AZ_LOCATION}" -o none

ts "Creating VNet, NSG, and accepting marketplace terms (parallel)..."
az network vnet create \
  --resource-group "${AZ_RG_VMS}" \
  --name "${VNET_NAME}" \
  --address-prefix "${VNET_CIDR}" \
  --subnet-name "${SUBNET_NAME}" \
  --subnet-prefix "${SUBNET_CIDR}" \
  -o none &
az network nsg create \
  --resource-group "${AZ_RG_VMS}" \
  --name "${NSG_NAME}" \
  -o none &
az vm image terms accept \
  --publisher kinvolk \
  --offer flatcar-container-linux-free \
  --plan stable-gen2 \
  -o none 2>/dev/null &
wait
ts "Networking ready"

# -----------------------------------------------------------------------
# Generate all 4 ignition configs upfront (IPs and token known statically)
# -----------------------------------------------------------------------
ts "Generating all ignition configs..."
CP_IGN=$(mktemp); W1_IGN=$(mktemp); W2_IGN=$(mktemp); W3_IGN=$(mktemp)

sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|TS_AUTHKEY|${TS_KEY}|g" \
  -e "s|VNET_CIDR|${SUBNET_CIDR}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|BLOB_FLATCAR_URL|${BLOB_FLATCAR}|g" \
  "${SCRIPT_DIR}/control-plane.bu" | butane --strict > "${CP_IGN}"

sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|CP_IP|${CP_INTERNAL_IP}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|BLOB_FLATCAR_URL|${BLOB_FLATCAR}|g" \
  "${SCRIPT_DIR}/worker-1.bu" | butane --strict > "${W1_IGN}"

sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|CP_IP|${CP_INTERNAL_IP}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|BLOB_FLATCAR_URL|${BLOB_FLATCAR}|g" \
  "${SCRIPT_DIR}/worker-2.bu" | butane --strict > "${W2_IGN}"

sed \
  -e "s|SSH_PUBKEY|${SSH_PUBKEY}|g" \
  -e "s|CP_IP|${CP_INTERNAL_IP}|g" \
  -e "s|JOIN_TOKEN|${JOIN_TOKEN}|g" \
  -e "s|BLOB_FEDORA_URL|${BLOB_FEDORA}|g" \
  "${SCRIPT_DIR}/worker-3.bu" | butane --strict > "${W3_IGN}"

# -----------------------------------------------------------------------
# Submit all 4 VMs immediately with static IPs
# -----------------------------------------------------------------------
ts "Submitting control plane VM: ${CP_VM_NAME} (${CP_INTERNAL_IP})"
az vm create --only-show-errors \
  --resource-group "${AZ_RG_VMS}" \
  --name "${CP_VM_NAME}" \
  --image "${FLATCAR_IMAGE}" \
  --size "${VM_SIZE}" \
  --admin-username "${ADMIN_USER}" \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --custom-data "${CP_IGN}" \
  --vnet-name "${VNET_NAME}" \
  --subnet "${SUBNET_NAME}" \
  --nsg "${NSG_NAME}" \
  --private-ip-address "${CP_INTERNAL_IP}" \
  --no-wait \
  -o none
rm -f "${CP_IGN}"

ts "Submitting worker-1 VM: ${WORKER1_VM_NAME} (${W1_IP})"
az vm create --only-show-errors \
  --resource-group "${AZ_RG_VMS}" \
  --name "${WORKER1_VM_NAME}" \
  --image "${FLATCAR_IMAGE}" \
  --size "${VM_SIZE}" \
  --admin-username "${ADMIN_USER}" \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --custom-data "${W1_IGN}" \
  --vnet-name "${VNET_NAME}" \
  --subnet "${SUBNET_NAME}" \
  --nsg "${NSG_NAME}" \
  --private-ip-address "${W1_IP}" \
  --no-wait \
  -o none
rm -f "${W1_IGN}"

ts "Submitting worker-2 VM: ${WORKER2_VM_NAME} (${W2_IP})"
az vm create --only-show-errors \
  --resource-group "${AZ_RG_VMS}" \
  --name "${WORKER2_VM_NAME}" \
  --image "${FCOS_IMAGE_ID}" \
  --size "${VM_SIZE}" \
  --admin-username "${ADMIN_USER}" \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --custom-data "${W2_IGN}" \
  --vnet-name "${VNET_NAME}" \
  --subnet "${SUBNET_NAME}" \
  --nsg "${NSG_NAME}" \
  --private-ip-address "${W2_IP}" \
  --no-wait \
  -o none
rm -f "${W2_IGN}"

ts "Submitting worker-3 VM: ${WORKER3_VM_NAME} (${W3_IP})"
az vm create --only-show-errors \
  --resource-group "${AZ_RG_VMS}" \
  --name "${WORKER3_VM_NAME}" \
  --image "${FCOS_IMAGE_ID}" \
  --size "${VM_SIZE}" \
  --admin-username "${ADMIN_USER}" \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --custom-data "${W3_IGN}" \
  --vnet-name "${VNET_NAME}" \
  --subnet "${SUBNET_NAME}" \
  --nsg "${NSG_NAME}" \
  --private-ip-address "${W3_IP}" \
  --no-wait \
  -o none
rm -f "${W3_IGN}"

# -----------------------------------------------------------------------
# Wait for control plane on Tailscale
# -----------------------------------------------------------------------
ts "All 4 VMs submitted — waiting for CP on Tailscale (up to 15 minutes)..."
CP_TS_IP=""
for i in $(seq 1 900); do
  TS_OUT=$(tailscale status 2>/dev/null || true)
  # Match any flatcar-cp* device (handles renamed duplicates like flatcar-cp-1)
  CANDIDATES=$(echo "${TS_OUT}" | awk '$2 ~ /^flatcar-cp/ {print $1}')
  for ip in ${CANDIDATES}; do
    if ssh ${SSH_OPTS} -o ConnectTimeout=3 -o BatchMode=yes \
        "${ADMIN_USER}@${ip}" true 2>/dev/null; then
      CP_TS_IP="${ip}"
      break 2
    fi
  done
  [ "$i" -eq 900 ] && { echo "ERROR: CP did not appear on Tailscale after 15 minutes"; exit 1; }
  sleep 1
done
ts "Control plane is on the tailnet!"
echo "    Tailscale IP: ${CP_TS_IP}"

# -----------------------------------------------------------------------
# Wait for kubeadm init
# -----------------------------------------------------------------------
ts "Waiting for kubeadm init (up to 10 minutes)..."
for i in $(seq 1 600); do
  if ssh ${SSH_OPTS} -o ConnectTimeout=5 "${ADMIN_USER}@${CP_TS_IP}" \
      'test -f /home/core/.kube/config' 2>/dev/null; then
    ts "kubeadm init complete!"
    break
  fi
  [ "$i" -eq 600 ] && { echo "ERROR: kubeadm init timed out"; exit 1; }
  sleep 1
done

# -----------------------------------------------------------------------
# Install Calico CNI
# -----------------------------------------------------------------------
ts "Installing Calico CNI"
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" \
  'kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml'
# Force eth0: Tailscale interface confuses Calico IP autodetection
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" \
  'kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=eth0'

# -----------------------------------------------------------------------
# Deploy Headlamp (early — starts pulling image while workers boot)
# -----------------------------------------------------------------------
ts "Deploying Headlamp dashboard"
scp ${SSH_OPTS} "${SCRIPT_DIR}/headlamp.yaml" "${ADMIN_USER}@${CP_TS_IP}:/tmp/headlamp.yaml"
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" \
  'kubectl apply -f /tmp/headlamp.yaml && rm /tmp/headlamp.yaml'

# -----------------------------------------------------------------------
# Write join info (all values known statically — no SSH needed)
# -----------------------------------------------------------------------
cat > "${JOIN_INFO}" <<EOF
# Generated by setup.sh — do not edit
CP_TS_IP=${CP_TS_IP}
CP_INTERNAL_IP=${CP_INTERNAL_IP}
JOIN_TOKEN=${JOIN_TOKEN}
WORKER1_IP=${W1_IP}
WORKER2_IP=${W2_IP}
WORKER3_IP=${W3_IP}
EOF
echo "    Join info saved to: ${JOIN_INFO}"

# -----------------------------------------------------------------------
# Wait for all workers to join AND be Ready
# -----------------------------------------------------------------------
echo ""
ts "Waiting for all 4 nodes to be Ready (up to 10 minutes)..."
for i in $(seq 1 600); do
  READY_COUNT=$(ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" \
    'kubectl get nodes --no-headers 2>/dev/null | awk '\''$2=="Ready"{c++} END{print c+0}'\''' 2>/dev/null || echo "0")
  if [ "${READY_COUNT}" -ge 4 ]; then
    ts "All 4 nodes Ready!"
    break
  fi
  [ "$i" -eq 600 ] && echo "WARNING: Not all nodes Ready after 10 minutes. Check status.sh."
  sleep 1
done
echo ""
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" 'kubectl get nodes -o wide' 2>/dev/null || true

# -----------------------------------------------------------------------
# Pre-stage upgrade sysexts on workers (downloaded in background)
# -----------------------------------------------------------------------
# Workers need the v1.33.12 sysext staged locally before the demo upgrade step.
echo ""
echo "==> Pre-staging upgrade sysexts on workers (background downloads)..."
SETUP_LOG="${SCRIPT_DIR}/setup-background.log"

ssh ${SSH_OPTS} "${ADMIN_USER}@${W1_IP}" \
  "curl -fsSL --retry 3 -o ~/kubernetes-v1.33.12-x86-64.raw \
   ${BLOB_FLATCAR}/kubernetes-v1.33.12-x86-64.raw" \
  >> "${SETUP_LOG}" 2>&1 &
PID_W1=$!

ssh ${SSH_OPTS} "${ADMIN_USER}@${W2_IP}" \
  "curl -fsSL --retry 3 -o ~/kubernetes-v1.33.12-x86-64.raw \
   ${BLOB_FLATCAR}/kubernetes-v1.33.12-x86-64.raw" \
  >> "${SETUP_LOG}" 2>&1 &
PID_W2=$!

ssh ${SSH_OPTS} "${ADMIN_USER}@${W3_IP}" \
  "curl -fsSL --retry 3 -o ~/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw \
   ${BLOB_FEDORA}/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw" \
  >> "${SETUP_LOG}" 2>&1 &
PID_W3=$!

# -----------------------------------------------------------------------
# Deploy demo workload + finish Headlamp
# -----------------------------------------------------------------------
echo "==> Deploying demo workload (nginx x3)"
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" "kubectl apply -f -" \
  < "${SCRIPT_DIR}/demo-workload.yaml"

echo "==> Waiting for Headlamp rollout..."
ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" \
  'kubectl rollout status deployment/headlamp -n headlamp --timeout=180s' || true

HEADLAMP_TOKEN=$(ssh ${SSH_OPTS} "${ADMIN_USER}@${CP_TS_IP}" \
  'kubectl create token headlamp -n headlamp --duration=24h')
echo "${HEADLAMP_TOKEN}" > "${TOKEN_FILE}"

# -----------------------------------------------------------------------
# Wait for background pre-staging
# -----------------------------------------------------------------------
echo "==> Waiting for upgrade sysext downloads..."
for pid_var in PID_W1 PID_W2 PID_W3; do
  pid="${!pid_var}"
  label="${pid_var/PID_/worker-}"
  wait "${pid}" && echo "    ${label}: done" || echo "    WARNING: ${label} staging may have failed. Check ${SETUP_LOG}"
done

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
echo ""
echo "==> Setup complete!"
echo ""
echo "    Control plane:  ssh ${ADMIN_USER}@${CP_TS_IP} (Tailscale)"
echo "    worker-1 IP:    ${W1_IP}"
echo "    worker-2 IP:    ${W2_IP}"
echo "    worker-3 IP:    ${W3_IP}"
echo ""
echo "    Headlamp:       http://${CP_TS_IP}:30080"
echo "    Headlamp token: ${HEADLAMP_TOKEN}"
echo "    Token saved to: ${TOKEN_FILE}"
echo ""
echo "    SSH helper: ./go.sh <vm-name>"
echo "    Tear down:  ./stop.sh  (preserves infra and storage)"
echo "    Full reset: ./nuke.sh  (deletes everything)"

# -----------------------------------------------------------------------
# Remind about Tailscale subnet route (auto-approved via tag:kcd ACL)
# -----------------------------------------------------------------------
echo ""
echo "============================================="
echo "  Tailscale subnet route: ${SUBNET_CIDR}"
echo "  Auto-approved via tag:kcd ACL."
echo "  Workers reachable via ./go.sh from Tailscale-connected machines."
echo "============================================="
