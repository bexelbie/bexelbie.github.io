---
title: "Projects"
permalink: /projects/
layout: single
author_profile: true
---

Software I've built to solve problems that bothered me enough to write code.

## op-secret-manager

A no-daemon tool that distributes [1Password](https://1password.com/) secrets to multi-user Linux systems while keeping management centralized. Uses SUID privilege separation to a service account (not root), reads a protected API key, drops privileges, then fetches and writes secrets to per-user directories. No persistent state, no ceremony.

Built for the specific case of "I have a few Linux boxes, some containers, and a 1Password account; I want secrets distributed without adding persistent infrastructure."

- [GitHub](https://github.com/bexelbie/op-secret-manager) (GPLv3)
- [Blog post]({% post_url 2026-02-06-op-secret-manager %})

## Currency Feel

A travel companion that goes beyond currency conversion. Compare prices using the Big Mac Index, average wages, and purchase power parity to understand what costs really feel like in another country.

- [App Store](https://apps.apple.com/us/app/currencyfeel/id6714003960) (iOS)
- [currencyfeel.com](https://currencyfeel.com)

Built under [Electric Pliers LLC](https://electricpliers.com).
