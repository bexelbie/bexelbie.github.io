---
title: "Flatcar Linux 101: A Hands-Free Server OS"
permalink: /talks/2026/installfestcz-flatcar-linux-101/
entry_type: proposal
status: submitted
speaking_event: "Installfest.cz"
speaking_date: 2026-03-15
speaking_links:
  details: /talks/2026/installfestcz-flatcar-linux-101/
header:
  overlay_image: "/img/about-bg.jpg"
  og_image: "/img/about-bg.jpg"
  teaser: "/img/about-bg.jpg"
  caption: "Photo credit: author"
  overlay_filter: 0.5
layout: single
author_profile: true
classes: wide
---

## Abstract

Flatcar Linux is an immutable, container-focused Linux distribution that automatically updates itself without breaking your applications. If you want an alternative to manually coordinating package updates across servers, choosing between stable releases with selective backports or newer packages from additional repositories, Flatcar offers a different approach. In this talk, I introduce the core concepts of Flatcar Linux, show you how to provision a server with Ignition configuration, and explain how systemd-sysext lets you extend the minimal base with official and community-maintained packages like Podman, Tailscale and more. This talk is for Linux administrators and developers who want to spend less time maintaining servers and more time running services.

## Description

Most Linux distributions expect you to manually manage updates, coordinate security patches across your fleet, and decide between stable releases with selective backports or adding repositories for newer software versions. This approach gives you control and flexibility, but it requires ongoing attention and creates opportunities for servers to become configured differently over time. Each update cycle involves testing, scheduling maintenance windows, and carefully rolling out changes.

Flatcar Linux takes a different approach: the operating system is immutable, updates happen automatically in the background, and all your applications run in containers. The base OS is minimal and never changes after boot. When an update is ready, Flatcar reboots into the new version automatically with zero manual intervention. If you need additional software beyond the minimal base, systemd-sysext lets you extend Flatcar with community-maintained packages from the sysext-bakery without breaking immutability.

In this talk, I explain how Flatcar works and show you how to get started. You will see a real server being provisioned from scratch using Ignition, Flatcar's declarative configuration system. I cover the automatic update mechanism and show how to extend Flatcar with systemd-sysext.

You will learn:

- what makes Flatcar different from traditional Linux distributions
- how Ignition lets you declaratively configure servers at boot time
- how automatic updates work and why they are safe
- how to extend Flatcar with systemd-sysext and the community sysext-bakery

## Outline (20-25 minutes)

**Opening: What is Flatcar? (2 minutes)**
- Immutable, container-focused Linux distribution
- Automatic background updates without breaking apps
- Minimal base: no package manager, declare everything at boot
- Who uses it: Edge devices, Kubernetes nodes, infrastructure that needs to "just work"

**The Ignition Moment (5 minutes)**
- Traditional approach: Install OS, SSH in, run commands, configure
- Flatcar approach: Declare everything in Ignition config, provision once
- Live demo (recorded): Provision a server from scratch
  - Show empty Butane YAML file
  - Add SSH key, create a systemd unit for nginx container
  - Transpile Butane → Ignition JSON with `docker run quay.io/coreos/butane`
  - Boot fresh QEMU image with ignition: `./flatcar_production_qemu.sh -i ignition.json`
  - SSH in, show `systemctl status nginx`, `curl localhost`
  - Total time from YAML to running: ~90 seconds
- Key point: Ignition only runs on first boot, everything declared

**How Auto-Updates Work (4 minutes)**
- Dual root partition system (A/B)
- Update downloads in background while you work
- Atomic switch: reboot into new partition
- If new version fails to boot, automatic rollback to old partition
- Show how to check update status: `update_engine_client --status`
- Show how to configure update strategy in Butane:
  - Define reboot windows
  - Disable automatic reboots (manual control)
  - Disable updates entirely (for testing)
- Trade-off: Less control, more reliability

**Extending Flatcar with Systemd-Sysext (7 minutes)**
- Problem: Minimal base doesn't include Docker, Kubernetes, Python, etc.
- Solution: systemd-sysext overlays `/usr` without breaking immutability
- Show the sysext-bakery: 30+ community extensions
  - Docker, Podman, containerd, CRI-O
  - Kubernetes, k3s, RKE2
  - Tailscale, Ollama, Falco
- Live example (recorded):
  - Add Tailscale sysext via Ignition
  - Show Butane snippet to enable sysext: `/etc/flatcar/enabled-sysext.conf`
  - Boot VM, show `systemd-sysext status`
  - Verify `which tailscale` works
- Mention: Can auto-update extensions independently with systemd-sysupdate
- Mention: Can build custom sysext for your own tools

**Common Use Cases (3 minutes)**
- Single-server deployments (like Talk 1)
  - Hosting personal projects
  - Small business infrastructure
  - "Set and forget" reliability
- Edge devices and IoT
  - Raspberry Pi, industrial computers
  - Remote locations with limited access
  - Auto-updates without manual intervention
- Kubernetes/container infrastructure
  - Immutable nodes, no configuration drift
  - Fast provisioning of new nodes
  - Easy rollback if update breaks

**Getting Started: Next Steps (3 minutes)**
- Try it locally: QEMU setup takes 5 minutes
  - Download QEMU image and script from flatcar.org
  - Write basic Butane YAML (show minimal example)
  - Transpile and boot
- Where to run it:
  - All major clouds (AWS, Azure, GCP, Equinix Metal)
  - VMware, VirtualBox, libvirt
  - Bare metal via PXE/iPXE
- Resources:
  - flatcar.org/docs - excellent documentation
  - sysext-bakery GitHub - ready-to-use extensions
  - Example configs in the docs
- Community: Matrix, Slack, GitHub discussions

**Q&A Buffer (if time)**
