---
name: read-recently-post
description: Use when bex asks to build, start, continue, or publish a "Read Recently", "Things I Read", or reading-notes post. The first response must be to run gen-read-recently (a blocking first step), then edit the generated draft. Covers the generator workflow, curation rules, disclaimer placement, and promoting the draft to a post.
---

# Read Recently / reading-notes post

## Blocking first step

If bex asks to build, start, or do the next read-recently or reading-notes post,
your **first response** must be: run `gen-read-recently`. Do this before
searching the repo, inspecting prior posts, checking command availability, or
running any tool. The only exception is when bex has already pointed to a
specific existing draft in `_working-notes/`. This is a blocking first step, not
a suggestion.

`gen-read-recently` already picks up the right pieces for this repo and creates a
draft in `_working-notes/`. (`ip-read-recently` is a user-level tool, assumed
installed.)

## Series curation rules

- Primarily curated reading notes, not a bundle of mini-essays. Commentary should explain why an item stuck, not turn every entry into a standalone post.
- Snark is allowed, but don't let the post become a snark dump. Keep sharp lines that add voice or judgment; cut ones that only sneer.
- A few lighter entries are fine, but each item should earn its place by doing at least one clearly:
  - surface a surprising fact or angle
  - reveal something about the author's own thinking
  - deliver a joke or aside sharp enough to justify the space
- Trim entries that add nothing beyond "I read this" or a placeholder reaction.
- When a disclaimer is needed (see the `blog-publication` skill for the canonical text), place it once near the top so it applies to the whole post.

## Editing the generated draft

The generator gives you scaffolding, not a publishable post. Before moving it to `_posts/`:

1. Edit by hand: write the excerpt, tighten the generated title/date range if awkward (the template consumes the generator's `title`, but normalize it before publishing), group items into sections only where the grouping helps, trim weak entries and extra highlights, and add the disclaimer once near the top if it applies.
2. Once the draft is captured and the post work is done, remind bex to run `move-read-recently` manually — it moves the processed Instapaper items out of the source folder.
3. Promote to a real post: move it from the repo root with `mv` into `_posts/`. Do not `git mv` from inside `_working-notes/`; that source is git-ignored.

Apply the `blog-publication` skill for final front matter and verification.
