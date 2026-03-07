---
title: "Projects"
permalink: /projects/
layout: single
author_profile: true
---

Software I've built to solve problems that bothered me enough to write code. Some of these ship through [Electric Pliers LLC](https://electricpliers.com); the rest are personal projects.

## Currency Feel

![Currency Feel comparison results](/img/projects/currencyfeel.png){: .align-left style="border: 1px solid #ddd; padding: 4px;"}

[currencyfeel.com](https://currencyfeel.com) · [App Store](https://apps.apple.com/us/app/currencyfeel/id6714003960)

Compare prices abroad using the Big Mac Index, average wages, and purchase power parity to understand what costs really feel like in another country. Built under [Electric Pliers LLC](https://electricpliers.com).

## Online Compact Calendar

[cc.bexelbie.com](https://cc.bexelbie.com) · [Blog post]({% post_url 2026-02-18-online-compact-calendar %}) · [GitHub](https://github.com/bexelbie/online-compact-calendar)

![A full-year compact calendar view showing one row per week, with multi-day events highlighted in color to make travel and vacation conflicts easy to spot.](/img/2026/CC-FullCalendar.png)

Year-at-a-glance web app that reads ICS feeds and highlights multi-day, all-day events in a single-page view. Useful for planning vacations, travel, and school breaks and, critically, spotting conflicts early.

## op-secret-manager

[Blog post]({% post_url 2026-02-06-op-secret-manager %}) · [GitHub](https://github.com/bexelbie/op-secret-manager)

Distribute [1Password](https://1password.com/) secrets to multi-user Linux systems. SUID privilege separation, no daemon, no persistent state.

## Jekyll Reads

[GitHub](https://github.com/ElectricPliers/jekyll-reads) · [Reading page](/reading/)

Tools for keeping a reading list in a single `_data/reading.yml` file and rendering it on this site. Includes a Node.js library, CLI tool, Vim integration, and Visual Studio Code extension for searching Open Library and inserting YAML entries with the right formatting. Built under [Electric Pliers LLC](https://electricpliers.com).

## HedgeDoc Draft Share

[Runbook](https://github.com/bexelbie/hedgedoc-container/blob/master/FORK.md) · [Fork notes](https://github.com/bexelbie/hedgedoc/blob/bex-master/FORK.md) · [Blog post]({% post_url 2026-02-12-yak-shaving %})

Self-hosted collaborative editing/review platform for markdown documents. Built on HedgeDoc v1 because it runs comfortably on tiny hardware with SQLite; the fork adds a few collaboration/UI fixes that allow for anonymous reviewers to prevent the need to create accounts, adds the ability to easily leave comments in addition to changes and ensure everything has appropriate color highlighting. See the fork notes or my blog post for details.

## Synofoto Media Count

[GitHub](https://github.com/bexelbie/synofoto-media-count)

Read-only bash script that queries the Synology Photos PostgreSQL database (`synofoto`) and prints a breakdown of what’s actually in your library: non-live photos, Live Photo groups, standalone videos, and incomplete Live Photo pairs.

## Phone a Friend

[GitHub](https://github.com/bexelbie/phone-a-friend) · [npm](https://www.npmjs.com/package/@bexelbie/phone-a-friend)

MCP server that lets VS Code Copilot Chat dispatch subtasks to a different AI model via GitHub Copilot CLI, returning a unified diff so the calling agent can apply changes with gutter indicators intact. This works around current limitations in VS Code.
