#!/bin/bash
# ABOUTME: Shows cluster node status by SSHing to the control plane.
# ABOUTME: Also prints tips for watching sysext loading on the FCoOS workers.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

echo "==> Cluster nodes:"
ssh ${SSH_OPTS} "${ADMIN}@${CP_IP}" 'kubectl get nodes -o wide' 2>/dev/null || \
  echo "    Control plane not reachable yet"

echo ""
echo "==> SSH shortcuts:"
echo "    Control plane: ssh ${ADMIN}@${CP_IP}"
echo "    worker-1:      ssh ${ADMIN}@${W1_IP}   (Flatcar, Flatcar bakery sysext)"
echo "    worker-2:      ssh ${ADMIN}@${W2_IP}   (FCoOS, Flatcar bakery sysext)"
echo "    worker-3:      ssh ${ADMIN}@${W3_IP}   (FCoOS, fedora-sysexts sysext)"

echo ""
echo "==> Watch sysext loading:"
echo "    worker-2: ssh ${ADMIN}@${W2_IP} 'journalctl -fu load-flatcar-k8s-sysext.service'"
echo "    worker-3: ssh ${ADMIN}@${W3_IP} 'journalctl -fu load-fedora-k8s-sysext.service'"

echo ""
echo "==> Headlamp dashboard:"
echo "    URL:   http://${CP_IP}:30080"
if [ -f "${TOKEN_FILE}" ]; then
  echo "    Token: $(cat "${TOKEN_FILE}")"
else
  echo "    Token: (not yet generated — run setup.sh first)"
fi

echo ""
echo "==> Serial console logs:"
echo "    tail -f ${LOG_DIR}/flatcar-cp.log"
echo "    tail -f ${LOG_DIR}/worker-1.log"
echo "    tail -f ${LOG_DIR}/worker-2.log"
echo "    tail -f ${LOG_DIR}/worker-3.log"

set -euo pipefail
