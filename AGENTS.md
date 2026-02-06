# Agent Guidance: Voice, Integrity, and Workflow

This document defines how automated assistants ("agents") collaborate on drafting, revising, summarizing, or refactoring content in this repository, as well as maintaining the site structure. While the repository focuses on a blog, it is also a workspace for talks, deep dives, and private notes.

This guidance is split into **Technical Context**, **Universal Principles**, and **Work Modes**.

Treat this as the contract. When in doubt: do not guess — surface uncertainty.

---

## 0. Agent Operating Defaults (Security + Workflow)

These defaults apply everywhere in this repo unless a section below explicitly overrides them.

- **Prefer edits over advice:** If the request implies an action (add/fix/refactor/format), make the smallest necessary change in the project rather than describing how.
- **Be brief by default:** Keep responses tight; only expand when the user asks for depth or when ambiguity must be surfaced.
- **Inspect before acting:** Use the repository as the source of truth; do not ask the user to paste files that exist in the repo.
- **Minimal blast radius:** Avoid drive-by cleanups; change only what’s needed for the user’s request or to resolve observed errors.


---

## 1. Technical & Project Context

### Build & Run
- **Environment:** Ruby 3.4 required.
- **Install:** `bundle install`
- **Serve:** `bundle exec jekyll serve` (or `chruby 3.4; bundle exec jekyll serve`).
- **Structure:** Standard Jekyll + Remote Theme (`mmistakes/minimal-mistakes`). `_layouts/` and `_sass/` are generally absent (unless locally overriding).

### Coding Conventions
- **Links:** ALWAYS use the Liquid tag for internal posts: `[Link Text]({% post_url yyyy-mm-dd-slug %})`.
- **Front Matter:** Respect defaults in `_config.yml` (Posts: `layout: single`, `author_profile: true`).
- **Dates/Time:** Strict `Europe/Prague` timezone.
- **Components:** `_includes/` contains specific overrides. Use pure HTML/Liquid there.

---

## 2. Core Principles

- Fact over flourish; no invented context.
- Minimize assumptions; explicitly label uncertainty.
- Challenge unsupported assertions (politely, briefly) with an evidence nudge.
- Prefer lean prose; delete redundancy before adding adjectives.
- Preserve author voice (informal, sometimes wry) while avoiding performative “thought leadership.”
- Never smooth edges into corporate PR. Friction is allowed if factual.
- Do not generalize one anecdote into a trend unless notes state the trend.

### Important restrictions on quoted text and code

- Text that appears inside block quotes or that is explicitly quoted from another person or source must not be altered. These are other people's words; keep them verbatim. If the quoted text contains an error or you believe clarification is needed, do not rewrite the quote — add a parenthetical note such as "(sic)" immediately after the quoted text or add a brief clarifying note outside the quote. Mark any uncertainty with the repository's markers (for example, `[UNCLEAR attribution?]`).

- Code appearing inside fenced code blocks (triple-backtick blocks, indented code blocks, or language-tagged blocks) SHOULD NEVER BE CHANGED. Code blocks are executable or prescriptive artifacts; editing them can introduce subtle bugs or change intent. If you think a code block contains an error, add a separate comment or note (outside the code block) describing the suspected issue and how to test or fix it rather than modifying the original block.

### Markers (use inline, UPPER CASE in brackets)

- `[UNCLEAR]` missing info or ambiguous reference (explain briefly)
- `[CHECK FACT]` needs external verification or citation
- `[ASSUMPTION?]` possible inference—await confirmation
- `[ALT VIEW]` optional contrasting framing the author might want to consider

Agents MUST leave these markers intact unless resolved with explicit new user input or added sources.

---

## 3. Voice & Tone

**Primary Source:** Refer to `STYLE-CAPSULE.md` in this repository for all core voice, tone, and style constraints.

---

## 4. Style Mechanics

