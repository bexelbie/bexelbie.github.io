# Agent Guidance: Voice, Integrity, and Workflow (General Blog Use)

This document defines how automated assistants ("agents") collaborate on drafting, revising, summarizing, or refactoring ANY blog content in this repository (technical, event reports, opinion pieces, travel, notes, meta-posts, link posts, social snippets). It encodes style, constraints, challenge rules, and delivery workflows. Treat it as the contract. When in doubt: do not guess — surface uncertainty.

---

## 1. Core Principles

- Fact over flourish; no invented context.
- Minimize assumptions; explicitly label uncertainty.
- Challenge unsupported assertions (politely, briefly) with an evidence nudge.
- Prefer lean prose; delete redundancy before adding adjectives.
- Preserve author voice (informal, sometimes wry) while avoiding performative “thought leadership.”
- Never smooth edges into corporate PR. Friction is allowed if factual.
- Do not generalize one anecdote into a trend unless notes state the trend.

Important restrictions on quoted text and code

- Text that appears inside block quotes or that is explicitly quoted from another person or source must not be altered. These are other people's words; keep them verbatim. If the quoted text contains an error or you believe clarification is needed, do not rewrite the quote — add a parenthetical note such as "(sic)" immediately after the quoted text or add a brief clarifying note outside the quote. Mark any uncertainty with the repository's markers (for example, `[UNCLEAR attribution?]`).

- Code appearing inside fenced code blocks (triple-backtick blocks, indented code blocks, or language-tagged blocks) SHOULD NEVER BE CHANGED. Code blocks are executable or prescriptive artifacts; editing them can introduce subtle bugs or change intent. If you think a code block contains an error, add a separate comment or note (outside the code block) describing the suspected issue and how to test or fix it rather than modifying the original block.

Markers (use inline, UPPER CASE in brackets):

- `[UNCLEAR]` missing info or ambiguous reference (explain briefly)
- `[CHECK FACT]` needs external verification or citation
- `[ASSUMPTION?]` possible inference—await confirmation
- `[ALT VIEW]` optional contrasting framing the author might want to consider

Agents MUST leave these markers intact unless resolved with explicit new user input or added sources.

---

## 2. Voice & Tone

Universal qualities:

- Direct, concise, grounded. Plain verbs over abstractions.
- Mild dry humor acceptable; no memes, emojis, hype words.
- Use first person singular (“I”) for personal experience; avoid “we” unless collaboration or community consensus is explicit in the source material.
- Avoid unrequested calls to action.
- Avoid semicolons unless present in original text; prefer splitting into shorter sentences.
- Use spaced single hyphens for asides instead of em dashes to match author preference (e.g., "this - not that").
- An ellispsis is always three periods set apart from the preceeding and succeeding words by a space (e.g., "This ... or that").

Content‑type modulation (see Section 4 for types):

- Technical / Analytical: tighter paragraphs, emphasize constraints, trade‑offs, and failure modes.
- Event Report: chronological skeleton + synthesis of value; avoid travelogue filler unless contextually relevant.
- Opinion / Editorial: clear thesis early; separate fact claims from value judgments.
- Travel / Personal: small sensory details ok; still avoid purple prose.
- Link / Pointer Post: minimal framing + why it matters + one takeaway.
- Raw Notes → Polished: compress repetition; preserve stated uncertainties; never upgrade a tentative statement to certainty.

Disallowed tone patterns:

- Hype (“game‑changing”, “revolutionary”) unless quoting others (quote + source).
- Artificial urgency (“must read”) without explicit justification.
- Vague collectivization (“we all know”) — replace with sourced or personal statement.

---


## 3. Style Mechanics

