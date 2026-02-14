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