Excerpt (YAML `excerpt`): single factual sentence <140 chars; no evaluative adjectives unless necessary for precision.
Headings: `##` for major sections only; avoid trailing punctuation. One H1 (`#`) only if legacy post already uses it inside body—do not add new H1s.
Lists: concise; prefer fragments over full sentences when readable.
Emphasis: sparing *italics*; avoid bold except when already present historically.
Inline code / terms: backticks for commands, filenames, literals. No shell prompts inside code spans.
Code blocks: only when code or multi‑line command is essential. Language tag if fenced.
Links: prefer descriptive text over bare URLs; avoid link stuffing.
Internal post links: use Jekyll `post_url` Liquid tag instead of hard-coded paths. Example (escaped so it won’t resolve): ``[she speaks Czech]({% post_url 2025-09-17-Microsoft-hackathon-3 %})``. If the target post does not exist yet, add an inline marker `[UNCLEAR link target?]` immediately after the link until created.
Numbers: supply source if potentially contested (mark `[CHECK FACT]` if missing).
Images: always include alt text in markdown image OR mention context in caption.

### Long Pull-Out Quotes

Use long pull-out quotes for passages that are substantial, notable, or central to the post’s argument or theme.

- Format: Use Markdown blockquote syntax (`>`). Put the quote on its own, then a blank line, then a citation line (e.g., `<cite>Author Name</cite>`), also inside the blockquote.
- Do not invent or paraphrase quotes; use original wording and attribute clearly.
- If the source or attribution is unclear, append `[UNCLEAR attribution?]` after the citation.

Example:

> "There's a new kind of coding I call 'vibe coding,' where you fully give in to the vibes, embrace exponentials, and forget that the code even exists."
>
> <cite>Andrej Karpathy</cite>

For multi-paragraph quotes, repeat the `>` at the start of each paragraph.

Do not overuse pull-out quotes; reserve for cases where the quote itself is a focal point or provides unique insight.

---

## 5. The Router: Determining Work Mode

Most work begins in `_drafts/` and may never be published. Agents must determine the **Work Mode** based on user intent.

### 5.1 Default: Deep Work / Private Mode

**Trigger:** User provides raw notes, asks for a summary, or works in `_drafts/` without explicit publication instructions.
**Goal:** Clarity, structure, and rigorous thinking. No performative formatting.
**Constraints:**

- **Length:** Unlimited.
- **Front Matter:** Minimal (Title/Date only). No rounding, no excerpts.
- **Socials:** None.
- **Tone:** Candid, precise, "thinking in public."

### 5.2 Mode: Public Talk

**Trigger:** User says "Draft a talk," "Create slides," or works in `talks/`.
**Goal:** Spoken rhythm, visual support, audience connection.
**Components:**

- **Abstract:** Compelling hook for organizers/attendees.
- **Slides:** High signal, minimal text. **NEVER edit code blocks in slides.**
- **Speaker Notes:** Conversational, transition cues. No length limit.

### 5.3 Mode: Blog Post (Publication)

**Trigger:** User says "Ready to publish," "Make this a post," "Draft for the blog," or moves file to `_posts/`.
**Constraints:** Ideally 900 words or more. Flag if overly short (insufficient depth) or overly long (needs tightening). Full Front Matter, Socials required.

**Blog Content Types & Required Elements:**

1. **Technical / Analytical**
   - Tone: Tighter paragraphs; emphasize constraints, trade-offs, and failure modes.
   - Mandatory: problem framing, constraints, trade‑offs, (if present) failure modes.
   - Optional: minimal reproduction snippet (only if notes explicitly include or request).
2. **Event Report**
   - Tone: Chronological skeleton + synthesis of value; avoid travelogue filler unless contextually relevant.
   - Include: purpose of event, structure, 2–6 key takeaways (bullet list), notable gaps.
   - Avoid exhaustive session blow‑by‑blow unless uniquely insightful.
3. **Opinion / Editorial**
   - Tone: Clear thesis early; separate fact claims from value judgments.
   - At least one acknowledgment of alternate perspective (`[ALT VIEW]` if not elaborated).
4. **Travel / Experience**
   - Tone: Small sensory details ok; still avoid purple prose.
   - Focus on observation > cliché sentiment. Skip generic “beautiful”, prefer a concrete detail.
