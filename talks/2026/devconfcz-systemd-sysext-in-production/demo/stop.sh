#!/bin/bash
# ABOUTME: Deletes the ephemeral VMs resource group, preserving infra and storage.
# ABOUTME: Re-run setup.sh to recreate the cluster without re-uploading sysexts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

# Cleanly remove CP from Tailscale before deleting VMs
TS_OUT=$(tailscale status 2>/dev/null || true)
CP_TS_IP=$(echo "${TS_OUT}" | awk '$2 ~ /^flatcar-cp/ {print $1; exit}')
if [ -n "${CP_TS_IP:-}" ]; then
  echo "==> Removing flatcar-cp from Tailscale..."
  timeout 10 ssh ${SSH_OPTS} -o ConnectTimeout=5 -o BatchMode=yes \
    "${ADMIN_USER}@${CP_TS_IP}" 'sudo timeout 8 tailscale logout' 2>/dev/null \
    && echo "    Tailscale logout successful." \
    || echo "    Could not reach CP for logout — Tailscale entry will expire on its own."
fi

echo "==> Deleting VMs resource group: ${AZ_RG_VMS}"
echo "    This will destroy: VNet, NSG, all 4 VMs, OS disks."
echo "    Preserved:         ${AZ_RG_INFRA} (storage account + FCoOS image)"
az group delete --name "${AZ_RG_VMS}" --yes --no-wait

rm -f "${JOIN_INFO}"
rm -f "${TOKEN_FILE}"
rm -f "${SCRIPT_DIR}/setup-background.log"

echo ""
echo "==> Deletion started (async). Resources gone in ~2 minutes."
echo "    Infra RG '${AZ_RG_INFRA}' preserved — run ./setup.sh to recreate cluster."
