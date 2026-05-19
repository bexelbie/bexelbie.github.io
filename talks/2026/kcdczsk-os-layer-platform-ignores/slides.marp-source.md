---
marp: true
theme: default
paginate: true
footer: "**The OS Layer Your Platform Ignores — KCD Czech & Slovak 2026 · www.bexelbie.com · @bexelbie@toot.io**"
---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _footer: "**KCD Czech & Slovak · Prague · 21 May 2026**" -->

# The OS Layer Your Platform Ignores

## Immutable nodes for Kubernetes

<div style="display: flex; align-items: center; justify-content: center; gap: 60px; margin-top: 20px;">
<img src="qr-bexelbie.png" width="200">
<div style="text-align: left; font-size: 0.85em; line-height: 2;">

Brian "bex" Exelbierd
Principal Product Manager, Microsoft Azure
🌐 www.bexelbie.com
✉️  bex@bexelbie.com
✉️  bexelbierd@microsoft.com
<img src="mastodon-logo.svg" style="height: 1em; vertical-align: middle;"> @bexelbie@toot.io
</div>

<!--

Regen QR Code!

- Linux for 20+ years
- Microsoft Azure doing Upstream Linux
- Using Azure today because that's what I have
- Works on AWS, GCP, bare metal, or this 2017 laptop in front of me
- Linux guy, not a Kubernetes guy
- Vanilla kubeadm - no special sauce
- Using Headlamp
- Errors in Kube are mine
- Slides at the QR code and on my website
-->

---

# You have 100 Kubernetes nodes.

# Can you prove their filesystems match?

<!--
- This is the question
- Most people can't answer this correctly
- Edge cases make most wrong
- Let me explain why.
-->

---

# Mutable systems drift

- Nodes at different lifecycle stages get updates at different times
- Package upgrade ordering varies across a fleet
  - Node A got update X before Y; Node B got Y before X → different state
- Debug sessions leave artifacts: tcpdump, strace, hot-patched binaries
- Debug artifacts and daemonset writes fill disks, blow quotas

<!--
- We use mutable nodes under Kube
- Mutable nodes ... mutate
- Old nodes differ from new nodes
- Mutable systems are non-deterministic at scale
- The order of package installations matters
- This is why enterprise Linux getting rid of scriptlets
- Perfect with Gold images and Infra as Code?
- Engineers SSH in to debug problems and leave things behind.
- Logs or dumps that create disk issues
- Replaced binaries that haven't been CI'ed
-->

---

# The divergence is invisible

Two nodes report the same kernel and OS version.

Their userspace has diverged.

**You can't tell from the outside.**

<!--
- Divergence is invisible
- Same kernel, same OS version string, same kubelet version
- Still different
- package-level/file-level audit of every node
- At 100 nodes? 1000? continuously?
- Start from same base .. day 2 is different from Day 1
-->

---

# Kubernetes can't check this

Kubernetes solves **orchestration**, not **OS integrity**.

- It knows: is the node Ready? Is kubelet responding?
- It doesn't know: what's on the filesystem. What changed since last boot.
- Node replacement from the "same image" doesn't help — mutable images mutate.

<!--
- This isn't a Kube problem
- Kubernetes is great at managing workloads
- Zero visibility into the node OS
- kubelet health check tells alive, workload ready
- NOT correct/consistent
- from where you look, nodes look identical
-->

---

<!-- _class: lead -->

# "Shift Down"

<!--
- So what do we do about this?
- Kubernetes Security community described "Shift Down"
- "Shift Left" — move security earlier in the pipeline
- "Shift Down" push security guarantees deeper into the platform
- The white paper talks about embedding security policies deeper into Kubernetes
- I'm taking it one step further:
- push it into the node os
-->

---

# You secured your container images.

## What about the node they run on?

- SLSA, Sigstore, SBOMs → container supply chain ✓
- But the node runs a **mutable filesystem**
- Detecting drift ≠ preventing drift
- What if drift were **structurally impossible**?

<!--
- We have history here
- CNCF ecosystem has done amazing work on container image supply chain
- SLSA levels, Sigstore for signing, SBOMs for transparency
- But this is above Kube - in the workload
- Most drift defenses detect changes after the fact
- detection is not prevention
- What if we made it so drift COULDN'T happen?
- Push integrity into the platform
-->

---

# Flatcar Container Linux

A container-optimized, immutable Linux distribution