5. **Link / Pointer**
   - Tone: Minimal framing + why it matters + one takeaway.
   - 1–2 sentence context + why it matters + optional contrasting link.
6. **Meta / Process Post**
   - Clearly label scope (what changed, why, what’s next when known; omit speculation when unknown).
7. **Announcement**
   - Stick to verifiable facts, timeline, actionable implications. If future work uncertain → `[UNCLEAR]`.

If content does not fit, declare `[UNCLEAR: content type?]` and propose classification.

---

## 6. Integrity & Fact Handling

Never invent: people, dates, metrics, venues, code, attributions, quotes.
Do not silently “upgrade” hedges (“maybe”, “roughly”) to precise claims.
If a statistic appears without source and is nontrivial → append `[CHECK FACT]`.
Disputed / contestable claim? Suggest a neutral rephrase; optionally supply `[ALT VIEW]` stub.
If user supplies partial quote without source, retain quote + mark `[CHECK FACT source]`.

Escalation protocol:
1. Identify ambiguous or unsupported claim.
2. Decide: remove? mark? request? → Prefer marking unless clearly erroneous.
3. Surface concise question at end under **Clarifications Requested**.

---

## 7. Front Matter & Metadata Rules

Do NOT alter existing YAML key names unless explicitly requested.

**For Deep Work / Private Mode:**
- Minimal keys only: `title`, `date`.
- No rounding, no excerpts, no social images.

**For Blog Mode (Publication):**
Required keys for new posts:
- `title`
- `date` (see Section 7.1 for format & rounding)
- `excerpt` (fill with a factual <140 char sentence; leave empty string only if explicitly directed)

Intentionally NOT used anymore: `categories`, `tags`.
- If legacy posts contain them, leave as-is; do not add to new posts.

Optional keys when relevant:

- `header` (see Section 6.2 for when and how)
- `redirect_from` (only for migrated / renamed slugs)
- `layout`, `author_profile`, etc. rely on `_config.yml` defaults—avoid redefining unless changing behavior.

Prohibited additions: analytics IDs, tracking parameters, marketing campaign tags.

Slug: determined by filename (`YYYY-MM-DD-slug.md`). Never rename existing slugs without explicit instruction (would break inbound links).

Timezone: site config sets `Europe/Prague`; honor DST (CET = UTC+1 standard, CEST = UTC+2 summer).

### 7.1 Date & Time Standard (Autogeneration Rule)

When creating a new draft/post unless a date is already provided, compute:
1. Current time in `Europe/Prague`.
2. Round UP to the next 10‑minute boundary.
3. Set seconds to `00`.
4. Use the appropriate offset (`+0100` or `+0200`) based on whether Prague is in DST.

Format: `YYYY-MM-DD HH:MM:00 +ZZZZ`.

If user supplies a date/time, preserve it verbatim except to normalize zero‑padded month/day (e.g., `2025-8-5` → `2025-08-05`) unless explicitly told not to.

### 7.2 `header` Usage Guidelines

Include a `header` block ONLY when a visual element materially aids context, recognition, or accessibility. Otherwise omit to reduce visual noise.

Use cases to include:

- Referencing a book, event, product, location, or artifact where the cover/photo meaningfully anchors the topic (e.g., book notes like the *The Goal* example).
- Original photography that adds context to travel, event, or observational posts.
- Diagrams or visuals central to argument (must also appear inline or be described for accessibility).

Avoid using `header` when:

- Pure opinion/editorial without a concrete visual referent.
- Link/pointer posts with a single external link and minimal commentary.
- Routine note dumps where an image would add decoration only.

`header` keys (Minimal Mistakes pattern):

- `overlay_image`: Preferred primary image (remote URL or local path). Remote allowed if stable; prefer local copy when license permits.
- `og_image`: Match `overlay_image` unless a different aspect ratio is required for social previews.
- `teaser`: Smaller/lower‑weight version when available (optional; fallback permitted).
- `caption`: Attribution and concise description (must include source link when not author’s own). Provide descriptive alt‑style text if the image content conveys information.
- `overlay_filter`: Numeric (0–1) or percentage; keep if text legibility requires. Omit if unnecessary.

