---
name: talks-publications
description: Use when adding or updating talks, proposals, podcasts, external articles, or the /talks/ page on the blog. The page auto-generates from YAML front matter; this skill is the front-matter cookbook (entry types, proposal status, examples, display format, key rules).
---

# Talks & publications

The `/talks/` page auto-generates from YAML front matter — no manual list editing. The Liquid template collects all pages and posts with `entry_type` set (excluding proposals), sorts by `speaking_date` descending, and groups by year.

## Entry types

1. **Talks** (`entry_type: talk`): Conference presentations. File at `talks/YYYY/slug/index.md`. Title links to detail page.
2. **Proposals** (`entry_type: proposal`): Submitted CFPs. Same structure. Listed on `/talks/proposals/`.
3. **Articles** (`entry_type: article`): External publications. YAML added to existing blog post in `_posts/`. Title links to blog post. No separate page needed (exception: articles without a blog post stub get a standalone page under `talks/YYYY/slug/`).
4. **Podcasts** (`entry_type: podcast`): Podcast interviews or appearances. File at `talks/YYYY/slug/index.md`. Title links to a detail page that can point to the recording.

### Proposal status

- Default: submitted proposal
- If rejected and you want to keep it for reference: set `proposal_status: rejected`
- When accepted: change `entry_type` to `talk`

## Display format (two lines per entry)

- Line 1: Title as clickable link (bold)
- Line 2: Type label, month year, venue or publication

## Front matter

### Talk / proposal

```yaml
entry_type: talk          # talk | proposal | article | podcast
speaking_event: "Flock 2016"
speaking_date: 2016-08-04  # YYYY-MM-DD
permalink: /talks/2016/flock-docs-hackfest/
speaking_links:
  details: /talks/2016/flock-docs-hackfest/
```

### Podcast

```yaml
entry_type: podcast
speaking_event: "Coffee With Kusari"
speaking_date: 2026-04-21
permalink: /talks/2026/coffee-with-kusari-episode-10/
speaking_links:
  details: /talks/2026/coffee-with-kusari-episode-10/
  recording: "https://www.youtube.com/watch?v=..."
```

### External article

Add to existing `_posts/` front matter:

```yaml
entry_type: article
speaking_event: "opensource.com"
speaking_date: 2019-04-24
speaking_links:
  external: "https://opensource.com/article/19/4/gpg-subkeys-ssh"
```

## Key rules

- `speaking_date` must be date-parseable (`YYYY-MM-DD`).
- `title` must be the actual talk/article title, not the event name.
- Preserve old URLs via `redirect_from` when renaming.
- FOSDEM organizer pages (`talks/fosdem/`) are historical artifacts with no `entry_type`.
