---
title: "When Do You Pay the Complexity Tax? Four Bets on Immutable Linux"
permalink: /talks/2026/devconfcz-complexity-tax-immutable-linux/
entry_type: proposal
proposal_status: rejected
speaking_event: "DevConf.CZ"
speaking_date: 2026-06-18
speaking_links:
  details: /talks/2026/devconfcz-complexity-tax-immutable-linux/
layout: single
author_profile: true
classes: wide
---

## Submitted to [DevConf.CZ 2026](https://devconf.info/cz/) in Brno, Czech Republic on June 18-19, 2026

## Abstract

Every container-optimized Linux distribution solves the same problem: run containers on minimal, immutable, auto-updating infrastructure. Yet the implementations keep diverging. FCOS/bootc, Flatcar, Bottlerocket, and Talos aren't converging toward one model - they're making fundamentally different architectural bets.

This talk skips the feature matrix. Instead, it asks one question: **when do you pay the complexity tax?** The ecosystem has focused on four choices: Design time, Build time, Boot time, and Run time.

Thilo and bex together have decades of experiences at Red Hat, Amazon, Microsoft and more. Now we work with Flatcar at Microsoft. This talk shares what that vantage point has taught us about why we keep diverging, why convergence isn't coming, and how to choose which tax your organization should pay.

<!--
## Proposed Talk Structure (25 min) — speaker notes

**Opening: "What switching sides taught me" (2 min):** "I spent a decade at Red Hat. Now I work on Flatcar at Microsoft. Here's what I've learned: we keep diverging not because anyone is wrong, but because 'container-optimized Linux' is actually four different philosophies wearing the same label."

**The False Consensus (1 min):** "OCI/registries settled the transport story." Mostly true. But we mistake the truck for the cargo.

**Bet 1: Composition at Design Time (5 min):** The **Talos** model. The OS is firmware. No shell, no SSH, gRPC API only.
- *The tax:* Application architecture. If your app needs a host binary, your app is broken.
- *Example:* You don't "install" GPU tooling. You rebuild via Image Factory or workloads bring what they need.
- *Failure mode:* A legacy dependency assumed a mutable host. Debugging without a shell is genuinely hard.

**Bet 2: Composition at Build Time (3 min):** The **FCOS / bootc** model. bootc is the tech stack; FCOS (and RHEL Image Mode) are the distributions. Both are shipping and production-available today. The OS *is* the container image, baked in CI.
- *The tax:* Image sprawl. Any change is a rebuild-and-rollout.
- *Example:* Bump kubelet? Rebuild the image, roll the fleet.
- *Failure mode:* The matrix explodes faster than your CI pipeline does.
- Acknowledge the strengths honestly (reproducibility, familiar tooling, full RPM dependency resolution).
- *The duality that breaks immutability:* FCOS also still supports the older rpm-ostree runtime model. `rpm-ostree install` adds packages on top of the base image. But crucially, `rpm-ostree override replace` lets you swap out the kernel or any system component with an arbitrary RPM, and `rpm-ostree override remove` strips packages from the base image entirely. These aren't just additive layers - they're arbitrary mutations to the OS. Each creates a new deployment you can roll back from, so it's transactional. But the resulting system is a unique composite: no vendor built it, no vendor tested it, no vendor can reason about it. The immutability promise becomes aspirational - the mechanism to break it is one command away. This is the core tension within FCOS: you have an immutable base image *and* full machinery to mutate it at runtime. bootc is the direction Red Hat is pushing precisely to resolve this: if everything is baked at build time, the image is the contract and there's nothing to override at runtime.

**Bet 3: Composition via API at Run time (5 min):** The **Bottlerocket** model. The OS is an API surface.
- *The tax:* Operational friction. Admin shell is a privileged container via control container (SSM, not SSH).
- *Example:* GPU support and kubelet managed through API surface and host containers, not package installs.
- *Failure mode:* The escape hatch is unfamiliar. During an incident, unfamiliar is expensive.

**Bet 4: Composition at Boot and Run time (5 min):** The **Flatcar** model. One generic base, many personalities via Ignition (at boot) and sysext overlays (at runtime).
- *The key architectural difference from rpm-ostree layering:* sysext overlays read-only SquashFS images onto a read-only `/usr` via overlayfs. Nothing is mutated. The base image is exactly what the vendor shipped. The extension is exactly what the author built. You're composing immutables on top of immutables - the vendor can still reason about what they shipped, and the extension author can still reason about what they built. There is no `override replace` equivalent. You cannot swap kernel packages or strip base components. The system is composable but not arbitrarily mutable.
- *The tax:* Boot-time complexity. The node must assemble itself correctly every time.
- *Example:* Same base OS everywhere. GPU nodes get a driver sysext. K8s nodes get kubelet at the version they need. Swap kubelet without a full OS rollback.
- *Failure mode:* A composition mistake becomes a fleet-wide boot incident.
- *Honest gap:* No dependency resolution. Each sysext must be self-contained. Dynamically linked binaries that assume host libraries create collisions - Flatcar built Flix (library path rewriting) and Flatwrap (mount namespace isolation) to handle this, but the burden is real.
- *Note on the mutable overlay mode:* Flatcar contributed an opt-in mutable overlay mode upstream to systemd (v256). This was *not* needed for Flatcar's `/usr` sysext use case - that remains strictly read-only-on-read-only. It was needed for two other contexts:
  - **systemd-confext** (the `/etc` counterpart to sysext): confext overlays images onto `/etc` the same way sysext overlays onto `/usr`. But on most Linux systems, `/etc` must be writable at runtime - services write PID files, certs get generated, daemons update config. On Flatcar specifically, `/etc` uses an overlay that provides defaults from `/usr` and copies a file to the real `/etc` only when modified. confext needs to layer configuration images on top of this while preserving writability for those runtime writes. Without the mutable mode, merging a confext image would make `/etc` read-only and break everything that expects to write there.
  - **Traditional (mutable) distros wanting to adopt sysext:** On Arch, Debian, Ubuntu, etc., `/usr` is writable because the package manager needs to install there. Merging a sysext on these distros makes `/usr` read-only as a side effect of the overlayfs - which breaks `apt install`, `pacman -S`, etc. The mutable mode routes writes through `/var/lib/extensions.mutable/usr/` so these distros can use sysext without losing package manager writability.
  - **What Flatcar uses in production:** Read-only `/usr` base, read-only sysext SquashFS images, read-only overlayfs result. The mutable mode is upstream infrastructure Flatcar contributed for others. Flatcar's own extension model is immutable end to end.
- Optional: 2-minute pre-recorded demo clip (bakery.sh boot -> merge K8s sysext -> kubelet appears -> unmerge -> vanishes).

**Conclusion: Choose Your Tax (5 min):** These aren't different distros - they're different answers to "What is an OS?" The trust spectrum: FCOS/Flatcar trust the operator. Bottlerocket trusts the API but tolerates the operator. Talos trusts only the code. Divergence is a feature. Know which tax your org is willing to pay--choose deliberately.
-->
