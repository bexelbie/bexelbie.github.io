#!/bin/bash
# ABOUTME: Deletes ALL demo Azure resources including storage and the FCoOS managed image.
# ABOUTME: After this, run prep-infra.sh again before running setup.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

echo "=========================================="
echo "  WARNING: This deletes EVERYTHING"
echo "=========================================="
echo "  VMs RG:    ${AZ_RG_VMS}"
echo "  Infra RG:  ${AZ_RG_INFRA}"
echo "  This includes the storage account with all sysexts and the FCoOS image."
echo "  You will need to run prep-infra.sh again before running setup.sh."
echo "=========================================="
echo ""
read -r -p "Type 'yes' to confirm: " CONFIRM
[ "${CONFIRM}" = "yes" ] || { echo "Aborted."; exit 1; }

echo "==> Deleting VMs resource group: ${AZ_RG_VMS}"
az group delete --name "${AZ_RG_VMS}" --yes --no-wait 2>/dev/null || true

echo "==> Deleting infra resource group: ${AZ_RG_INFRA}"
az group delete --name "${AZ_RG_INFRA}" --yes --no-wait 2>/dev/null || true

rm -f "${JOIN_INFO}"
rm -f "${TOKEN_FILE}"
rm -f "${SCRIPT_DIR}/setup-background.log"

echo ""
echo $'\a'"============================================="
echo "  ACTION REQUIRED: Clean up Tailscale"
echo "============================================="
echo "  Remove 'flatcar-cp' from: https://login.tailscale.com/admin/machines"
echo "============================================="
echo ""
echo "==> Both resource groups deletion started (async)."
echo "    All resources — VMs, storage, FCoOS image — will be gone in a few minutes."
