---
name: kindle-reading
description: Use when bex wants to pull his Kindle highlights and notes for a book so he can write a reading.yml entry. Covers connecting to the Kindle over WiFi, pulling My Clippings.txt, listing which books have clippings, and dumping the highlights/notes (tagged quote vs. his own note) for the books he picks. Not for the Instapaper read-recently pipeline (that's read-recently-post).
---

# Kindle reading notes → reading.yml

Extracts highlights and typed notes bex made on his Kindle for inclusion into
`_data/reading.yml` `comment:`. **Agent task**: dump the clippings tagged with
their type (`[Highlight]` or `[Note]`), nothing more. Do not add commentary,
interpretation, or additional text — the output is the raw harvest ready for bex
to edit and contextualize. Books only — for Instapaper articles use the
`read-recently-post` skill.

## Two stages

1. **List** which books have clippings. bex tells you which he cares about.
2. **Dump** the highlights/notes for those books, each entry tagged
   `[Highlight]` (a quote) or `[Note]` (his own words).

`clippings.py` (in this skill dir) does everything: it SSHes to the Kindle,
pulls `My Clippings.txt`, and prints the result. No manual pull step.

```sh
# stage 1 — list every book with clippings + counts
python3 clippings.py

# stage 2 — dump the ones bex picks (title substrings, case-insensitive)
python3 clippings.py "gentoo" "kahneman"

# work from an already-saved file instead of the Kindle
python3 clippings.py --file MyClippings.txt "gentoo"
```

Each dump prints the knowable metadata (title, author, per-book counts) and one
block per clipping with its type, Kindle location, and timestamp. Everything
else in a `reading.yml` entry (url, cover, started/finished dates, and `id`) is
not in the clippings file — bex adds it, typically from OpenLibrary. `id` is the
deep-link anchor (`id: book-N`, next unused number, never reused); see the header
comment in `reading.yml`.

## Connection details (baked into the script)

- The Kindle is at a static IP `172.21.233.5` over WiFi; if the pull fails it's
  asleep — ask bex to wake it.
- Auth uses `dbclient` (`brew install dropbear`) with the root password read
  from 1Password at runtime: `op://Private/chtchgdbdwbxnoz3x2r46ixt5q/password`
  (item "Dominika's Kindle"). The UID isn't a secret; the password never leaves
  `op`. `op` must be signed in.
- Full connection reference and troubleshooting: `e-ink-tags/kindle/SSH.md`.

## Notes on the data

- `My Clippings.txt` is append-only across every book ever read, hence stage 1.
- Book titles carry the author in parens (`Title (Author)`); the Instapaper
  entry does not and is ignored as a book.
- A `[Note]` with no highlight is a standalone typed note. `conversion error`
  and mojibake (`―`, `‖`) come from a bad source file, not the Kindle — clean
  them by hand.
- This skill is deliberately not committed to the blog repo. It references the
  IP/op path only; the secret stays in 1Password.