- **CNCF Incubating** project (CoreOS → Kinvolk → Microsoft → CNCF)
- Made for one thing: running containers reliably
- The OS itself is treated like a container image
- A **functionality contract**: you define what you need, Flatcar delivers and maintains it

<!--
- Flatcar is a special-purpose OS. It runs containers. That's it.
- It's a CNCF project — vendor-neutral, community-governed.
- The brand, the assets, the IP — all CNCF.
- Incubating doesn't tell the whole story
- Long lineage: CoreOS made concepts from ChromiumOS into Container Linux
- Red Hat bought CoreOS and changed the tech
- Kinvolk forked and continued it as Flatcar
- Microsoft acquired Kinvolk and donated Flatcar to CNCF.
-->

---

# Immutable by design

| | Mutable OS | Flatcar |
|:--|:--|:--|
| `/usr` | Read-write, anyone can change it | **Read-only**, dm-verity protected |
| Updates | Individual packages, any order | Entire OS atomically, as one unit |
| Verification | Package-level audit | VERSION_ID + sysext list = full identity |
| After reboot | Same node, new mysteries | Cryptographically verified identical userspace |

<!--
- /usr is read-only and dm-verity protected
- dm-verity means cryptographic hash verification at the block level
- Every block is verified against a hash at read
- If anything has been tampered with — it won't run
- Not "alert" — won't execute.
- Not even a cosmic bit-flip gets through.
- There is no package manager. You cannot install something on /usr
- Updates are atomic, deterministic
- more to come on updates and adding software
- Two checks give you full userspace identity:
- VERSION_ID and a similar string for added software
  Together, these tell you the complete userspace state
- /etc is still writable — more to come
- This is the "Shift Down" made concrete and pushed deeper
- Userspace drift isn't detected — it's impossible
-->

---

# Demo: Provision & Prove Immutability
## What we're provisioning

```yaml
# Butane config → transpiled to Ignition JSON
variant: flatcar
version: 1.0.0
storage:
  files:
    - path: /opt/extensions/kubernetes/kubernetes-v1.33.2-x86-64.raw
      contents:
        source: https://extensions.flatcar.org/...
  links:
    - path: /etc/extensions/kubernetes.raw
      target: /opt/extensions/kubernetes/kubernetes-v1.33.2-x86-64.raw
systemd:
  units:
    - name: kubeadm.service
      enabled: true
      contents: |
        ...
        ExecStart=/usr/bin/kubeadm join <control-plane>:6443 --token ...
```

<!--
- Flatcar is an OS you deploy, not configure
- This Butane yaml defines the contract between workload and OS
- transpile to json and deploy on your platform of choice
- we provide a system that meets this contract
- This is a simplified view of the Butane config I am using.
- SSH key, kubernetes sysext, kubeadm join command.
- One declarative file. Same file = same machine. Every time.
-->

---

# Demo: Provision & Prove Immutability
## Deploying on Azure

```bash
az vm create \
  --resource-group kcd-flatcar-demo \
  --name flatcar-worker-2 \
  --image kinvolk:flatcar-container-linux-free:stable-gen2:4593.2.0 \
  --size Standard_B2ms \
  --admin-username core \
  --custom-data worker.ign
```

Same command. Same image. Same config. Same result.

<!--
- This is the Azure CLI command.
- One command, one config file.
- --custom-data passes our Ignition JSON. Flatcar reads it on first boot.
- I'll add a worker to an existing cluster
- bring up workload on it
- prove it is identical to an existing worker
- flip to headlamp
-->

---

<!-- _class: lead -->

# [Live demo on pre-staged node]

---

# A/B Partition Updates

```
┌──────────────┐    ┌──────────────┐
│ Partition A  │    │ Partition B  │
│  (running)   │    │  (staging)   │
└──────────────┘    └──────────────┘
            ↕ reboot ↕
```

- Update image written to inactive partition — running system untouched
- Reboot activates the new OS
- Rollback = reboot to old partition
- **No intermediate states** — it works or it rolls back

<!--
- Flatcar doesn't do in-place package updates
- The entire OS is downloaded, verified image and written
- While this happens, the running system is completely untouched
- any problems, no change in run time system
- Reboot swaps to the new partition. Health check runs.
- If it fails, next reboot goes back to the old partition
- In Kubernetes context: drain the node, update, reboot, rejoin, uncordon.
- FLUO (Flatcar Linux Update Operator) or Kured or whatever comes next automate this across a fleet.
- Respects your policies and rules
-->

---

<!-- _class: lead -->

# Demo: OS Update with Kubernetes Lifecycle

