---
title: "systemd-sysext in Production: What We Learned Extending /usr Without a Package Manager"
permalink: /talks/2026/devconfcz-systemd-sysext-in-production/
entry_type: proposal
proposal_status: submitted
speaking_event: "DevConf.CZ"
speaking_date: 2026-06-18
speaking_links:
  details: /talks/2026/devconfcz-systemd-sysext-in-production/
layout: single
author_profile: true
classes: wide
---

## Submitted to [DevConf.CZ 2026](https://devconf.info/cz/) in Brno, Czech Republic on June 18-19, 2026

## Abstract

systemd-sysext is a standard mechanism for overlaying `/usr` on any systemd-based OS. The spec and tooling exists, but what happens when you push it past "hello world" into production software - GPU drivers, Kubernetes, container runtimes?

Flatcar Container Linux has been shipping all of these as sysext images since 2022. Docker and containerd don't exist as binaries in the base OS - they're sysext images. Kubernetes can upgrade independently of the OS via sysext + sysupdate.

This talk covers what broke, what we fixed, and what we contributed upstream to systemd. You'll see the two hardest engineering problems - dynamic linking collisions and library path isolation - and the open source tools (Flix and Flatwrap) that solve them. We'll discuss when sysext is the right tool and when rpm-ostree is better.

Whether you work on FCOS, Flatcar, or any other systemd-based distro, sysext is already in your systemd. This talk tells you what to expect when you use it for real.

<!--
## Proposed Talk Structure (25 min) — speaker notes

**sysext is a systemd mechanism, not a Flatcar feature (3 min):** Poettering's "Fitting Everything Together" describes sysext as the standard way to extend `/usr` on immutable hosts. It's in every modern systemd. The question isn't whether your distro supports it - it does. The question is what happens when you push it into real production software.

**The problem everyone hits (4 min):** "Just ship a binary as a SquashFS image" fails fast.
- A GPU driver expects libraries and helpers at specific paths.
- `kubelet` brings a small ecosystem of dependencies and assumptions.
- Without RPM dependency resolution, you either make extensions fully self-contained or you accept collisions.

**How sysext works (3 min):** SquashFS images overlaid onto `/usr` via overlayfs. No package manager, no transaction log, no dependency graph. Merge, use, unmerge. Filesystem before/after.

**Upstream contributions from Flatcar (4 min):** Production use surfaced problems that led to upstream systemd contributions.
- The mutable overlay mode: sysext originally required a read-only overlay. Production needs required composability with runtime state. Contributed upstream. [CHECK FACT: verify specific PR/version]
- Other improvements to `systemd-sysext` and `systemd-sysupdate` that benefit any distro.

**Solving the dynamic linking problem (5 min):** The genuinely interesting engineering.
- Dynamically linked binaries assume host libraries at expected paths. Two sysext images shipping different library versions collide.
- Flatcar developed Flix (library path rewriting) and Flatwrap (mount namespace isolation). Both open source in the sysext-bakery repo.
- Trade-off stated honestly: you gave up dependency resolution for simplicity and lifecycle independence. rpm-ostree doesn't have this problem. Sysext is simpler but the self-containment burden is real.

**When not to use sysext (1 min):** If you need rich dependency resolution, complex package graphs, or third-party installers that expect `dnf install`, sysext is the wrong tool. "Simple" can become "fragile" if you force it.

**sysext on your distro (2 min):** sysext works on any systemd-based OS. The images are portable; the lifecycle integration (sysupdate configs, A/B update coverage) is where distros diverge. Brief: what this looks like on FCOS.

**Live demo (3 min):** Boot a Flatcar VM with `bakery.sh boot`. Base OS - no `kubelet`. Merge a Kubernetes sysext - `kubelet` appears and runs. Unmerge - it vanishes. (Pre-recorded fallback ready.)

Co-speaker: Daniel Zatovic
-->