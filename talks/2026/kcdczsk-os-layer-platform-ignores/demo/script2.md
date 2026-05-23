DEMO 2 — OS update with Kubernetes lifecycle
  - Click drain on flatcar-worker-1 node
  - cgpt show /dev/sda | grep -A3 USR
  - cat /etc/os-release | grep VERSION_ID
  - update_engine_client -status
  - reboot
  - sudo cgpt show /dev/sda | grep -A3 USR
  - cat /etc/os-release | grep VERSION_ID
  - Click uncordon on flatcar-worker-1 node and scale up

--------------------------------------------------------------------------------

SETUP: Terminal still SSH'd into worker-1. Headlamp in browser.

- STEP 1: [Headlamp] Drain worker-1
  - Click drain on flatcar-worker-1 node
  - Watch pods migrate to worker-2
  - "Standard Kubernetes drain and cordon. Headlamp makes it visual — pods moving to worker-2."

- STEP 2: [Terminal] Show A/B partition layout BEFORE update
  - sudo su
  - cgpt show /dev/sda | grep -A3 USR
  - Shows USR-A (priority=1, successful=1) and USR-B (priority=2, successful=1)
  - "Two copies of the OS. Right now we're running from USR-A.
     USR-B has the staged update, ready to go."

- STEP 3: [Terminal] Check current version on worker-1
  - cat /etc/os-release | grep VERSION_ID
  - "Reminder - currently 4593.2.0. Let's update."

- STEP 4: [Terminal] Show pre-staged update
  - update_engine_client -status
  - Shows UPDATE_STATUS_UPDATED_NEED_REBOOT
  - "I pre-staged this update before the talk. The new OS image is already
     written to the inactive partition. The running system is untouched.
     This is how it works in production — download happens in the background,
     reboot happens on your schedule."

- STEP 5: [Terminal] Reboot
  - reboot
  - SSH session disconnects
  - "The system is going down, booting the update partition and running health checks.  Were there to be a failure it would stop, reboot and go back to our old partition.  These health checks can include your workloads, not just the OS."
  - Talk about Channels if you need to kill time:
    "Flatcar has channels — stable, LTS, beta, alpha. I'm on stable.
     Every release goes through over 100 end-to-end real-world scenario tests.
     The whole OS is tested as a unit against itself — not individual packages
     passing unit tests."

- STEP 6: [Terminal] SSH back in, verify partition swap
  - ./go.sh flatcar-worker-1 (wait ~30s for reboot)
  - sudo cgpt show /dev/sda | grep -A3 USR
  - USR-B now active (we booted from it), USR-A is the fallback
  - "The partition priorities flipped. We're now on USR-B.
     If anything went wrong, one reboot takes us back to USR-A."

- STEP 7: [Terminal] Verify new version
  - cat /etc/os-release | grep VERSION_ID
  - "New version. The OS updated atomically. The version string changed giving us our new identifier this user space."
  - you can also see hte changed dmverity hash (still in copy buffer)

- STEP 8: [Headlamp] Uncordon worker-1
  - Click uncordon on flatcar-worker-1 node
  - Node goes Ready
  - "Back in service. If this had failed, reboot rolls back to the old partition. Let's scale up our demo workload and show that pods can still run on the system."
