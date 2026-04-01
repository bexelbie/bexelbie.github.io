---
marp: true
theme: default
paginate: true
footer: "**Flatcar Linux 101 — Installfest.cz 2026 · www.bexelbie.com · @bexelbie@toot.io**"
---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _footer: "**Installfest.cz March 28, 2026**" -->

# Flatcar Linux 101

## A Hands-Free Server OS

<div style="display: flex; align-items: center; justify-content: center; gap: 60px; margin-top: 20px;">
<img src="qr-bexelbie.png" width="200">
<div style="text-align: left; font-size: 0.85em; line-height: 2;">

Brian "bex" Exelbierd
🌐 www.bexelbie.com
✉️ bex@bexelbie.com
<img src="mastodon-logo.svg" style="height: 1em; vertical-align: middle;"> @bexelbie@toot.io
</div>

<!--
- This talk is about Flatcar Linux
- I'm Brian Exelbierd - worked with Linux for over 20 years
- 10+ years at Red Hat in a variety of roles, now working on upstream and community Linux for Microsoft
- I live in Brno - been in the Czech Republic for over 13 years
- I don't speak great Czech, which is why this talk is in English
- Slides are online at the QR Code and on my website
- Disclaimer: My employer, Microsoft has funded my travel to installfest.cz
-->

---

# What is Flatcar Linux?

A container-optimized Linux distribution

- Made for running containers - focused on doing this and only this well
- Orchestrated: Kubernetes worker nodes, other orchestration systems
- Unorchestrated: Docker Compose, Podman, standalone containers
- Think of the OS itself as being treated like a container image

<!--
- Flatcar is special purpose operating system
- Exclusively for running containers
- Supports both orchestrated and unorchestrated containers
-->

---

# Flatcar is a CNCF Project

