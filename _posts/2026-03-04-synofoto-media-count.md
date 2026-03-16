---
title: "Counting Synology Photos uploads with synofoto-media-count"
date: 2026-03-04 22:10:00 +0100
excerpt: "Read-only queries against Synology Photos’ DB to gauge upload progress."
---

I’m currently testing Synology Photos, including the iPhone uploader. I wanted to know how far the upload had actually gotten.

The problem is that none of the obvious UIs answer that.

- The Synology Photos web UI doesn’t show a total count.
- The phone UI shows my whole camera roll (uploaded or not), and also doesn’t give a useful count.

So I wrote a small tool: [synofoto-media-count](https://github.com/bexelbie/synofoto-media-count).

## The mismatch

If you’re backing up an iPhone library, you can end up with three numbers that don’t agree:

- The number of photos on your phone
- The number of files on disk
- The number of “things” Synology Photos has indexed (which the UI doesn’t show)

That last one is the number I cared about. I’m fine with the file system being messy - I just want to know whether the app has ingested what I think it has.

## Why counting files doesn’t answer this

The file system is easy to count, but it’s not what I’m trying to measure. With Live Photos, the file count is expected to be “weird” because a single photo experience can be multiple files.

What I actually want is a number that matches the app’s idea of “items,” because that’s what I’m mentally comparing to the photo count on my phone. That’s the gap this script closes.

## What the script does

The repo contains a read-only bash script (`count-media.sh`) that runs `SELECT` queries against Synology Photos’ PostgreSQL database (by default, the `synofoto` database). It has options for multiple users and folders, JSON output for automation, and an optional `publish-to-ha.py` helper that publishes counts into Home Assistant via MQTT auto-discovery. It collapses Live Photo pairs into a single “item” so the results are closer to what you see on the phone.

## Requirements

To run it, you need:

- Synology DSM 7.x with Synology Photos installed
- SSH access to the NAS
- `sudo` privileges (or direct `postgres` user access)
- Python 3 if you want to use `publish-to-ha.py`

## Safety

This script is read-only. It runs `SELECT` queries only and never modifies your data.

## Usage (quick)

In the common case, you copy the script to your NAS, make it executable, and run it with `sudo`. It will try to do something sensible for iPhone uploads (like auto-selecting `/MobileBackup` if it exists) and will scope to the current user by default.

If the defaults don’t match your setup, there are flags for selecting a folder interactively, scoping to a different user, and emitting `--json` output for automation.

## Home Assistant integration

If you want the counts to show up somewhere other than your terminal, `publish-to-ha.py` can publish per-user counts into Home Assistant via MQTT auto-discovery. The result is a handful of sensors per user (non-live photos, Live Photos, videos, other, and a total) that you can graph or use in automations.

## Notes

- Counts include nested subfolders by default. If you want a single folder only, there’s an “exact folder” option.
- `--verbose` shows additional technical detail (raw unit counts, type breakdowns).
- `--inspect` helps when something looks weird - like “incomplete Live Photo groups” where one half is missing.
- For iPhone MobileBackup libraries, the defaults for photo/video types should work, but they’re overridable if your installation differs.

It prints a breakdown like:

- non-live photos
- Live Photos (collapsed groups, plus their underlying files)
- standalone videos
- “other” items
- incomplete Live Photo groups (one half is missing)

That breakdown is enough to sanity check whether “uploads are incomplete” vs “uploads are likely complete.” This provides a validation point to go with "why isn't this thing uploading now?"

Now it's time to set my phone to sleep focus and leave the uploader running overnight ... for a long time.
