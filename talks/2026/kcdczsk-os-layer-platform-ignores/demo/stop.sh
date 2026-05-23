#!/bin/bash
# ABOUTME: Tears down all demo Azure resources by deleting the resource group.
# ABOUTME: Also removes the local join-info.env file and Tailscale node registration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

rm -f "${SCRIPT_DIR}/join-info.env"
rm -f "${SCRIPT_DIR}/worker2-create.log"
rm -f "${SCRIPT_DIR}/setup-background.log"
rm -f "${SCRIPT_DIR}/../token"

echo "==> Deleting resource group: ${RESOURCE_GROUP}"
echo "    This will destroy ALL resources in the group."
az group delete --name "${RESOURCE_GROUP}" --yes --no-wait

# Tailscale nodes need manual cleanup
echo ""
echo $'\a'"============================================="
echo "  ACTION REQUIRED: Clean up Tailscale"
echo "============================================="
echo "  Remove 'flatcar-cp' from your Tailscale admin:"
echo "  https://login.tailscale.com/admin/machines"
echo "  (Ephemeral nodes auto-expire, but it may take time)"
echo "============================================="
echo ""

echo "==> Deletion started (async). Resources will be gone in a few minutes."
