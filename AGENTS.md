# AGENTS.md — Blog

Writing conventions for this repo come from the global `writing` and
`style-capsule` skills (they auto-load by task, everywhere — not just here).
This file holds only what's specific to operating the blog repo; durable repo
facts are in `PROJECT_CONTEXT.md`, and task workflows are the project-local
skills under `.agents/skills/`.

## Work tracking

- Open work → `_working-notes/loops.md` (via the `loops` skill). The path is
  `_working-notes/`, **not** `working-notes/`: the leading underscore keeps it
  out of the Jekyll build (`_site`), and it's git-ignored via
  `.gitignore` (this repo is public).
- **No `log.md`** — git commit history is this repo's record. (A root `log.md`
  with no front matter would be published as a static file.)

## Workflows with a blocking first step

Some skills require a user-directed first action before any tool use — notably
`read-recently-post`, whose first response must be to run `gen-read-recently`.
When a skill says the first response is a specific instruction to bex, follow it
over the default "just do it" proactiveness.
