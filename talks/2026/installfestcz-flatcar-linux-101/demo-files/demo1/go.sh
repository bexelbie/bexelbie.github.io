#!/bin/bash
# ABOUTME: SSH into the Demo 1 VM at its static IP.
# ABOUTME: Waits for SSH to be ready if the VM is still booting.

IP="192.168.122.103"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519"

# Quick check — if SSH works immediately, connect
if ssh $SSH_OPTS -o ConnectTimeout=2 -o BatchMode=yes core@${IP} true 2>/dev/null; then
  exec ssh $SSH_OPTS core@${IP}
fi

# Otherwise wait for it
echo "Waiting for VM to be ready..."
for i in $(seq 1 60); do
  if ssh $SSH_OPTS -o ConnectTimeout=2 -o BatchMode=yes core@${IP} true 2>/dev/null; then
    exec ssh $SSH_OPTS core@${IP}
  fi
  sleep 1
done

echo "ERROR: VM not reachable at ${IP} after 60s"
exit 1