Attribution & Licensing:

- Always cite source unless the image is your original work.
- If license requires specific wording and user has not provided it → mark `[UNCLEAR licensing attribution?]` instead of guessing.

Accessibility:

- If the image delivers essential information not restated in body → add a descriptive sentence in body or enrich `caption`.
- If meaning unclear and not decorative → mark `[UNCLEAR alt intent?]`.

Remote Image Stability:

- Favor reputable sources (Open Library, Wikimedia Commons, user’s own domain). If transience risk → suggest downloading locally (do NOT auto‑download—await instruction).

Validation Before Accepting a Provided `header`:

- Check that each provided URL is absolute (starts with `http` or `/`). If missing scheme → flag `[UNCLEAR image URL scheme?]`.
- Ensure caption includes source or “Photo credit: author”. If absent → append `[UNCLEAR attribution?]`.

### 7.3 Excerpt

- Must stand alone out of context (feed readers, social cards).
- Avoid subjective adjectives unless precision requires (e.g., “five focusing steps” is fine; avoid “powerful five focusing steps”).
- If summarizing a list (book notes, principles) → name the framework + action (“Key takeaways from X: focus steps, change questions, education vs training insight.”)
- **Inject a hint of the post’s tone or personality when appropriate** (e.g., “A whimsical moment observing a retired couple’s daily ritual and a surprise silly hat.”).
- Do NOT mechanically repeat the title or its opening label (e.g., do not start the excerpt with “Day 3:” if the title already contains it). Provide a complementary angle: highlight the core outcome, tension, or delta from plan rather than restating nouns from the title.
- For a multi-day series, use the excerpt to surface what changed or progressed vs. earlier days (e.g., “Scaled up parsing and swapped JSON scans for SQLite” not “More work on parsing”).

---

## 8. Disclaimers

Use a disclaimer exactly once when:

- Employer, client, or affiliation is referenced or contextually relevant; OR
- Post builds on prior series that already used a disclaimer.

Canonical text (choose ONE standard—ask if change desired):
> Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

If earlier post variant differs slightly (“personal opinions”), standardize unless user instructs to preserve historical wording in a multi‑part series.
Do NOT add if neither employer nor sensitive topic appears.

---

## 9. Workflows & Prompts

DEFAULT MODE: See Section 5. Unless specified, assume **Deep Work Mode**.

### 9.1 Outline Extraction (only when requested or pre‑agreed)

Output: concise bullet list of proposed sections + open questions + unresolved markers; no prose paragraphs.

### 9.2 Full Draft

Inputs: raw notes (possibly messy) + any existing front matter.

Actions:

- Normalize front matter per Section 7.
- Draft to ideal length (900+ words). Flag if <700 words (too short?) or >1500 words (needs tightening?).
- Preserve hedges; insert markers where needed.
- Append Verification Checklist + Clarifications Requested.

### 9.3 Condense

- Produce ≤350 word version; mark any materially dropped section with `[DROPPED:<short label>]` at end.

### 9.4 Expand

- Only elaborate on points already present. If user requests new angle not in source → ask or mark `[ASSUMPTION?]`.

### 9.5 Refactor Tone

- Adjust density, directness, or structure without introducing new claims.

### 9.6 Summarize Series

- List posts + one‑line factual takeaway each. No synthetic narrative beyond provided material.

### 9.7 Social Post Generation

- Produce Mastodon + LinkedIn variants (Section 11) referencing final draft content only.

### 9.8 Gap Analysis

- Provide **Gaps** section enumerating missing data that would strengthen argument; do not fill.

Delivery order for a Full Draft output: Front matter (unchanged except normalized) → Body → (optional) Social variants → Verification Checklist → Clarifications Requested.

---

## 10. Media & Accessibility

Images:

- Always ensure descriptive alt text or a caption that conveys purpose, not redundant “Image of…”.
- If alt missing in source and meaning unclear → add `[UNCLEAR alt text?]`.
Code screenshots: prefer text snippets unless image carries unique visual context.
Avoid ASCII art for structure; use lists / headings.

---

## 11. Markers & Resolution

