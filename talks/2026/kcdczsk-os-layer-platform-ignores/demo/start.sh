#!/bin/bash
# ABOUTME: On-stage script to launch worker-2 during Demo 1.
# ABOUTME: Reads join info from setup.sh, generates Ignition, creates the VM.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"
source "${SCRIPT_DIR}/join-info.env"

SSH_PUBKEY="$(cat "${SSH_KEY_PATH}.pub")"

echo "==> Generating worker-2 Ignition"
W2_IGN=$(mktemp)
sed -e "s|SSH_PUBKEY|${SSH_PUBKEY}|" \
    -e "s|WORKER_HOSTNAME|${WORKER2_VM_NAME}|" \
    -e "s|CP_IP|${CP_INTERNAL_IP}|" \
    -e "s|JOIN_TOKEN|${JOIN_TOKEN}|" \
    -e "s|CA_HASH|${CA_HASH}|" \
    "${SCRIPT_DIR}/worker.bu" \
  | butane --strict > "${W2_IGN}"

echo "==> Creating worker-2 VM: ${WORKER2_VM_NAME} (no public IP)"
AZ_LOG="${SCRIPT_DIR}/worker2-create.log"
JOIN_INFO="${SCRIPT_DIR}/join-info.env"
(
  az vm create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${WORKER2_VM_NAME}" \
    --image "${FLATCAR_IMAGE}" \
    --size "${VM_SIZE}" \
    --admin-username "${ADMIN_USER}" \
    --ssh-key-values "${SSH_KEY_PATH}.pub" \
    --custom-data "${W2_IGN}" \
    --vnet-name "${VNET_NAME}" \
    --subnet "${SUBNET_NAME}" \
    --nsg "${NSG_NAME}" \
    --public-ip-address "" \
    -o table \
    > "${AZ_LOG}" 2>&1
  WORKER2_IP=$(az vm show -g "${RESOURCE_GROUP}" -n "${WORKER2_VM_NAME}" \
    --show-details --query privateIps -o tsv 2>/dev/null)
  if [ -n "${WORKER2_IP}" ]; then
    echo "WORKER2_IP=${WORKER2_IP}" >> "${JOIN_INFO}"
  fi
  rm -f "${W2_IGN}"
) &
AZ_PID=$!

echo ""
echo "==> Worker-2 creation running in background (PID ${AZ_PID})"
echo "    Output: ${AZ_LOG}"
