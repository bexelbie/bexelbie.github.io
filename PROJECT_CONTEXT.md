# PROJECT_CONTEXT.md — Blog (Jekyll / Minimal Mistakes)

Project-specific conventions for the blog. Read alongside AGENTS-writing.md for behavioral rules and STYLE-CAPSULE.md for voice guidance.

## Build & Run

- **Environment:** Ruby 3.4 required.
- **Install:** `bundle install`
- **Serve:** `bundle exec jekyll serve` (or `chruby 3.4; bundle exec jekyll serve`).
- **Structure:** Standard Jekyll + Remote Theme (`mmistakes/minimal-mistakes`). `_layouts/` and `_sass/` are generally absent unless locally overriding.

## File Conventions

- **Posts:** `_posts/YYYY-MM-DD-slug.md`
- **Drafts:** `_drafts/` — untracked by git. Do not commit drafts unless explicitly instructed.
- **Talks:** `talks/YYYY/slug/index.md`
- **Projects:** `projects/index.md`
- **Components:** `_includes/` contains specific overrides. Use pure HTML/Liquid there.

## Git Workflow

Work in main. `_drafts/` files are untracked and should not be committed unless explicitly instructed. Never rename existing post slugs without explicit instruction — it breaks inbound links. Use `redirect_from` in front matter when moving or renaming published pages.

## Internal Links

ALWAYS use the Liquid tag for internal posts: `[Link Text]({% post_url yyyy-mm-dd-slug %})`. If the target post does not exist yet, raise the broken reference in chat.

## Images & Asset URLs

Preview deployments may run on a different domain than production. To avoid broken images on preview/staging:

- **In post/page body content:** use local, root-relative paths with the `relative_url` filter.
  - Example: `![Alt text]({{ "/img/2026/example.png" | relative_url }})`
  - Avoid `absolute_url` in body content (it will hard-code the production domain).
- **In metadata / SEO contexts** (canonical URLs, feeds, OpenGraph images): `absolute_url` is appropriate/required.

Rule of thumb: **content assets = relative**; **metadata/share URLs = absolute**.

## Front Matter

Respect defaults in `_config.yml` (Posts: `layout: single`, `author_profile: true`). Do NOT alter existing YAML key names unless explicitly requested.

### Draft / Exploratory Work

Minimal keys only: `title`, `date`. No excerpt, no social images.

### Publication-Ready Posts

Required keys:
- `title`
- `date` (see Date & Time Standard below)
- `excerpt` (factual sentence, <140 chars; no evaluative adjectives unless necessary for precision)

Intentionally NOT used anymore: `categories`, `tags`. Leave them in legacy posts; do not add to new posts.

Optional keys when relevant:
- `header` (see Header Guidelines below)
- `redirect_from` (only for migrated / renamed slugs)
- `layout`, `author_profile`, etc. rely on `_config.yml` defaults — avoid redefining unless changing behavior.

Prohibited additions: analytics IDs, tracking parameters, marketing campaign tags.

### Date & Time Standard

Timezone: `Europe/Prague`. Honor DST (CET = UTC+1, CEST = UTC+2).

When creating a new post and no date is provided:
1. Current time in `Europe/Prague`.
2. Round UP to the next 10-minute boundary.
3. Set seconds to `00`.
4. Use the appropriate offset (`+0100` or `+0200`) based on DST.

Format: `YYYY-MM-DD HH:MM:00 +ZZZZ`.

If user supplies a date/time, preserve it verbatim except to normalize zero-padded month/day (e.g., `2025-8-5` → `2025-08-05`).

### Excerpt Rules

- Must stand alone out of context (feed readers, social cards).
- Avoid subjective adjectives unless precision requires.
- If summarizing a list → name the framework + action.
- Inject a hint of the post's tone when appropriate.
- Do NOT repeat the title or its opening label. Provide a complementary angle.
- For a multi-day series, surface what changed vs. earlier days.

### Header Guidelines

Include a `header` block ONLY when a visual element materially aids context. Otherwise omit.

Use cases to include:
- Book cover, event photo, or artifact that anchors the topic
- Original photography adding context
- Diagrams central to argument

Avoid when:
- Pure opinion/editorial without a concrete visual referent
- Link/pointer posts with minimal commentary
- Routine note dumps where an image is decoration only

`header` keys (Minimal Mistakes pattern):
- `overlay_image`: Primary image (remote URL or local path). Remote allowed if stable; prefer local copy when license permits.
- `og_image`: Match `overlay_image` unless different aspect ratio needed.
- `teaser`: Smaller version when available (optional).
- `caption`: Attribution + concise description. Include source link when not author's own.
- `overlay_filter`: Numeric (0-1); keep if text legibility requires. Omit otherwise.

Attribution: Always cite source unless original work. If license requires specific wording not provided → raise in chat.

