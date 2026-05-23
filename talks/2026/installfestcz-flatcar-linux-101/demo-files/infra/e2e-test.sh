#!/bin/bash
# End-to-end test of the full Flatcar 101 demo.
# Runs everything from clean slate: infra, Nebraska, VM1 update, VM2 sysext.
# Exit on first failure.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG_DIR="${PROJECT_DIR}/artifacts/old-4515"
BASE_IMG="${IMG_DIR}/flatcar_production_qemu_image.img"

VM1_IP="192.168.122.101"
VM2_IP="192.168.122.102"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes -o LogLevel=ERROR -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519"

PASS=0
FAIL=0
TESTS=()
E2E_START=$(date +%s)

ts() { local now=$(date +%s); printf "[%3ds] " $((now - E2E_START)); }
pass() { PASS=$((PASS+1)); TESTS+=("✅ $1"); echo "$(ts)✅ $1"; }
fail() { FAIL=$((FAIL+1)); TESTS+=("❌ $1"); echo "$(ts)❌ $1"; }
check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; return 1; fi
}
banner() { echo ""; echo "$(ts)======================================"; echo "  $1"; echo "======================================"; }

cleanup_vms() {
  # Kill any QEMU VMs we started
  for pid in $VM1_PID $VM2_PID; do
    if [ "$pid" != "0" ] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
}

VM1_PID=0
VM2_PID=0
trap cleanup_vms EXIT

wait_for_ssh() {
  local ip="$1" max="${2:-60}"
  for i in $(seq 1 "$max"); do
    if ssh $SSH_OPTS -o ConnectTimeout=2 core@"$ip" true 2>/dev/null; then
      return 0
    fi
    sleep 1
  done
  return 1
}

# ============================================================
banner "Phase 1: Clean slate"
# ============================================================

echo "$(ts)==> Tearing down old infra..."
bash "$SCRIPT_DIR/teardown.sh" 2>/dev/null || true
rm -f "${IMG_DIR}/vm1-work.qcow2" "${IMG_DIR}/vm2-work.qcow2"
echo "$(ts)==> Clean."

# ============================================================
banner "Phase 2: Infrastructure"
# ============================================================

echo "$(ts)==> Starting infra pod..."
bash "$SCRIPT_DIR/start-infra.sh" >/dev/null 2>&1
check "Infra pod running" podman pod exists flatcar-infra

echo "$(ts)==> Registering Nebraska package..."
bash "$SCRIPT_DIR/setup-nebraska.sh" >/dev/null 2>&1
check "Nebraska health" curl -4 -sf http://localhost:8000/health

echo "$(ts)==> Verifying nginx serves payloads..."
check "nginx payload" curl -4 -sf http://localhost:8080/payload/flatcar_production_update.gz -o /dev/null
check "nginx tailscale old" curl -4 -sf http://localhost:8080/sysext/tailscale-1.70.0-x86-64.raw -o /dev/null
check "nginx tailscale new" curl -4 -sf http://localhost:8080/sysext/tailscale-1.76.6-x86-64.raw -o /dev/null
check "nginx oem-qemu" curl -4 -sf http://localhost:8080/payload/oem-qemu.gz -o /dev/null