---

# systemd-sysext: Extend Without Breaking

How do you add software to an immutable OS?

- **System extensions** overlay files onto `/usr` at runtime
- Immutable images — composable, versioned, independently updatable
- Three tiers:
  - **Official (shipped)**: containerd, Docker, OEM tools — part of the base image
  - **Official (opt-in)**: NVIDIA drivers, Python, ZFS — enable in config
  - **Community (bakery)**: kubernetes, tailscale, nvidia-runtime — from extensions.flatcar.org

<!--
- If /usr is read-only, how do you add anything?
- systemd-sysext provides an overlay mechanism.
  Think of it like a container layer — but for the OS.
- Each sysext is a self-contained, immutable image (usually squashfs).
  It overlays its contents onto /usr at boot.
- Three tiers of sysexts:         
  - opt out - shipped in image
  - opt in - shipped from our repos
  - community - bakery - tailscale, kube
- On THIS cluster, kubelet came from a community sysext.
- sysext images have the same supply chain guarantees
- Versioned, verifiable, immutable.
- Nothing is "installed." Everything is composed.
-->

---

# Component lifecycle with sysupdate

Each sysext has its own update track — independent of the OS

```ini
# /etc/sysupdate.kubernetes.d/kubernetes-v1.33.transfer
[Source]
Type=url-file
Path=https://extensions.flatcar.org/extensions/kubernetes/
MatchPattern=kubernetes-v1.33.@v-%a.raw

[Target]
Path=/opt/extensions/kubernetes
MatchPattern=kubernetes-v1.33.@v-%a.raw
CurrentSymlink=/etc/extensions/kubernetes.raw
```

- `systemd-sysupdate` checks for new patch versions on a timer
- Downloads the new sysext image, updates the symlink
- Same atomic pattern as the OS — but per component

<!--
- This is the config
- look for kubernetes v1.33 patch releases at this URL
- Match on z streams in this case
- downloads the new sysext image next to old one
- flips the symlink like flipping partitions
- Unlike with the os, no reboot required
-->

---

<!-- _class: lead -->

# Demo: Kubelet Sysext Upgrade

---

# What this gives your platform team

- **Provable userspace**: VERSION_ID proves `/usr` (dm-verity). Sysext symlinks prove components. Two checks, full identity.
- **Supply chain integrity**: Boot → OS → sysexts → workload. All verified.
- **At scale today** (not future promises):
  - **Cluster API** provisions Flatcar node fleets — same Ignition mechanism, automated
  - **FLUO / Kured** coordinates rolling OS updates across the cluster
  - **systemd-sysupdate** keeps sysext versions current automatically
- **Next**: `systemd-confext` brings the same overlay pattern to `/etc` — immutable config

<!--
- This isn't a research project
- These tools are current, maintained, and in production.
- Cluster API standard
- What I showed you by hand today — done by Kube tooling
- FLUO and Kured watch for update_engine's "reboot needed" signal,
- drain the node, reboot it, and uncordon it — automatically.
- Follow your node policy
- We are working on making /etc/ the same
- confext: today /usr is immutable but /etc is still writable.
- systemd-confext will bring the same overlay model to /etc —
- Your implementation will vary based on your needs
-->

---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _footer: "**KCD Czech & Slovak · Prague · 21 May 2026**" -->

# Thank You

**Visit Flatcar** → flatcar.org

<div style="display: flex; align-items: center; justify-content: center; gap: 60px; margin-top: 20px;">
<img src="qr-bexelbie.png" width="200">
<div style="text-align: left; font-size: 0.85em; line-height: 2;">

Brian "bex" Exelbierd
Principal Product Manager, Microsoft Azure
🌐 www.bexelbie.com
✉️ bex@bexelbie.com
✉️  bexelbierd@microsoft.com
<img src="mastodon-logo.svg" style="height: 1em; vertical-align: middle;"> @bexelbie@toot.io

</div>
</div>

<!--
- Thank you
- Flatcar: flatcar.org — docs, community, everything
- Chat: Matrix channel, CNCF Slack (#flatcar)
- Office Hours: every 2nd Wednesday, 14:30 UTC — Europe-friendly
- Slides online at the QR code and my website
- Happy to take questions now or find me in the hallway
-->

---

<!-- Build Notes:
Build: marp --pptx --html slides.md -o slides.pptx --allow-local-files
QR Code: qrencode -o qr-bexelbie.png -s 10 -m 2 "https://www.bexelbie.com"
-->
