#!/bin/bash
# ABOUTME: Boots the Demo 1 VM (provisioning demo) from its pre-staged work image.
# ABOUTME: Creates the work image from the base if it doesn't exist yet.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_IMG="${SCRIPT_DIR}/assets/flatcar_production_qemu_image.img"
WORK_IMG="${SCRIPT_DIR}/assets/demo1-work.qcow2"
IGN="${SCRIPT_DIR}/demo1.ign"

if [ ! -f "$IGN" ]; then
  echo "ERROR: Ignition config not found: $IGN"
  exit 1
fi

# Ensure virbr0 is up
if ! ip link show virbr0 >/dev/null 2>&1; then
  sudo systemctl start libvirtd
  sleep 1
  sudo virsh net-start default 2>/dev/null || true
  sleep 1
fi

if [ ! -f "$WORK_IMG" ]; then
  echo "==> Creating work image (first boot will provision via Ignition)"
  cp "$BASE_IMG" "$WORK_IMG"
fi

echo "==> Booting Demo 1 VM (Flatcar provisioning demo)"

qemu-system-x86_64 \
  -m 3072 \
  -cpu host \
  -smp 2 \
  -enable-kvm \
  -nographic \
  -drive if=virtio,file="${WORK_IMG}" \
  -fw_cfg name=opt/org.flatcar-linux/config,file="${IGN}" \
  -netdev bridge,id=net0,br=virbr0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:fc:03:01,romfile="" \
  -boot order=c \
  -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0 \
  </dev/null >/dev/null 2>&1 &

echo "    PID: $!"
echo "    SSH: ./go.sh  (or ssh core@192.168.122.103)"
echo "    Stop: ./stop.sh"

# Create a tmux session for dual-screen presentation
TMUX_SESSION="demo1"
if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo ""
  echo "    tmux session '$TMUX_SESSION' already exists."
else
  tmux new-session -d -s "$TMUX_SESSION" -c "$SCRIPT_DIR"
  echo ""
  echo "    tmux session '$TMUX_SESSION' created."
fi
echo ""
echo "    Attach with:  tmux attach -t $TMUX_SESSION"