echo "$(ts)==> Verifying Omaha response..."
OMAHA=$(curl -4 -s -X POST "http://localhost:8000/v1/update/" \
  -H 'Content-Type: application/xml' \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" version="Flatcar-4515.0.0" updaterversion="0.4.7.1" installsource="scheduler" ismachine="1">
  <os version="Chateau" platform="CoreOS" sp="4515.0.0_x86_64"></os>
  <app appid="{e96281a6-d1af-4bde-9a0a-97b76e56dc57}" version="4515.0.0" track="stable" bootid="{test}" machineid="test" lang="en-US" hardware_class="" delta_okay="false">
    <updatecheck></updatecheck>
  </app>
</request>')
if echo "$OMAHA" | grep -q "192.168.122.1:8080/payload/"; then
  pass "Omaha returns local payload URL"
else
  fail "Omaha returns local payload URL"
fi

# ============================================================
banner "Phase 3: VM1 — OS update (4515.0.0 → 4628.0.0)"
# ============================================================

echo "$(ts)==> Creating VM1 working image..."
cp "${BASE_IMG}" "${IMG_DIR}/vm1-work.qcow2"

echo "$(ts)==> Booting VM1..."
VM1_BOOT_START=$(date +%s)
qemu-system-x86_64 \
  -m 3072 -cpu host -smp 2 -enable-kvm -nographic \
  -drive if=virtio,file="${IMG_DIR}/vm1-work.qcow2" \
  -fw_cfg name=opt/org.flatcar-linux/config,file="${PROJECT_DIR}/vm1-plain.ign" \
  -netdev bridge,id=net0,br=virbr0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:fc:01:01,romfile="" \
  -boot order=c \
  -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0 \
  </dev/null >/dev/null 2>&1 &
VM1_PID=$!

echo "$(ts)==> Waiting for VM1 to boot (up to 90s)..."
if wait_for_ssh "$VM1_IP" 90; then
  VM1_BOOT_SECS=$(( $(date +%s) - VM1_BOOT_START ))
  pass "VM1 SSH reachable ($VM1_IP) [boot: ${VM1_BOOT_SECS}s]"
else
  fail "VM1 SSH reachable ($VM1_IP)"
  echo "FATAL: Cannot continue VM1 tests"
fi

if ssh $SSH_OPTS core@${VM1_IP} true 2>/dev/null; then
  SSH1="ssh $SSH_OPTS core@${VM1_IP}"

  VM1_VER=$($SSH1 'source /etc/os-release && echo $VERSION_ID' 2>/dev/null)
  if [ "$VM1_VER" = "4515.0.0" ]; then pass "VM1 boots 4515.0.0"; else fail "VM1 boots 4515.0.0 (got: $VM1_VER)"; fi

  VM1_HOST=$($SSH1 'hostname' 2>/dev/null)
  if [ "$VM1_HOST" = "flatcar-vm1" ]; then pass "VM1 hostname set by Ignition"; else fail "VM1 hostname (got: $VM1_HOST)"; fi

  VM1_DOCKER=$($SSH1 'docker version --format "{{.Server.Version}}" 2>/dev/null' || echo "none")
  if [ "$VM1_DOCKER" != "none" ]; then pass "VM1 has Docker"; else fail "VM1 has Docker"; fi

  echo "$(ts)==> Triggering OS update on VM1..."
  UPDATE_START=$(date +%s)
  $SSH1 'sudo update_engine_client -update 2>&1' &
  UPDATE_PID=$!

  # Poll for completion (up to 120s)
  UPDATE_OK=false
  for i in $(seq 1 60); do
    OP=$($SSH1 'update_engine_client -status 2>/dev/null | grep CURRENT_OP | cut -d= -f2' 2>/dev/null || echo "")
    if echo "$OP" | grep -q "NEED_REBOOT"; then
      UPDATE_OK=true
      break
    fi
    sleep 2
  done
  wait $UPDATE_PID 2>/dev/null || true

  if $UPDATE_OK; then
    UPDATE_SECS=$(( $(date +%s) - UPDATE_START ))
    pass "VM1 update downloaded and finalized [${UPDATE_SECS}s]"
  else
    fail "VM1 update downloaded and finalized"
    echo "$(ts)==> DIAGNOSTICS: capturing update_engine state..."
    $SSH1 'echo "--- /boot usage ---"; df -h /boot; echo "--- /boot contents ---"; ls -lh /boot/; echo "--- cgpt show ---"; sudo cgpt show /dev/vda 2>/dev/null; echo "--- update_engine journal (last 50) ---"; journalctl -u update-engine --no-pager -n 50 2>/dev/null; echo "--- update_engine status ---"; update_engine_client -status 2>/dev/null' 2>/dev/null || echo "(diagnostics failed)"
  fi

  echo "$(ts)==> Rebooting VM1..."
  REBOOT_START=$(date +%s)
  $SSH1 'sudo reboot' 2>/dev/null || true
  sleep 10

  # Wait for VM1 to come back at same static IP
  if wait_for_ssh "$VM1_IP" 60; then
    REBOOT_SECS=$(( $(date +%s) - REBOOT_START ))
    VM1_VER=$($SSH1 'source /etc/os-release && echo $VERSION_ID' 2>/dev/null)
    if [ "$VM1_VER" = "4628.0.0" ]; then pass "VM1 rebooted into 4628.0.0 [reboot: ${REBOOT_SECS}s]"; else fail "VM1 rebooted into 4628.0.0 (got: $VM1_VER)"; fi
  else
    fail "VM1 reachable after reboot"
  fi
fi

echo "$(ts)==> Shutting down VM1..."
if kill -0 "$VM1_PID" 2>/dev/null; then
  kill "$VM1_PID" 2>/dev/null || true
  wait "$VM1_PID" 2>/dev/null || true
fi
VM1_PID=0

# ============================================================
banner "Phase 4: VM2 — Sysext (Podman + Tailscale update)"
# ============================================================

echo "$(ts)==> Creating VM2 working image..."
cp "${BASE_IMG}" "${IMG_DIR}/vm2-work.qcow2"

echo "$(ts)==> Booting VM2..."
VM2_BOOT_START=$(date +%s)
qemu-system-x86_64 \
  -m 3072 -cpu host -smp 2 -enable-kvm -nographic \
  -drive if=virtio,file="${IMG_DIR}/vm2-work.qcow2" \
  -fw_cfg name=opt/org.flatcar-linux/config,file="${PROJECT_DIR}/vm2-sysext.ign" \
  -netdev bridge,id=net0,br=virbr0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:fc:02:01,romfile="" \
  -boot order=c \
  -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0 \
  </dev/null >/dev/null 2>&1 &
VM2_PID=$!

echo "$(ts)==> Waiting for VM2 to boot (up to 120s — downloads sysexts)..."
if wait_for_ssh "$VM2_IP" 120; then
  VM2_BOOT_SECS=$(( $(date +%s) - VM2_BOOT_START ))
  pass "VM2 SSH reachable ($VM2_IP) [boot: ${VM2_BOOT_SECS}s]"
else
  fail "VM2 SSH reachable ($VM2_IP)"
  echo "$(ts)==> DIAGNOSTICS: checking if VM2 is reachable at any IP..."
  ping -c1 -W1 192.168.122.102 >/dev/null 2>&1 && echo "  ping .102: OK" || echo "  ping .102: FAILED"
  sudo virsh net-dhcp-leases default 2>/dev/null | grep "fc:02:01" | tail -3
  # Try DHCP IPs in case static config didn't apply
  for ip in $(sudo virsh net-dhcp-leases default 2>/dev/null | grep "fc:02:01" | grep -oP '192\.168\.122\.\d+' | sort -u | tail -3); do
    if ssh $SSH_OPTS -o ConnectTimeout=3 core@$ip 'echo "VM2 FOUND at '$ip'"; ip addr show eth0 | grep "inet "; ls /etc/systemd/network/; journalctl -u ignition-files --no-pager -n 20 2>/dev/null' 2>/dev/null; then
      break
    fi
  done
  echo "FATAL: Cannot continue VM2 tests"
fi

if ssh $SSH_OPTS core@${VM2_IP} true 2>/dev/null; then
  SSH2="ssh $SSH_OPTS core@${VM2_IP}"

  VM2_VER=$($SSH2 'source /etc/os-release && echo $VERSION_ID' 2>/dev/null)
  if [ "$VM2_VER" = "4515.0.0" ]; then pass "VM2 boots 4515.0.0"; else fail "VM2 boots 4515.0.0 (got: $VM2_VER)"; fi

  VM2_HOST=$($SSH2 'hostname' 2>/dev/null)
  if [ "$VM2_HOST" = "flatcar-vm2" ]; then pass "VM2 hostname set by Ignition"; else fail "VM2 hostname (got: $VM2_HOST)"; fi

  # Docker should be nulled out
  VM2_DOCKER=$($SSH2 'docker version 2>&1' && echo "found" || echo "not-found")
  if echo "$VM2_DOCKER" | grep -q "not-found"; then pass "VM2 Docker nulled out"; else fail "VM2 Docker nulled out"; fi

  # Podman should be active
  VM2_PODMAN=$($SSH2 'podman --version 2>/dev/null' || echo "none")
  if echo "$VM2_PODMAN" | grep -q "podman version"; then pass "VM2 Podman active ($VM2_PODMAN)"; else fail "VM2 Podman active (got: $VM2_PODMAN)"; fi

  # Tailscale should be 1.70.0
  VM2_TS=$($SSH2 '/usr/local/bin/tailscale version 2>/dev/null | head -1' || echo "none")
  if [ "$VM2_TS" = "1.70.0" ]; then pass "VM2 Tailscale 1.70.0 loaded"; else fail "VM2 Tailscale 1.70.0 (got: $VM2_TS)"; fi

  # Timer should be active
  VM2_TIMER=$($SSH2 'systemctl is-active sysupdate-tailscale.timer 2>/dev/null' || echo "none")
  if [ "$VM2_TIMER" = "active" ]; then pass "VM2 sysupdate timer active"; else fail "VM2 sysupdate timer (got: $VM2_TIMER)"; fi

  # Sysext status should show podman + tailscale
  VM2_SYSEXT=$($SSH2 'systemd-sysext status 2>/dev/null')
  if echo "$VM2_SYSEXT" | grep -q "flatcar-podman"; then pass "VM2 sysext: flatcar-podman"; else fail "VM2 sysext: flatcar-podman"; fi
  if echo "$VM2_SYSEXT" | grep -q "tailscale"; then pass "VM2 sysext: tailscale"; else fail "VM2 sysext: tailscale"; fi

  # Trigger sysext update
  echo "$(ts)==> Updating Tailscale sysext on VM2..."
  SYSUPDATE_START=$(date +%s)
  $SSH2 'sudo systemctl start sysupdate-tailscale.service' 2>/dev/null
  UPDATE_RC=$?
  if [ "$UPDATE_RC" -eq 0 ]; then
    SYSUPDATE_SECS=$(( $(date +%s) - SYSUPDATE_START ))
    pass "VM2 sysupdate-tailscale.service ran [${SYSUPDATE_SECS}s]"
  else
    fail "VM2 sysupdate-tailscale.service ran"
  fi

  VM2_TS2=$($SSH2 '/usr/local/bin/tailscale version 2>/dev/null | head -1' || echo "none")
  if [ "$VM2_TS2" = "1.76.6" ]; then pass "VM2 Tailscale updated to 1.76.6"; else fail "VM2 Tailscale updated (got: $VM2_TS2)"; fi

  # Podman should still work after sysext refresh
  VM2_PODMAN2=$($SSH2 'podman --version 2>/dev/null' || echo "none")
  if echo "$VM2_PODMAN2" | grep -q "podman version"; then pass "VM2 Podman still works after refresh"; else fail "VM2 Podman after refresh (got: $VM2_PODMAN2)"; fi
fi

echo "$(ts)==> Shutting down VM2..."
if kill -0 "$VM2_PID" 2>/dev/null; then
  kill "$VM2_PID" 2>/dev/null || true
  wait "$VM2_PID" 2>/dev/null || true
fi
VM2_PID=0

# ============================================================
banner "Phase 5: Reset and verify repeatable"
# ============================================================

echo "$(ts)==> Running reset-demo.sh..."
bash "$SCRIPT_DIR/reset-demo.sh" >/dev/null 2>&1
check "Reset: infra pod running" podman pod exists flatcar-infra
check "Reset: VM1 image removed" test ! -f "${IMG_DIR}/vm1-work.qcow2"
check "Reset: VM2 image removed" test ! -f "${IMG_DIR}/vm2-work.qcow2"

echo "$(ts)==> Re-registering Nebraska..."
bash "$SCRIPT_DIR/setup-nebraska.sh" >/dev/null 2>&1
check "Reset: Nebraska health" curl -4 -sf http://localhost:8000/health

# ============================================================
banner "RESULTS"
# ============================================================

echo ""
E2E_SECS=$(( $(date +%s) - E2E_START ))
E2E_MIN=$(( E2E_SECS / 60 ))
E2E_REM=$(( E2E_SECS % 60 ))
for t in "${TESTS[@]}"; do
  echo "  $t"
done
echo ""
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "  Total:  $((PASS+FAIL))"
echo "  Elapsed: ${E2E_MIN}m ${E2E_REM}s"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "❌ E2E TEST FAILED"
  exit 1
else
  echo "✅ ALL TESTS PASSED"
  exit 0
fi
