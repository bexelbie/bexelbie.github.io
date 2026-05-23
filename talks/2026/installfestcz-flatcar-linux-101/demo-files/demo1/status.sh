#!/bin/bash
# ABOUTME: Shows whether the Demo 1 VM is running and basic status info.
# ABOUTME: If running, shows QEMU process details and tries SSH for guest info.

IP="192.168.122.103"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519 -o BatchMode=yes -o ConnectTimeout=2"

PID=$(pgrep -f "demo1-work.qcow2" || true)

if [ -z "$PID" ]; then
  echo "Demo 1 VM is not running."
  exit 0
fi

echo "==> Demo 1 VM is running (PID $PID)"
echo ""
echo "--- QEMU process ---"
ps -p "$PID" -o pid,vsz=MEM_KB,rss=RSS_KB,etime=ELAPSED,args --no-headers
echo ""

if ssh $SSH_OPTS core@${IP} true 2>/dev/null; then
  echo "--- Guest status ---"
  ssh $SSH_OPTS core@${IP} '
    echo "Hostname: $(hostname)"
    echo "Uptime:  $(uptime -p)"
    echo "Version: $(source /etc/os-release && echo $VERSION_ID)"
    echo ""
    echo "--- docker ps ---"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
  ' 2>/dev/null
else
  echo "--- Guest status ---"
  echo "SSH not reachable at ${IP} (VM may still be booting)"
fi
