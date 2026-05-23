#!/bin/bash
# Reset the demo to pre-update state.
# Removes CoW overlay images so VMs boot fresh from the base image.
# Also tears down the infra pod and restarts it (resets Nebraska state).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG_DIR="${PROJECT_DIR}/artifacts/old-4515"

echo "==> Removing VM working images (resets to pre-update state)"
rm -f "${IMG_DIR}/vm1-work.qcow2"
rm -f "${IMG_DIR}/vm2-work.qcow2"

echo "==> Restarting infrastructure pod (resets Nebraska state)"
"${SCRIPT_DIR}/teardown.sh"
"${SCRIPT_DIR}/start-infra.sh"

echo ""
echo "==> Demo reset complete."
echo "    Nebraska needs the 4628.0.0 package re-registered."
echo "    Run: ${SCRIPT_DIR}/setup-nebraska.sh"
