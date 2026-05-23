DEMO 1 — Flatcar node exploration
  - cat /etc/os-release | grep VERSION_ID
  - touch /usr/test
  - dmsetup table | grep verity
  - do this on worker1

--------------------------------------------------------------------------------

SETUP: Terminal SSH'd into worker-1. Headlamp in browser.
       worker-2 is provisioning in background from previous slide.

- STEP 1: [Terminal] SSH into pre-staged worker
  - ./go.sh flatcar-worker-1
  - cat /etc/os-release | grep VERSION_ID
  - Shows VERSION_ID=4593.2.0
  - "This one string tells me everything about this system."

- STEP 2: [Terminal] Try to write to /usr
  - touch /usr/test
  - "Read-only file system. Let's become root and try"
  - sudo su
  - touch /usr/test
  - "Not permission denied — read-only. Nobody can write here. Not me, not root, not an attacker."

- STEP 3: [Terminal] Show dm-verity
  - dmsetup table | grep verity
  - "Cryptographic verification at the block level.
     Every read from /usr is verified against a hash tree.
     Tamper with a single byte and the system refuses to use it."
  - copy the dmverity output, including prompt for later compare
  - "I am going to copy this so we can compare it to the other node - sadly you can't see the highlight on the project, but I am grabbing the prompt too so you can see the machine name"

- STEP 4: [Headlamp] Check on worker-2
  - flatcar-worker-2 should now appear as Ready
  - go to it and show /etc/os-release VERSION_ID - same system
  - "Same config. Same image. Same userspace. Joined automatically."
  - go back to ssh and show the dmsetup table | grep verity and then copare it with what you pasted with cat > /dev/null
