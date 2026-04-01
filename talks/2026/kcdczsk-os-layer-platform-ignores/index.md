---
title: "The OS Layer Your Platform Ignores"
permalink: /talks/2026/kcdczsk-os-layer-platform-ignores/
entry_type: proposal
proposal_status: submitted
speaking_event: "KCD Czech & Slovak"
speaking_date: 2026-05-21
speaking_links:
  details: /talks/2026/kcdczsk-os-layer-platform-ignores/
layout: single
author_profile: true
classes: wide
---

## Submitted to [KCD Czech & Slovak 2026](https://community.cncf.io/kcd-czech-slovak/) in Prague, Czech Republic on 21-22 May 2026

## Abstract

You have a hundred Kubernetes nodes. Can you prove their filesystems match what you shipped?

Kubernetes solves orchestration, not OS integrity. Nodes replace from the same image - but it runs a mutable filesystem. Debug sessions leave files. Daemonsets write to the host. Two nodes report identical versions while filesystems diverge. The orchestrator can't check.

Most drift defenses detect changes after the fact. Detecting drift isn't making it structurally impossible. "Shift Down" security pushes integrity into the platform - the node OS is where that starts.

Flatcar Container Linux (CNCF Incubating) treats the node OS like containers: immutable, declarative, atomically updated. /usr is dm-verity protected - cryptographically verified at boot. systemd-sysext extends the base without breaking immutability.

I'll show how Flatcar provisions identical nodes from Ignition, updates atomically with rollback, and gives platform teams a node they can reason about.

<!--
## How This Session Benefits The CNCF Ecosystem

Flatcar is a CNCF Incubating project, and this talk directly supports its adoption by showing practitioners how to use it. More broadly, the session advances the "Shift Down" security approach advocated by the Kubernetes SIG-Security working group - moving OS integrity from an afterthought to a platform guarantee.  Attendees building internal platforms on Kubernetes will leave with a concrete, reproducible approach to node provisioning that complements the container-level supply chain tooling the CNCF ecosystem already provides. The talk also demonstrates integration with other CNCF-adjacent standards: Ignition for declarative provisioning, systemd-sysext for composable OS extensions, and dm-verity for cryptographic boot verification.
-->
