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