![w:500](https://www.cncf.io/wp-content/uploads/2023/04/cncf-main-site-logo.svg)

 CoreOS → Kinvolk → Microsoft → CNCF

<!--
- Flatcar is a community driven, CNCF Stewarded project
- in the Cloud Native Computing Foundation
- This makes it an open vendor-neutral project
- the brand and all assets are CNCF IP
- Flatcar has a long history: CoreOS withContainer Linux
  - Red Hat buys it merges with Atomic
  - Kinvolk takes over the original line
  - Microsoft buys Kinvolk
  - Microsoft donates Flatcar to the CNCF
-->

---

# Functionality, not Features

General-purpose Linux | Flatcar
:--|:--
Choose your shell, desktop, language stack | We choose for you
Manage updates: backports vs. new repos vs. waiting | Whole OS updates atomically
Think about *features*: this version, this package | Think about *functionality*: does it work?
You build the system you want | We deliver a light switch
Components may shift under your feet | Contract: runtime stays the same

<!--
- Defined by functionality not features
- General-purpose Linux gives you a platform for choosing features
  - pick shell, desktop, etc.
- Day 2 the choices continue
  - Upgrade for a new set of feature choices?
  - Add a third-party repo?
  - Backport on to my existing system?
- Flatcar avoids all this choice by promising functionality
  - The OS is one unit released and updated as a single unit - no feature decision making
  - Functionality is a contract that will be maintained
- Flatcar is a light switch
  - when you flip it, the light comes on
  - The type of switch is irrelevant - the functionality matters
- Contract between your workload and the container run time/Machine things like GPU
- Not a contract about the version of software shipped in the host
- Below the line we maintain and do what's best
-->

---

# Provisioned, not Installed

| Install | Provision |
|:--|:--|
| Make choices during setup | Declare what you need up front |
| Interactive process | One declarative configuration |
| Each machine slightly different | Every machine identical |

Same idea as containers: you don't bake config into the image — you write config and apply it at launch.

<!--
- Flatcar is not installed - it is provisioned
- Cloud users provision, most metal and virt users install
- both work everywhere
- Installation
  - Make choices as you assemble the machine
  - Often do two rounds a kickstart like install followed by an Ansible like post-install
  - possibly a third round where you log in and much around
- Provisioning
  - Define the machine specification in a declarative configutation
  - A provisioner marries your config and an OS and gives you a machine
  - fully assembled and ready to go
  - Just like how we run containers
- Config has Sensible defaults, no boilerplate
- Booting with no config works
- Post provisioning mucking around is possible but is an anti-pattern
-->

---

# Immutable by Design

- First boot: provisioned from config. After that: the base OS doesn't change.
- `/usr` is read-only and dm-verity protected
- No individual package updates — the entire OS updates as one unit
- Same config + same base OS = identical machine every time

<!--
- Configuration drift is a non-issue
- Configuration happens one time at first boot and never again
- Run the same provisioning twice get the same system
- /usr is read-only and dm-verity protected
- neither you nor attackers can modify it
- the OS is provisioned as a whole disk image and updated the same way
- No individual parts get updated
- This also means no dependency drift - no "this system took update X but not Y"
- Two machines running the same version are actually identical. Mutable systems mutate. Think about this: if I install Fedora 43 and you install Fedora 43 but I run dnf daily and you run it weekly - we are not running the same packages.
- A node that has been updated is identical to an image deployed fresh at that moment
-->

---

<!-- _class: lead -->

# Demo: Provisioning a Server

<!--
- Demo running on a Lenovo T460S from 2016 — all local, no WiFi needed. Some steps pre-staged to avoid download spinners.  The VM I am going to show is already running for the same reason.
- STEP 1: cat demo1/demo1.bu
  - SSH key
  - Static IP via systemd-networkd
  - Custom web page - loaded from a file
  - nginx container - loaded from a file
  - Updates masked 

- STEP 2: butane --strict --files-dir . demo1.bu
  - Same content

- STEP 3: curl http://192.168.122.103:8000 from the host — show the web page

- STEP 4: docker ps

- STEP 5: sudo touch /usr/test
  - sudo mount -o remount,rw /usr

- STEP 7: sudo dmsetup table | grep verity

- STEP 8: sudo cgpt show /dev/vda | grep -A3 USR
  — show priority/tries/successful flags
-->

---

# A/B Updates

```
┌──────────────┐    ┌──────────────┐
│ Partition A  │    │ Partition B  │
│  (running)   │    │  (staging)   │
└──────────────┘    └──────────────┘
            ↕ reboot ↕
```

- Verified image staged to inactive partition
- Reboot activates the new OS
- Rollback = reboot to old partition
- No intermediate states — it works or it rolls back

<!--
- In-place updates via A/B partitions
- nodes don't get recycled, they get updated
- update agent checks for updates
- Update is downloaded, validated, and written to the inactive partition
- Updates are atomic - no intermediate states
- Reboot to use the update
- Reboot daemon manages strategy
- After reboot, there is a health check OS and Workload
- Health fails -> roll back by rebooting old partition
-->

---

# Channels

```
Alpha → Beta → Stable (+ LTS)
```

- **Alpha**: Fully tested, may have incomplete features. For developers.
- **Beta**: Production-ready. Run as canaries alongside stable.
- **Stable**: Widespread production. Promoted from beta.
- **LTS**: Long-term support track for environments that need slower change.

<!--
- We have multiple update channels
- Not going to read this - they are targeted
- Important all are fully tested
- Not unit tests - over 100+ real e2e tests
- From simple 1 Node to full clusters
- All are great - we recommend stable
- Users are part of our stabilization
- Clusters have beta nodes as a canary - their feedback lets us promote
- You are always getting an O S that has been fully tested.
- This means all the parts are tested against each other, not just tested individually.
- Traditional distributions that are mutable tend to test only at ga, and only for a very narrow set of dependencies installed together
- We have a well define set of tests and test exhaustively
- We test basically every PR and commit (exceptions for docs and small non-code changes)
-->


---

<!-- _class: lead -->

# Demo: systemd-sysext

<!--
- Demo: systemd system extensions
— if /usr is immutable, how do you extend the OS? systsemd system extensions a/k/a/ sysexts.
- This machine has no container runtimes
- STEP 1: cat demo2.bu
  - /etc/extensions/docker-flatcar.raw → /dev/null
  - /etc/extensions/containerd-flatcar.raw → /dev/null
  - Flatcar ships Docker and containerd as system extensions. They're overlaid onto /usr at boot.
  - The system sees /dev/null and skips them. Not masked - literally not there

- STEP 2: docker --version; podman --version

- STEP 3: systemd-sysext status — only oem-qemu loaded

- STEP 4: sudo cp /opt/sysexts/flatcar-podman.raw /var/lib/extensions/
  - I am simulating the download of the sysext for podman
  - Could have been at provisioning

- STEP 5: sudo systemd-sysext refresh
  - This merges in the new extension - could also have been at boot

- STEP 6: podman --version; which podman
  - Tada - podman and where it should be

- STEP 7: sudo rm /var/lib/extensions/flatcar-podman.raw
  - sudo systemd-sysext refresh
  - podman --version → No such file or directory
  - and gone - the path is only known because it is cached in bash

- System extensions let you customize Flatcar without breaking immutability.
- Official extensions come from the release server
- community extensions come from the bakery
- your private extensions come from your infrastructure
-->

---

# Flatcar Runs Everywhere

| Environment | Options |
|:--|:--|
| **Cloud** | Azure, AWS, GCP, and many more |
| **Virtualization** | VMware, VirtualBox, libvirt, QEMU |
| **Bare metal** | PXE / iPXE |

Also: Terraform, Go bindings, Cluster API

<!--
- Flatcar supports a wide range of deployment targets
- All major clouds and many tier2 or tier3 cloud providers
- All favorite virtualization providers
- Bare metal via PXE/iPXE
-->

---

<style scoped>
table { width: 100%; table-layout: fixed; }
td, th { width: 50%; vertical-align: top; font-size: 0.85em; }
</style>

# Try It Today — Get Involved

| Community | Try It Locally |
|:--|:--|
| **flatcar.org** — website & docs | 1. Download the QEMU image from flatcar.org |
| **Chat**: Matrix · CNCF Slack | 2. Write a Butane YAML config |
| **GitHub Discussions** | 3. Transpile: `butane config.bu > config.ign` |
| **Office Hours**: every 2nd Tue, 15:30 UTC | 4. Boot: `./flatcar_production_qemu.sh -i config.ign` |
| **DevSync**: every 4th Tue, 15:30 UTC | |
| **Bug Smash**: last Fri of the month | ~5 minutes to a running system |

<!--
- flatcar.org is website and you can find everything there
- Chat: Matrix channel, also on CNCF Slack
- GitHub Discussions
- Live meetings through out the month
- Europe friendly - most of the maintainers are here
- Try it locally: runs in QEMU, takes about five minutes
-->

---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _footer: "**Installfest.cz March 28, 2026**" -->

# Thank You

**Visit Flatcar** → flatcar.org

<div style="display: flex; align-items: center; justify-content: center; gap: 60px; margin-top: 20px;">
<img src="qr-bexelbie.png" width="200">
<div style="text-align: left; font-size: 0.85em; line-height: 2;">

Brian "bex" Exelbierd
🌐 www.bexelbie.com
✉️ bex@bexelbie.com
<img src="mastodon-logo.svg" style="height: 1em; vertical-align: middle;"> @bexelbie@toot.io

</div>
</div>
<!--
- Thank you
- Slides are online at the QR Code and on my website
- Happy to take questions now or find me in the hallway
- If I can't answer something I'll point you in the right direction
-->

---

<!-- Build Notes:
Build: marp --pptx --html 101-slides.md -o 101-slides.pptx --allow-local-files
QR Code: qrencode -o /Users/bexelbie/repos/blog/bexelbie.github.io/working-notes/qr-bexelbie.png -s 10 -m 2 "https://www.bexelbie.com"
-->