Accessibility: If image delivers essential info not in body → add descriptive sentence in body or caption.

Remote stability: Favor reputable sources. If transience risk → suggest downloading locally (do not auto-download).

## Publication Standards

Target length: ideally 900+ words. Flag if under 700 (too thin?) or over 1500 (needs tightening?).

Full front matter required (see above). Excerpt required.

## Disclaimer

Use exactly once when employer, client, or affiliation is referenced or contextually relevant.

Canonical text:
> Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

If an earlier post in a series uses a slightly different variant, standardize unless instructed to preserve historical wording.

Do NOT add if neither employer nor sensitive topic appears.

## Talks & Publications Page

The `/talks/` page auto-generates from YAML front matter. No manual list editing. The Liquid template collects all pages and posts with `entry_type` set, sorts by `speaking_date` descending, and groups by year.

### Entry Types

1. **Talks** (`entry_type: talk`): Conference presentations. File at `talks/YYYY/slug/index.md`. Title links to detail page.
2. **Proposals** (`entry_type: proposal`): Submitted CFPs. Same structure. Shown as "Submitted proposal." When accepted, change `entry_type` to `talk`. If rejected, delete or repurpose.
3. **Articles** (`entry_type: article`): External publications. YAML added to existing blog post in `_posts/`. Title links to blog post. No separate page needed (exception: articles without a blog post stub get a standalone page under `talks/YYYY/slug/`).

### Display Format (two lines per entry)

- Line 1: Title as clickable link (bold)
- Line 2: Type label, month year, venue or publication

### Talk/Proposal Front Matter

```yaml
entry_type: talk          # talk | proposal | article
speaking_event: "Flock 2016"
speaking_date: 2016-08-04  # YYYY-MM-DD
permalink: /talks/2016/flock-docs-hackfest/
speaking_links:
  details: /talks/2016/flock-docs-hackfest/
```

### External Article Front Matter

Add to existing `_posts/` front matter:

```yaml
entry_type: article
speaking_event: "opensource.com"
speaking_date: 2019-04-24
speaking_links:
  external: "https://opensource.com/article/19/4/gpg-subkeys-ssh"
```

### Key Rules

- `speaking_date` must be date-parseable (`YYYY-MM-DD`).
- `title` must be the actual talk/article title, not the event name.
- Preserve old URLs via `redirect_from` when renaming.
- FOSDEM organizer pages (`talks/fosdem/`) are historical artifacts with no `entry_type`.

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

- Order newest-first
- Internal links use `post_url` tags
- No sub-pages unless a project grows complex

## Blog-Specific Style Mechanics

### Long Pull-Out Quotes

Use for passages that are substantial, notable, or central to the post's argument.

Format: Markdown blockquote (`>`), then blank line, then citation line (e.g., `<cite>Author Name</cite>`), also inside blockquote.

Example:

> "There's a new kind of coding I call 'vibe coding,' where you fully give in to the vibes, embrace exponentials, and forget that the code even exists."
>
> <cite>Andrej Karpathy</cite>

Do not invent or paraphrase quotes. If attribution is unclear, raise in chat. Reserve for focal points — do not overuse.

### H1 Usage

One H1 (`#`) only if a legacy post already uses it inside body. Do not add new H1s.

## Social Media Patterns

Generate social posts only when requested, typically at publication time.

### Mastodon (≤500 chars)

Factual pointer; 0-2 hashtags; no CTA unless explicitly asked. Include one concrete hook (stat, question, or contrast). Avoid duplicating the full excerpt. Use the full character limit for engaging, concise summaries. Add URL placeholder if post is live or planned.

### Bluesky (≤300 chars)

Similar to Mastodon. Factual pointer; no CTA. Focus on core insight or hook. Use full character limit.

### LinkedIn

2-4 short paragraphs. Context + 1-3 insights + optional neutral observation. No inflated impact; no invented metrics.

### Hashtags

- Mastodon: 0-4 max, at end. Skip if no discovery value.
- Bluesky: 0-2 max, at end.
- LinkedIn: 2-4 concise, high-signal at end after blank line. Prefer topic/category over slogans.
- Do not embed hashtags mid-sentence.

### Formatting

Body text, then blank line, then URL (or placeholder), then blank line, then hashtags. Do not use Markdown formatting (bold, italics, links) — these platforms don't support it. Write as cut-and-paste ready. Ignore markdown linting errors in social sections; they are ephemeral.

## Blog-Specific Verification Checks

In addition to universal verification (see AGENTS-writing.md), check:
- Excerpt <140 chars & factual: Y/N
- Disclaimer present exactly once if needed: Y/N
- Social outputs within character limits: Y/N/N-A
- Internal links use `post_url` tag: Y/N
- `header` includes attribution where required: Y/N/N-A

End of PROJECT_CONTEXT.md
