#!/bin/bash
# ABOUTME: SSH into a demo VM by name via Tailscale subnet routing.
# ABOUTME: CP is reached directly via Tailscale IP; workers via private subnet IP.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

VM_NAME="${1:-}"
if [ -z "${VM_NAME}" ]; then
  echo "Usage: $0 <vm-name>"
  echo "  e.g., $0 ${CP_VM_NAME}"
  echo "        $0 ${WORKER1_VM_NAME}"
  echo "        $0 ${WORKER2_VM_NAME}"
  echo "        $0 ${WORKER3_VM_NAME}"
  exit 1
fi

# Load cached IPs from join-info.env if available
if [ -f "${JOIN_INFO}" ]; then
  source "${JOIN_INFO}"
fi

IP=""
if [ "${VM_NAME}" = "${CP_VM_NAME}" ]; then
  TS_OUT=$(tailscale status 2>/dev/null || true)
  IP=$(echo "$TS_OUT" | awk '$2 ~ /^flatcar-cp/ {print $1; exit}')
elif [ "${VM_NAME}" = "${WORKER1_VM_NAME}" ] && [ -n "${WORKER1_IP:-}" ]; then
  IP="${WORKER1_IP}"
elif [ "${VM_NAME}" = "${WORKER2_VM_NAME}" ] && [ -n "${WORKER2_IP:-}" ]; then
  IP="${WORKER2_IP}"
elif [ "${VM_NAME}" = "${WORKER3_VM_NAME}" ] && [ -n "${WORKER3_IP:-}" ]; then
  IP="${WORKER3_IP}"
fi

# Fall back to Azure private IP lookup (reachable via Tailscale subnet route)
if [ -z "${IP:-}" ]; then
  IP=$(az vm show \
    --resource-group "${AZ_RG_VMS}" \
    --name "${VM_NAME}" \
    --show-details \
    --query privateIps -o tsv 2>/dev/null || true)
fi

if [ -z "${IP:-}" ]; then
  echo "ERROR: Could not find IP for '${VM_NAME}' in ${AZ_RG_VMS}"
  echo "       Is the cluster running? Try: az vm list -g ${AZ_RG_VMS} -o table"
  exit 1
fi

# Connect immediately if available, otherwise wait
if ssh ${SSH_OPTS} -o ConnectTimeout=2 -o BatchMode=yes "${ADMIN_USER}@${IP}" true 2>/dev/null; then
  exec ssh ${SSH_OPTS} "${ADMIN_USER}@${IP}"
fi

echo "Waiting for ${VM_NAME} (${IP}) to be reachable..."
for i in $(seq 1 120); do
  if ssh ${SSH_OPTS} -o ConnectTimeout=2 -o BatchMode=yes "${ADMIN_USER}@${IP}" true 2>/dev/null; then
    exec ssh ${SSH_OPTS} "${ADMIN_USER}@${IP}"
  fi
  sleep 1
done

echo "ERROR: ${VM_NAME} not reachable at ${IP} after 120s"
exit 1