Leave markers untouched until explicitly resolved by user reply or added citation.
Resolution steps:

- Replace marker with sourced fact (add link) OR
- Remove claim if unsourceable and nonessential OR
- Keep marker if still pending.
Never silently drop a marker.

---

## 12. Social Media Patterns

Mastodon (≤500 chars): factual pointer; at most 0–2 hashtags; no CTA unless user explicitly asks. Include one concrete hook (stat, question, or contrast) from post; avoid duplicate full excerpt. **Use the full character limit when possible to craft engaging, concise summaries that reflect the post’s tone. Add a URL placeholder if the post is live or planned.**

Bluesky (≤300 chars): similar to Mastodon; factual pointer; no CTA. Focus on the core insight or hook. **Use the full character limit to craft engaging, concise summaries.**

LinkedIn: 2–4 short paragraphs; mention context + 1–3 insights + optional neutral observation; no inflated impact; no invented metrics.

Hashtags:

- Mastodon: 0-4 relevant hashtags max; place at end; skip if they add no discovery value.
- Bluesky: 0-2 relevant hashtags max; place at end.
- LinkedIn: 2–4 concise, high-signal hashtags at end (after an empty line). Avoid novelty or vanity tags; prefer topic/category (#Hackathon, #OpenSource, #Debian, #AI) over slogans.
- Do not embed hashtags mid-sentence unless quoting or unavoidable; preserve readability.
- Formatting: keep social body text, then a blank line, then the URL (or placeholder), then a blank line, then the hashtags on a line. **Do not use Markdown formatting (bold, italics, links) as these platforms do not support it.** Don't worry about escaping or otherwise fencing anything. The social section should be written as a cut and paste, the user will deal with it. Ignore markdown linting errors in this section; these suggestions are ephemeral and not part of the permanent file.

Optional Additional Formats (on request only):

- Thread Outline (numbered bullets ≤5) – each bullet <240 chars.
- Alt Excerpt Variants – up to 3 factual rewrites.

---

## 13. Challenge & Feedback Protocol

When a claim seems weakly supported:

1. Keep original wording (unless unsafe / defamatory) but append `([CHECK FACT] rationale?)` OR propose lean alternative.
2. Provide a concise rationale in Clarifications section. Avoid debate unless user invites deeper dive.
3. If user rejects challenge, remove marker and proceed—do not re-litigate unless new contradictory data arises.

---

## 14. Verification Checklist (Attach to Drafts)

- Fabrication introduced: Y/N
- All markers (`[UNCLEAR]`, `[CHECK FACT]`, etc.) enumerated: Y/N (list count)
- Disclaimer present exactly once if needed: Y/N
- Excerpt <140 chars & factual: Y/N
- Tone matches content type table: Y/N
- Hype terms present? (list or “None”)
- Image alt text present where images used: Y/N/N-A
- Social outputs within limits: Y/N/N-A

---

## 15. Formatting Safeguards

- Never modify YAML key names; only values if instructed.
- Preserve trailing newline.
- Avoid mass reflow; limit edits to necessary spans.
- Do not convert legacy inline H1 sections unless user requests cleanup.

---

## 16. Quick Reference (Cheat Sheet)

Tone: direct, factual, occasional dry humor.
Modes: **Deep Work** (default, unlimited), **Blog** (900w, strict), **Talk** (slides/notes).
Required front matter (Blog): title, date (rounded next 10 min Prague), excerpt.
No categories/tags on new posts (leave legacy alone).
Header: only when image adds substantive context (book cover, original photo, key diagram, etc.).
Date rule: round up to next 10‑minute mark; correct DST offset.
Markers: `[UNCLEAR]` `[CHECK FACT]` `[ASSUMPTION?]` `[ALT VIEW]`.
Default workflow: Raw notes → Deep Work (clean up) OR Blog Draft (if requested).
Draft length (Blog): Ideally 900+ words. Flag if <700 or >1500.
Social: Mastodon ≤500 chars, ≤2 hashtags. LinkedIn: no hype.
Disclaimer: once only when relevant.
Never invent anything. Surface uncertainty.

End of AGENTS.md
