#!/bin/bash
# ABOUTME: Checks whether the Demo 2 VM is running.
# ABOUTME: Shows process info and basic guest connectivity.

set -euo pipefail

IP="192.168.122.104"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519"

PID=$(pgrep -f "demo2-work.qcow2" || true)

if [ -z "$PID" ]; then
  echo "Demo 2 VM is NOT running."
  exit 1
fi

echo "Demo 2 VM is running (PID: $PID)"

if ssh $SSH_OPTS -o ConnectTimeout=2 -o BatchMode=yes core@${IP} 'echo "  Hostname: $(hostname)"; echo "  Uptime: $(uptime -p)"; systemd-sysext status 2>/dev/null || true' 2>/dev/null; then
  :
else
  echo "  (VM is running but not yet reachable via SSH)"
fi
