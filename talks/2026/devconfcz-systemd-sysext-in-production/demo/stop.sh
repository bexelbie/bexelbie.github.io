#!/bin/bash
# ABOUTME: Stops all running coreos-demo VMs and cleans up TAP devices.
# ABOUTME: Disk overlays in images/ are preserved; delete them manually to reset.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

# Kill VMs via pidfiles — use sudo cat so root-owned pidfiles (QEMU) are readable
for pid_file in "${PID_DIR}"/*.pid; do
  [ -f "${pid_file}" ] || continue
  vm=$(basename "${pid_file}" .pid)
  pid=$(sudo cat "${pid_file}" 2>/dev/null || true)
  [ -n "${pid}" ] || { echo "${vm}: could not read pidfile, skipping"; continue; }
  if sudo kill -0 "${pid}" 2>/dev/null; then
    echo "Stopping ${vm} (PID ${pid})..."
    sudo kill "${pid}"
  else
    echo "${vm} is not running (stale PID ${pid})"
  fi
  sudo rm -f "${pid_file}"
done

# Remove TAP devices
for tap in tap-flatcar-cp tap-w1 tap-w2 tap-w3; do
  if ip link show "${tap}" &>/dev/null; then
    echo "Removing TAP device ${tap}..."
    sudo ip link delete "${tap}" 2>/dev/null || true
  fi
done

echo ""
echo "All VMs stopped."
echo "Disk overlays preserved in ${IMAGES_DIR}/"
echo "To fully reset: rm -f ${IMAGES_DIR}/flatcar-cp.qcow2 ${IMAGES_DIR}/worker-1.qcow2 ${IMAGES_DIR}/worker-2.qcow2 ${IMAGES_DIR}/worker-3.qcow2"
echo "To also clear join info: rm -f ${JOIN_INFO}"
