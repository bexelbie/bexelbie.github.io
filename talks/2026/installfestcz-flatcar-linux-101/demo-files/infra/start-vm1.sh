#!/bin/bash
# Boot Flatcar VM 1 (plain) from the old version image.
# Uses a working copy so the base image stays pristine for reset.
# Uses TAP networking via libvirt bridge (virbr0) for fast host access.
# SSH: ssh core@192.168.122.101  (static IP)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG_DIR="${PROJECT_DIR}/artifacts/old-4515"
IGN="${PROJECT_DIR}/vm1-plain.ign"
WORK_IMG="${IMG_DIR}/vm1-work.qcow2"

if [ ! -f "$IGN" ]; then
  echo "ERROR: Ignition config not found: $IGN"
  exit 1
fi

# Create a working copy of the base image (preserves the original for reset)
if [ ! -f "$WORK_IMG" ]; then
  echo "==> Creating working copy for VM1 (qcow2, ~490M)"
  cp "${IMG_DIR}/flatcar_production_qemu_image.img" "$WORK_IMG"
fi

echo "==> Booting VM1 (plain Flatcar 4515.0.0)"
echo "    Network: virbr0 bridge (192.168.122.0/24)"
echo "    SSH: ssh core@192.168.122.101  (static IP)"
echo "    Stop: Ctrl-A X"
echo ""

exec qemu-system-x86_64 \
  -m 3072 \
  -cpu host \
  -smp 2 \
  -enable-kvm \
  -nographic \
  -drive if=virtio,file="${WORK_IMG}" \
  -fw_cfg name=opt/org.flatcar-linux/config,file="${IGN}" \
  -netdev bridge,id=net0,br=virbr0 \
  -boot order=c \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:fc:01:01,romfile=""
