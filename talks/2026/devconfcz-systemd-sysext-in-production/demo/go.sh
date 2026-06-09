#!/bin/bash
# ABOUTME: SSH into a demo VM by short name (flatcar-cp, worker-1, worker-2, worker-3).
# ABOUTME: Resolves the IP from common.env; no cloud provider or VPN required.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

VM_NAME="${1:-}"
if [ -z "${VM_NAME}" ]; then
  echo "Usage: $0 <vm-name>"
  echo ""
  echo "  Known nodes:"
  echo "    ${CP_HOSTNAME}  (${CP_IP})"
  echo "    ${W1_HOSTNAME}  (${W1_IP})"
  echo "    ${W2_HOSTNAME}  (${W2_IP})"
  echo "    ${W3_HOSTNAME}  (${W3_IP})"
  exit 1
fi

case "${VM_NAME}" in
  "${CP_HOSTNAME}") IP="${CP_IP}" ;;
  "${W1_HOSTNAME}") IP="${W1_IP}" ;;
  "${W2_HOSTNAME}") IP="${W2_IP}" ;;
  "${W3_HOSTNAME}") IP="${W3_IP}" ;;
  *)
    echo "ERROR: Unknown VM '${VM_NAME}'"
    echo "Run '$0' with no arguments to see valid names."
    exit 1
    ;;
esac

# Connect immediately if the node is already up
if ssh ${SSH_OPTS} -o ConnectTimeout=2 -o BatchMode=yes "${ADMIN}@${IP}" true 2>/dev/null; then
  exec ssh ${SSH_OPTS} "${ADMIN}@${IP}"
fi

# Otherwise wait up to 2 minutes
echo "Waiting for ${VM_NAME} (${IP}) to be ready..."
for i in $(seq 1 120); do
  if ssh ${SSH_OPTS} -o ConnectTimeout=2 -o BatchMode=yes "${ADMIN}@${IP}" true 2>/dev/null; then
    exec ssh ${SSH_OPTS} "${ADMIN}@${IP}"
  fi
  sleep 1
done

echo "ERROR: ${VM_NAME} not reachable at ${IP} after 120s"
exit 1