Paragraphs: 2–5 sentences; break longer sequences.
Excerpt (YAML `excerpt`): single factual sentence <140 chars; no evaluative adjectives unless necessary for precision.
Headings: `##` for major sections only; avoid trailing punctuation. One H1 (`#`) only if legacy post already uses it inside body—do not add new H1s.
Lists: concise; prefer fragments over full sentences when readable.
Emphasis: sparing *italics*; avoid bold except when already present historically.
Inline code / terms: backticks for commands, filenames, literals. No shell prompts inside code spans.
Code blocks: only when code or multi‑line command is essential. Language tag if fenced.
Links: prefer descriptive text over bare URLs; avoid link stuffing.
Internal post links: use Jekyll `post_url` Liquid tag instead of hard-coded paths. Pattern: write the markdown link with the Liquid tag inside the parentheses. Example (shown escaped so it won’t resolve): ``[she speaks Czech]({% post_url 2025-09-17-Microsoft-hackathon-3 %})``. If the target post does not exist yet, add an inline marker `[UNCLEAR link target?]` immediately after the link until created.
Numbers: supply source if potentially contested (mark `[CHECK FACT]` if missing).
Images: always include alt text in markdown image OR mention context in caption (see Section 9).
Terminology: use “open source” as two words, lowercase, and unhyphenated even when used adjectively (e.g., “open source community”, “open source policy”). Do NOT change it inside proper nouns, event names, direct quotations, or URLs. Avoid “open-source” except when preserving an original quoted title.


### Long Pull-Out Quotes

Use long pull-out quotes for passages that are substantial, notable, or central to the post’s argument or theme. These are typically multi-line quotations from external sources or individuals (e.g., Andrej Karpathy, Simon Willison) that merit visual emphasis and separation from the main text.

- Format: Use Markdown blockquote syntax (`>` at the start of each quoted line). Place the quote on its own, then insert a blank line, then the citation line (e.g., `<cite>Author Name</cite>`), also inside the blockquote.
- Do not use bold or italics for the quote body unless present in the original.
- Only use pull-out quotes for material that is worth highlighting; do not convert routine inline quotes or short phrases into blockquotes.
- Inline quoting remains appropriate for brief references, partial sentences, or when the quote is not a central argument.
- Do not invent or paraphrase quotes; always use the original wording and attribute clearly.
- If the source or attribution is unclear, append `[UNCLEAR attribution?]` after the citation.

Example:

> "There's a new kind of coding I call 'vibe coding,' where you fully give in to the vibes, embrace exponentials, and forget that the code even exists."
>
> <cite>Andrej Karpathy</cite>

For multi-paragraph quotes, repeat the `>` at the start of each paragraph.

Do not overuse pull-out quotes; reserve for cases where the quote itself is a focal point or provides unique insight.

---

## 4. Content Types & Required Elements

1. Technical / Analytical
   - Mandatory: problem framing, constraints, trade‑offs, (if present) failure modes.
   - Optional: minimal reproduction snippet (only if notes explicitly include or request).
2. Event Report
   - Include: purpose of event, structure, 2–6 key takeaways (bullet list), notable gaps.
   - Avoid exhaustive session blow‑by‑blow unless uniquely insightful.
3. Opinion / Editorial
   - Early thesis, evidence separation, at least one acknowledgment of alternate perspective (`[ALT VIEW]` if not elaborated).
4. Travel / Experience
   - Focus on observation > cliché sentiment. Skip generic “beautiful”, prefer a concrete detail.
5. Link / Pointer
   - 1–2 sentence context + why it matters + optional contrasting link.
6. Personal Notes / Journaling
   - Convert timestamp bullets into thematic clusters; keep raw form only if user explicitly requests.
7. Meta / Process Post
   - Clearly label scope (what changed, why, what’s next when known; omit speculation when unknown).
8. Announcement
   - Stick to verifiable facts, timeline, actionable implications. If future work uncertain → `[UNCLEAR]`.

If content does not fit, declare `[UNCLEAR: content type?]` and propose classification.

---

## 5. Integrity & Fact Handling

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

## 6. Front Matter & Metadata Rules

Do NOT alter existing YAML key names unless explicitly requested.

Required keys for new posts (current practice):

- `title`
- `date` (see Section 6.1 for format & rounding)
- `excerpt` (fill with a factual <140 char sentence; leave empty string only if explicitly directed)

Intentionally NOT used anymore: `categories`, `tags`.

- If legacy posts contain them, leave as-is; do not add to new posts.
- Do not attempt to auto-classify or backfill categories/tags.

Optional keys when relevant:

- `header` (see Section 6.2 for when and how)
- `redirect_from` (only for migrated / renamed slugs)
- `layout`, `author_profile`, etc. rely on `_config.yml` defaults—avoid redefining unless changing behavior.

Prohibited additions: analytics IDs, tracking parameters, marketing campaign tags.

Slug: determined by filename (`YYYY-MM-DD-slug.md`). Never rename existing slugs without explicit instruction (would break inbound links).

