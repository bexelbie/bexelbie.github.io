#!/bin/bash
# ABOUTME: SSH into the Demo 2 VM, waiting for it to become ready.
# ABOUTME: Uses IdentitiesOnly to avoid SSH agent key exhaustion.

set -euo pipefail

IP="192.168.122.104"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519"

echo "Waiting for Demo 2 VM to accept SSH..."
for i in $(seq 1 30); do
  if ssh $SSH_OPTS -o ConnectTimeout=2 -o BatchMode=yes core@${IP} true 2>/dev/null; then
    echo "Connected!"
    exec ssh $SSH_OPTS core@${IP}
  fi
  sleep 1
done

echo "ERROR: Demo 2 VM did not become reachable within 30s"
exit 1
