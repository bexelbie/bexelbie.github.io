#!/bin/bash
# ABOUTME: Stops the Demo 1 VM via SSH shutdown, with kill as fallback.
# ABOUTME: Finds the process by its disk image path.

set -euo pipefail

IP="192.168.122.103"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519"
TMUX_SESSION="demo1"

cleanup_tmux() {
  if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    tmux kill-session -t "$TMUX_SESSION"
    echo "==> tmux session '$TMUX_SESSION' destroyed."
  fi
}

PID=$(pgrep -f "demo1-work.qcow2" || true)

if [ -z "$PID" ]; then
  echo "Demo 1 VM is not running."
  cleanup_tmux
  exit 0
fi

echo "==> Shutting down Demo 1 VM..."
ssh $SSH_OPTS -o ConnectTimeout=3 -o BatchMode=yes core@${IP} 'sudo shutdown -h now' 2>/dev/null || true

# Wait up to 15s for clean shutdown
for i in $(seq 1 15); do
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "==> Demo 1 VM stopped cleanly."
    cleanup_tmux
    exit 0
  fi
  sleep 1
done

echo "    Clean shutdown timed out, killing process..."
kill "$PID" 2>/dev/null || true
sleep 2
echo "==> Demo 1 VM stopped."
cleanup_tmux
