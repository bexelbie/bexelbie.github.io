---
title: "You Don't Need Kubernetes: Side Projects on One Linux Server"
permalink: /talks/2026/installfestcz-you-dont-need-kubernetes/
redirect_from:
  - /talks/cfp-submissions/installfest.cz-2026
entry_type: proposal
status: submitted
speaking_event: "Installfest.cz"
speaking_date: 2026-03-15
speaking_links:
  details: /talks/2026/installfestcz-you-dont-need-kubernetes/
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

This proposal was originally part of a combined submission to Installfest.cz 2026. The second proposal is [Flatcar Linux 101: A Hands-Free Server OS](/talks/2026/installfestcz-flatcar-linux-101/).

## Abstract

You probably do not need Kubernetes, a dedicated secrets vault, or Grafana to run a small side project on the internet. In this talk, I show how I run a reliable web service on a single immutable Flatcar Linux server with rootless Podman containers managed by systemd. I also explain how I reuse 1Password for secret injection and Home Assistant via MQTT for simple monitoring. The goal is a practical, repeatable setup you can run at home and mostly ignore between feature updates. This talk is for developers and homelab enthusiasts who want to run reliable services without spending all their time on maintenance.

## Description

Many side projects start as a small idea and then grow into an unnecessarily complex home lab: Kubernetes clusters, separate secrets vaults, multiple dashboards, and complex upgrade procedures. This is fun if you want to learn those tools, but it is often more work than the actual service you are trying to run. For many side projects, we just want something that works, is safe enough, and does not need constant attention.

In this talk, I walk through the real-world architecture of [PuzzleSecretary](puzzlesecretary.com), a web service for tracking social game scores that runs on a single Linux server. I use Flatcar Linux as an immutable base, rootless Podman for containers, 1Password for storing secrets, and Home Assistant for basic monitoring and alerts. The focus is on concrete steps and practical trade-offs, not on building a small data center in your closet.

You will see:

- how to structure a single-server deployment for a web service
- how Flatcar auto-updates and rootless Podman quadlets help with isolation
- how to inject credentials via 1Password instead of building a new secrets system
- how to use Telegraf and MQTT to treat Home Assistant as a simple monitoring and alerting layer

## Outline (20-25 minutes)

**Opening: The Over-Engineering Trap (3 minutes)**
- Live example: Show a typical "simple" homelab architecture diagram (K8s, Vault, Grafana, Prometheus)
- Question: "How much time maintaining vs building features?"
- Thesis: Most side projects don't need this complexity

**Architecture Overview: PuzzleSecretary (3 minutes)**
- What it does: Track social game scores (show screenshot/recorded demo)
- Single server setup: One Flatcar Linux VPS
- Key components at a glance (diagram):
  - Flatcar Linux (immutable base, auto-updates)
  - Rootless Podman + systemd quadlets
  - 1Password (secrets)
  - Home Assistant (monitoring via MQTT)

**Principle 1: Immutable Base OS (4 minutes)**
- Why immutability matters for side projects
- Flatcar auto-updates in background (show update logs/status)
- No manual `apt upgrade`, no drift between dev/prod
- Trade-off: Can't `apt install`, must use containers or sysext
- Recorded clip: Show `systemctl status update-engine` and uptime after auto-reboot

**Principle 2: Reuse Existing Tools (5 minutes)**
- 1Password for secrets (already paying for it)
  - Show Butane config snippet with 1Password reference
  - Mention: podman secret create from 1Password CLI
  - Trade-off: Requires 1Password subscription, CLI setup
- Home Assistant for monitoring (already running at home)
  - Show Telegraf → MQTT → Home Assistant dashboard
  - Simple alerts via Home Assistant automations
  - Trade-off: Not a "real" monitoring system, good enough for side projects
- Principle: Stretch tools you already know/pay for

**Principle 3: Systemd for Orchestration (4 minutes)**
- Podman quadlets: containers managed like systemd services
- Show quadlet file example for web app container
- Dependencies: `After=network-online.target`, `Requires=`
- Automatic restarts, logging to journald
- Trade-off: No fancy orchestration, but no complexity either

**Putting It Together (4 minutes)**
- Recorded walkthrough: Full deployment from Ignition config
  - Butane YAML → Ignition JSON
  - Provision server (timelapse/fast-forward)
  - Service comes up, auto-restarts on failure
  - Home Assistant shows it's alive
- Point out: This setup has been running for X months with Y manual interventions

**Principles to Adapt (2 minutes)**
- Immutability: Use whatever immutable OS fits (Flatcar, Fedora CoreOS, NixOS)
- Reuse: What tools do you already have? (Bitwarden instead of 1Password, Uptime Kuma instead of HA)
- Simplicity: One server is enough for most side projects
- Automation: Declare it once, let it run
- Where to learn more: Link to your blog/repo

**Q&A Buffer (if time)**
