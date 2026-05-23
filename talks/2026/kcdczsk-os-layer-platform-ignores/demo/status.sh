#!/bin/bash
# ABOUTME: Shows status of demo Azure resources and Kubernetes cluster.
# ABOUTME: Uses Tailscale to reach the control plane (no public IPs).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

echo "==> Azure VMs in ${RESOURCE_GROUP}:"
az vm list \
  --resource-group "${RESOURCE_GROUP}" \
  --show-details \
  --query "[].{Name:name, State:powerState, PrivateIP:privateIps, Size:hardwareProfile.vmSize}" \
  -o table 2>/dev/null || echo "    Resource group not found or no VMs."

echo ""

# Reach control plane via Tailscale
CP_IP=$(tailscale status 2>/dev/null | awk '$2 == "flatcar-cp" {print $1; exit}' || true)

if [ -n "${CP_IP}" ]; then
  echo "==> Kubernetes cluster status (via Tailscale → flatcar-cp):"
  ssh ${SSH_OPTS} -o ConnectTimeout=5 -o BatchMode=yes "${ADMIN_USER}@${CP_IP}" \
    'kubectl get nodes -o wide 2>/dev/null' 2>/dev/null \
    || echo "    Could not reach control plane at ${CP_IP}"
  echo ""
  echo "==> Pods:"
  ssh ${SSH_OPTS} -o ConnectTimeout=5 -o BatchMode=yes "${ADMIN_USER}@${CP_IP}" \
    'kubectl get pods -A --no-headers 2>/dev/null | head -20' 2>/dev/null \
    || true
  echo ""
  echo "==> Headlamp: http://${CP_IP}:30080"
else
  echo "==> Control plane not on Tailscale. Run setup.sh first."
fi
