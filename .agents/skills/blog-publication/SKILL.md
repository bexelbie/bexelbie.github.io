---
name: blog-publication
description: Use when preparing a blog post for publication — making a draft publication-ready, applying final polish, or running final blog verification. Covers required front matter, the date/time standard, excerpt rules, header/visual guidelines, the disclaimer, length targets, blog-specific style mechanics, and publication checks. Not needed for exploratory drafting.
---

# Blog publication

Apply when bex says a draft is ready to publish, asks to make something a post,
asks for publication polish, or asks for final verification. Most blog work is
exploratory drafting — this skill is for the publication step only.

## Publication-ready front matter

Required keys:
- `title`
- `date` (see Date & time standard)
- `excerpt` (factual sentence, <140 chars; no evaluative adjectives unless necessary for precision)

Optional when relevant:
- `header` (see Header guidelines)
- `redirect_from` (only for migrated / renamed slugs)
- `layout`, `author_profile`, etc. rely on `_config.yml` defaults — avoid redefining unless changing behavior.

`categories`/`tags` are intentionally unused; don't add them to new posts. Prohibited: analytics IDs, tracking parameters, marketing campaign tags.

## Date & time standard

Timezone: `Europe/Prague`. Honor DST (CET = UTC+1, CEST = UTC+2).

When creating a new post and no date is provided:
1. Current time in `Europe/Prague`.
2. Round UP to the next 10-minute boundary.
3. Set seconds to `00`.
4. Use the appropriate offset (`+0100` or `+0200`) based on DST.

Format: `YYYY-MM-DD HH:MM:00 +ZZZZ`.

If bex supplies a date/time, preserve it verbatim except to normalize zero-padded month/day (e.g., `2025-8-5` → `2025-08-05`).

## Excerpt rules

- Must stand alone out of context (feed readers, social cards).
- Avoid subjective adjectives unless precision requires.
- If summarizing a list → name the framework + action.
- Inject a hint of the post's tone when appropriate.
- Do NOT repeat the title or its opening label. Provide a complementary angle.
- For a multi-day series, surface what changed vs. earlier days.

## Header guidelines

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

## Disclaimer

Use exactly once when employer, client, or affiliation is referenced or contextually relevant.

Canonical text:
> Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

If an earlier post in a series uses a slightly different variant, standardize unless instructed to preserve historical wording. Do NOT add if neither employer nor sensitive topic appears.

## Publication standards (length)

Target length: ideally 900+ words. Flag if under 700 (too thin?) or over 1500 (needs tightening?). Full front matter required. Excerpt required.

## Blog-specific style mechanics

### Long pull-out quotes

Use for passages that are substantial, notable, or central to the post's argument.

Format: Markdown blockquote (`>`), then blank line, then citation line (e.g., `<cite>Author Name</cite>`), also inside the blockquote.

Example:

> "There's a new kind of coding I call 'vibe coding,' where you fully give in to the vibes, embrace exponentials, and forget that the code even exists."
>
> <cite>Andrej Karpathy</cite>

Do not invent or paraphrase quotes. If attribution is unclear, raise in chat. Reserve for focal points — do not overuse.

### H1 usage

One H1 (`#`) only if a legacy post already uses it inside body. Do not add new H1s.

### Bold

Avoid bold. Keep bold only where a legacy post already uses it; do not add new bold.

## Blog-specific verification

In addition to the global `writing` skill's universal verification, check:
- Excerpt <140 chars & factual: Y/N
- Disclaimer present exactly once if needed: Y/N
- Social outputs within character limits: Y/N/N-A
- Internal links use `post_url` tag: Y/N
- `header` includes attribution where required: Y/N/N-A