Timezone: site config sets `Europe/Prague`; honor DST (CET = UTC+1 standard, CEST = UTC+2 summer).

### 6.1 Date & Time Standard (Autogeneration Rule)

When creating a new draft/post unless a date is already provided, compute:

1. Current time in `Europe/Prague`.
2. Round UP to the next 10‑minute boundary (e.g., 14:03 → 14:10; 14:10 stays 14:10; 14:59 → 15:00).
3. Set seconds to `00`.
4. Use the appropriate offset (`+0100` or `+0200`) based on whether Prague is in DST.

Format (placed after rounding): `YYYY-MM-DD HH:MM:00 +ZZZZ` (four‑digit numeric offset, no colon) matching existing post style.

If user supplies a date/time, preserve it verbatim except to normalize zero‑padded month/day (e.g., `2025-8-5` → `2025-08-05`) unless explicitly told not to.

### 6.2 `header` Usage Guidelines

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

### 6.3 Excerpt

- Must stand alone out of context (feed readers, social cards).
- Avoid subjective adjectives unless precision requires (e.g., “five focusing steps” is fine; avoid “powerful five focusing steps”).
- If summarizing a list (book notes, principles) → name the framework + action (“Key takeaways from X: focus steps, change questions, education vs training insight.”)
- **Inject a hint of the post’s tone or personality when appropriate** (e.g., “A whimsical moment observing a retired couple’s daily ritual and a surprise silly hat.”).
- Do NOT mechanically repeat the title or its opening label (e.g., do not start the excerpt with “Day 3:” if the title already contains it). Provide a complementary angle: highlight the core outcome, tension, or delta from plan rather than restating nouns from the title.
- For a multi-day series, use the excerpt to surface what changed or progressed vs. earlier days (e.g., “Scaled up parsing and swapped JSON scans for SQLite” not “More work on parsing”).

---

## 7. Disclaimers

Use a disclaimer exactly once when:

- Employer, client, or affiliation is referenced or contextually relevant; OR
- Post builds on prior series that already used a disclaimer.

Canonical text (choose ONE standard—ask if change desired):
> Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

If earlier post variant differs slightly (“personal opinions”), standardize unless user instructs to preserve historical wording in a multi‑part series.
Do NOT add if neither employer nor sensitive topic appears.

---

## 8. Workflows & Prompts

DEFAULT MODE: When the user supplies raw notes, proceed directly to a Full Draft (Section 8.2) unless the user explicitly asks for an outline first OR the notes exceed ~900 words and are highly fragmented—in that case propose an Outline (Section 8.1) before drafting. Err on shipping a usable draft quickly.

### 8.1 Outline Extraction (only when requested or pre‑agreed)

Output: concise bullet list of proposed sections + open questions + unresolved markers; no prose paragraphs.

### 8.2 Full Draft

Inputs: raw notes (possibly messy) + any existing front matter.

Actions:

- Normalize front matter per Section 6 (date rounding, excerpt check, no categories/tags).
- Draft ≤900 words unless user sets a different ceiling.
- Preserve hedges; insert markers where needed.
- Append Verification Checklist + Clarifications Requested.

### 8.3 Condense

- Produce ≤350 word version; mark any materially dropped section with `[DROPPED:<short label>]` at end.

### 8.4 Expand

- Only elaborate on points already present. If user requests new angle not in source → ask or mark `[ASSUMPTION?]`.

### 8.5 Refactor Tone

- Adjust density, directness, or structure without introducing new claims.

### 8.6 Summarize Series

- List posts + one‑line factual takeaway each. No synthetic narrative beyond provided material.

### 8.7 Social Post Generation

- Produce Mastodon + LinkedIn variants (Section 11) referencing final draft content only.

### 8.8 Gap Analysis

- Provide **Gaps** section enumerating missing data that would strengthen argument; do not fill.

Delivery order for a Full Draft output: Front matter (unchanged except normalized) → Body → (optional) Social variants → Verification Checklist → Clarifications Requested.

---

## 9. Media & Accessibility

Images:

- Always ensure descriptive alt text or a caption that conveys purpose, not redundant “Image of…”.
- If alt missing in source and meaning unclear → add `[UNCLEAR alt text?]`.
Code screenshots: prefer text snippets unless image carries unique visual context.
Avoid ASCII art for structure; use lists / headings.

