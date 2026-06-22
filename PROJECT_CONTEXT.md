---
kind: docs
purpose: bex's personal blog — Jekyll / Minimal Mistakes site at bexelbie.github.io
visibility: public
---

# PROJECT_CONTEXT.md — Blog (Jekyll / Minimal Mistakes)

Project-specific facts for the blog. Writing conventions come from the global
`writing` and `style-capsule` skills (they auto-load by task). Task-specific blog
workflows are project-local skills (see Skills below).

## Build & Run

- **Environment:** Ruby 3.4 required.
- **Install:** `bundle install`
- **Serve:** `bundle exec jekyll serve` (or `chruby 3.4; bundle exec jekyll serve`).
- **Structure:** Standard Jekyll + Remote Theme (`bexelbie/minimal-mistakes@bex-master`). `_layouts/` and `_sass/` are generally absent unless locally overriding.

## File Conventions

- **Posts:** `_posts/YYYY-MM-DD-slug.md`
- **Drafts / scratch:** `_working-notes/` — a real dir, git-ignored (`.gitignore`) and Jekyll-excluded (leading underscore keeps it out of `_site`). Do not commit. When promoting a draft to a post, move it with `mv` from the repository root and then `git add` the new file; `git mv` from inside `_working-notes/` will fail because the source is ignored.
- **Talks:** `talks/YYYY/slug/index.md`
- **Projects:** `projects/index.md`
- **Components:** `_includes/` contains specific overrides. Use pure HTML/Liquid there.

## Git Workflow

Work in preview. `_working-notes/` is git-ignored and must not be committed unless explicitly instructed. Never rename existing post slugs without explicit instruction — it breaks inbound links. Use `redirect_from` in front matter when moving or renaming published pages.

## Internal Links

ALWAYS use the Liquid tag for internal posts: `[Link Text]({% post_url yyyy-mm-dd-slug %})`. If the target post does not exist yet, raise the broken reference in chat.

## Images & Asset URLs

Preview deployments may run on a different domain than production. To avoid broken images on preview/staging:

- **In post/page body content:** use local, root-relative paths with the `relative_url` filter.
  - Example: `![Alt text]({{ "/img/2026/example.png" | relative_url }})`
  - Avoid `absolute_url` in body content (it will hard-code the production domain).
- **In metadata / SEO contexts** (canonical URLs, feeds, OpenGraph images): `absolute_url` is appropriate/required.

Rule of thumb: **content assets = relative**; **metadata/share URLs = absolute**.

## Front Matter (defaults)

Respect defaults in `_config.yml` (Posts: `layout: single`, `author_profile: true`). Do NOT alter existing YAML key names unless explicitly requested.

- **Draft / exploratory:** minimal keys only — `title`, `date`. No excerpt, no social images.
- `categories`/`tags` are intentionally **not** used anymore. Leave them in legacy posts; do not add to new posts.
- **Prohibited additions:** analytics IDs, tracking parameters, marketing campaign tags.

Publication-ready front matter (required keys, the date/time standard, excerpt rules, header guidelines) is in the `blog-publication` skill.

## Projects Page

Lives at `projects/index.md` using `layout: single` with `author_profile: true`. Manually maintained.

### Format

```markdown
## Project Name

[primary-link](https://url) · [secondary-link](https://url)

Short description paragraph.
```

### Link Strategy

- Web apps: link to live app
- Phone apps: link to product website; App Store link second
- CLI/server tools: link to blog post (if exists) or GitHub repo

### Ownership Disclosure

- Electric Pliers LLC projects: include "Built under [Electric Pliers LLC](https://electricpliers.com)" in description
- Personal projects: no per-project attribution (page intro covers default)

### Rules

- Order by likelihood of interest (most broadly useful first)
- Internal links use `post_url` tags
- No sub-pages unless a project grows complex

## Skills (task-triggered)

- `blog-publication` — preparing a post for publication (front matter, date/time, excerpt, headers, disclaimer, length, blog verification).
- `read-recently-post` — building a "Things I Read" / reading-notes post (runs `gen-read-recently` first).
- `talks-publications` — adding/updating talks, proposals, podcasts, articles, or the `/talks/` page.
- `social-posts` — generating Mastodon/LinkedIn posts at publication time.

## Work Tracking

Open work → `_working-notes/loops.md` (use the `loops` skill; the path is `_working-notes/`, not `working-notes/`, so Jekyll's leading-underscore rule keeps it out of `_site`). No `log.md` for this repo — git commit history is the record.
