---
title: "Jekyll Reads: the tooling behind my reading list"
date: 2026-03-03 08:50:00 +0100
excerpt: "A tiny, dependency-free toolkit for keeping a Jekyll reading log in sync: one YAML data file, a CLI, and editor integrations that handle the boring parts."
---

## Why I needed more than a social reading site

In [Rediscovering Reading (Without the Social Media Part)]({% post_url 2025-02-11-rediscovering-reading %}) I wrote about stepping away from scrolling and building a slower, more deliberate reading habit. Part of that shift was making my reading log public without tying it to a dedicated social network.

The mechanics behind that were simple but fussy: keep a YAML file up to date, copy and paste links from Open Library, remember to grab cover images, and wire everything into Jekyll templates for the reading page and sidebar. None of it was hard, but it was just annoying enough that I knew future‑me would start skipping updates.

I built Jekyll Reads to make that workflow tolerable.

## What Jekyll Reads actually does

Jekyll Reads is a small collection of pieces designed around a single idea: keep all the book data in one `_data/reading.yml` file and let everything else be presentation.

The core pieces are:

- A shared Node.js library that talks to Open Library, picks a reasonable match, and produces a standard YAML snippet for a book
- A command‑line tool that lets you search for a book and print the YAML to stdout, with options for indentation and auto‑selecting results
- A Vim integration that shells out to the CLI and drops the YAML directly into your buffer at the right indentation level
- A Visual Studio Code extension that does the same thing from inside the editor, with a proper search UI and update checks for the extension itself

All of this is intentionally boring: no external Node dependencies, just the built‑in modules and a bit of glue. The point is to make it slightly easier to keep the reading list current than to let it drift.

## How it shows up on this site

On this site, the source of truth is `_data/reading.yml`. Entries that are still in progress, finished, or abandoned are all represented there with the same structure. The YAML includes things like start and finish dates, a link to more information (usually Open Library), an optional cover image, and a free‑form comment.

That data feeds two places:

- The dedicated [reading page](/reading/), which separates currently‑reading, finished, and abandoned books and shows covers, dates, and comments
- A small sidebar block on the home page that surfaces what I am currently reading, so the log is visible without needing a whole post for every book

Jekyll Reads does not try to be a general bookshelf app. It just reflects what I am already doing: writing short notes in YAML and publishing them along with the rest of the site.

## Design constraints and trade‑offs

I made a few deliberate choices that might look odd if you are used to larger toolchains:

- **No external Node dependencies.** The library and CLI only use built‑in modules like `https` and `readline`. That keeps installation simple and makes it easy to run in constrained environments.
- **Open Library as the primary data source.** It provides book metadata, cover images, and stable URLs without requiring another account or scraping.
- **Plain YAML as the storage format.** A static `_data` file is easy to version, review, and back up. It also plays nicely with Jekyll’s existing data pipeline.
- **Multiple small tools instead of one big one.** The CLI, Vim integration, and VS Code extension all sit on top of the same library, so they stay in sync without each re‑implementing the logic.

If any of that stops being true in the future, I can replace or extend the pieces without touching the core data file.

## If you want to use it

The repository README walks through how to set up your own `_data/reading.yml`, wire up a reading page and sidebar, and use the CLI or editor integrations. It is written so that you can follow it even if you are not using the same Jekyll theme I am.

The code is MIT‑licensed and shipped under Electric Pliers LLC. If you want a lightweight way to publish a reading log without standing up a whole social network, you might find it useful.

You can find the repository and full documentation here: https://github.com/ElectricPliers/jekyll-reads
