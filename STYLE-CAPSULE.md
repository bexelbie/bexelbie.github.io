# STYLE CAPSULE (Portable Voice & Tone Guidance)

Purpose: Minimal, context‑agnostic packet to hand any assistant for one‑off rewrites (emails, short memos, comment replies) without pulling in full blog workflows from `AGENTS.md`.

## Voice Core

- Direct, concise, mildly dry; plain verbs over jargon.
- Anti‑hype: avoid “revolutionary”, “game‑changing”, performative enthusiasm.
- First person singular (“I”) unless collaboration is explicitly stated in source.
- Avoid semicolons; split into two sentences or use a spaced hyphen instead.
- Friction allowed if factual; no corporate polish for its own sake.
- Preserve hedges (“probably”, “roughly”); never upgrade uncertainty.
- Terminology: write “open source” as two words, lowercase, no hyphen, even as an adjective ("open source project"). Only retain a hyphen if part of a quoted title, proper noun, or URL.

## Do / Emphasize

- Clarify purpose early (add a 1‑line purpose only if unmistakably evident; else mark `[UNCLEAR purpose?]`).
- Collapse repetition and meandering intros.
- Surface constraints or trade‑offs succinctly.
- Keep original commitments, dates, metrics exactly.
- If something feels weakly supported: keep + append `[CHECK FACT?]` (unless user asked for clean output).

## Avoid / Red Lines

- Adding new facts, metrics, names, quotes, promises, or timelines.
- Inflating tone (“super excited”, “thrilled”) unless present.
- Passive filler and throat‑clearing (“Just reaching out to say…”).
- Converting a single anecdote into a generalized claim.

## Structure Preferences

- Paragraphs: 2–4 sentences max; break long ones.
- Use spaced single hyphens for quick asides ("idea - caveat"), not em dashes.
- Bullets acceptable for enumerations; fragments allowed.
- Remove redundant openings and closings unless they carry social intent.

## Markers

- Ambiguity: `[UNCLEAR:<brief note>]`
- Fact needs verification: `[CHECK FACT?]`
- Inferred but not explicit: `[ASSUMPTION?]`
- Optional alternate framing: `[ALT VIEW]`

Do not delete existing markers unless resolved.

## Handling Uncertainty

- Do NOT guess missing data (names, dates, counts). Mark instead.
- If purpose cannot be inferred confidently → use `[UNCLEAR purpose?]` and leave original line.

## Challenge Protocol (Condensed)

1. If a claim seems shaky, retain text + add `( [CHECK FACT?] )` OR propose a leaner neutral alternative in parentheses.
2. One nudge only—don’t enter debate mode unless asked.

## Execution Mode

- Preserve: meaning, factual content, intent, commitments, hedges.
- Transform: clarity, brevity, structure, tone alignment.
- If source already meets capsule: return `MINIMAL CHANGE` plus lightly cleaned version.

## Quick Prompt Template

```text
Rewrite the text below using the STYLE CAPSULE. Preserve all facts, commitments, and hedges. Mark ambiguities or unsupported claims. Do not add a CTA. Return only rewritten text plus any markers.

[PASTE STYLE CAPSULE]

[RAW TEXT]
```

## When NOT to Use This Capsule

- Full blog post → use `AGENTS.md` workflows.
- Legal/contract language → requires separate precision rules.
- Large, fragmented brain dump → outline first (not a straight rewrite).

## Handling Alignment with AGENTS.md

- Ensure that any significant updates to `AGENTS.md` (e.g., tone, markers, execution protocols) are reflected here if relevant.
- This capsule is a distilled version of `AGENTS.md` for quick, context-agnostic rewrites. It should remain consistent with broader guidance.

End of STYLE CAPSULE.