---

## 10. Markers & Resolution

Leave markers untouched until explicitly resolved by user reply or added citation.
Resolution steps:

- Replace marker with sourced fact (add link) OR
- Remove claim if unsourceable and nonessential OR
- Keep marker if still pending.
Never silently drop a marker.

---

## 11. Social Media Patterns

Mastodon (≤500 chars): factual pointer; at most 0–2 hashtags; no CTA unless user explicitly asks. Include one concrete hook (stat, question, or contrast) from post; avoid duplicate full excerpt. **Use the full character limit when possible to craft engaging, concise summaries that reflect the post’s tone. Add a URL placeholder if the post is live or planned.**

LinkedIn: 2–4 short paragraphs; mention context + 1–3 insights + optional neutral observation; no inflated impact; no invented metrics.

Hashtags:

- Mastodon: 0-4 relevant hashtags max; place at end; skip if they add no discovery value.
- LinkedIn: 2–4 concise, high-signal hashtags at end (after an empty line). Avoid novelty or vanity tags; prefer topic/category (#Hackathon, #OpenSource, #Debian, #AI) over slogans.
- Do not embed hashtags mid-sentence unless quoting or unavoidable; preserve readability.
- Formatting: keep social body text, then a blank line, then the URL (or placeholder), then a blank line, then the hashtags on a line. Don't worry about escaping or otherwise fencing anything.  The social section should be written as a cut and paste, the user will deal with it.

Optional Additional Formats (on request only):

- Thread Outline (numbered bullets ≤5) – each bullet <240 chars.
- Alt Excerpt Variants – up to 3 factual rewrites.

---

## 12. Challenge & Feedback Protocol

When a claim seems weakly supported:

1. Keep original wording (unless unsafe / defamatory) but append `([CHECK FACT] rationale?)` OR propose lean alternative.
2. Provide a concise rationale in Clarifications section. Avoid debate unless user invites deeper dive.
3. If user rejects challenge, remove marker and proceed—do not re-litigate unless new contradictory data arises.

---

## 13. Verification Checklist (Attach to Drafts)

- Fabrication introduced: Y/N
- All markers (`[UNCLEAR]`, `[CHECK FACT]`, etc.) enumerated: Y/N (list count)
- Disclaimer present exactly once if needed: Y/N
- Excerpt <140 chars & factual: Y/N
- Tone matches content type table: Y/N
- Hype terms present? (list or “None”)
- Image alt text present where images used: Y/N/N-A
- Social outputs within limits: Y/N/N-A

---

## 14. Formatting Safeguards

- Never modify YAML key names; only values if instructed.
- Preserve trailing newline.
- Avoid mass reflow; limit edits to necessary spans.
- Do not convert legacy inline H1 sections unless user requests cleanup.

---

## 15. Quick Reference (Cheat Sheet)

Tone: direct, factual, occasional dry humor.
Required front matter: title, date (rounded next 10 min Prague), excerpt.
No categories/tags on new posts (leave legacy alone).
Header: only when image adds substantive context (book cover, original photo, key diagram, etc.).
Date rule: round up to next 10‑minute mark; correct DST offset.
Markers: `[UNCLEAR]` `[CHECK FACT]` `[ASSUMPTION?]` `[ALT VIEW]`.
Default workflow: Raw notes → Full Draft.
Max standard draft length: 900 words (unless specified).
Social: Mastodon ≤500 chars, ≤2 hashtags. LinkedIn: no hype.
Disclaimer: once only when relevant.
Never invent anything. Surface uncertainty.

---

## 16. Evolution of This File

Append dated **Changelog** entries for substantive shifts. Do not retroactively rewrite history; clarify intent.

### Changelog

- 2025-09-17: Initial creation (generalized guidance for all blog content; includes removal of categories/tags requirement, header usage rules, date rounding protocol, and default raw-notes→draft workflow; merged and expanded prior hackathon-focused draft into unified style & integrity rules).

---

## Evolution of Guidance

### Updates to STYLE CAPSULE

When making changes to `AGENTS.md`, consider whether the `STYLE-CAPSULE.md` requires updates to maintain alignment. The STYLE CAPSULE is a condensed version of this document for one-off rewrites and should reflect any significant shifts in tone, markers, or execution protocols.

---

End of AGENTS.md
