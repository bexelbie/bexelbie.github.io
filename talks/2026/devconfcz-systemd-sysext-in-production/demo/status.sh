#!/bin/bash
# ABOUTME: Shows cluster status: Azure VM states and Kubernetes node readiness.
# ABOUTME: Works at any point — before, during, or after setup.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

# Load join info if available; otherwise derive CP Tailscale IP on the fly
if [ -f "${JOIN_INFO}" ]; then
  source "${JOIN_INFO}"
else
  echo "    (join-info.env not yet written — setup.sh still running or not started)"
  TS_OUT=$(tailscale status 2>/dev/null || true)
  CP_TS_IP=$(echo "$TS_OUT" | awk '$2 ~ /^flatcar-cp/ {print $1; exit}')
fi

echo "==> Azure VMs in ${AZ_RG_VMS}:"
az vm list --resource-group "${AZ_RG_VMS}" \
  --query "[].{Name:name, Prov:provisioningState, IP:\"[0].privateIpAddress\"}" \
  -o table 2>/dev/null || echo "    (resource group not found)"

echo ""
if [ -n "${CP_TS_IP:-}" ]; then
  echo "==> Kubernetes nodes (via ${CP_TS_IP}):"
  ssh ${SSH_OPTS} -o ConnectTimeout=5 "${ADMIN_USER}@${CP_TS_IP}" 'kubectl get nodes -o wide' 2>/dev/null || \
    echo "    (control plane not reachable yet)"
  echo ""
  echo "==> Headlamp: http://${CP_TS_IP}:30080"
else
  echo "==> Control plane not yet on Tailscale"
fi
