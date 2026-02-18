# STYLE CAPSULE (Portable Voice & Tone Guidance)

Purpose: Minimal, context-agnostic packet to hand any assistant for one-off rewrites (emails, short memos, comment replies) without pulling in full workflows from AGENTS-writing.md.

## Voice Core

- Direct, concise, mildly dry; plain verbs over jargon.
- Anti-hype: avoid "revolutionary", "game-changing", performative enthusiasm.
- First person singular ("I") unless collaboration is explicitly stated in source.
- Avoid semicolons; split into two sentences or use a spaced hyphen instead.
- Friction allowed if factual; no corporate polish for its own sake.
- Preserve hedges ("probably", "roughly"); never upgrade uncertainty.
- Terminology: write "open source" as two words, lowercase, no hyphen, even as an adjective ("open source project"). Only retain a hyphen if part of a quoted title, proper noun, or URL.

## Do / Emphasize

- Clarify purpose early (add a 1-line purpose only if unmistakably evident; otherwise ask).
- Collapse repetition and meandering intros.
- Surface constraints or trade-offs succinctly.
- Keep original commitments, dates, metrics exactly.
- If something feels weakly supported: keep the text and raise the concern (unless user asked for clean output).

## Avoid / Red Lines

- Adding new facts, metrics, names, quotes, promises, or timelines.
- Inflating tone ("super excited", "thrilled") unless present in source.
- Passive filler and throat-clearing ("Just reaching out to say…").
- Converting a single anecdote into a generalized claim.

## Structure Preferences

- Paragraphs: 2-5 sentences max; break long ones.
- Use spaced single hyphens for quick asides ("idea - caveat"), not em dashes.
- An ellipsis is always three periods set apart from the preceding and succeeding words by a space (e.g., "This ... or that").
- Bullets acceptable for enumerations; fragments allowed.
- Remove redundant openings and closings unless they carry social intent.

## Handling Uncertainty

- Do NOT guess missing data (names, dates, counts). Ask instead.
- If purpose cannot be inferred confidently, ask rather than assuming.

## Challenge Protocol (Condensed)

1. If a claim seems shaky, retain text and propose a leaner neutral alternative, or raise the concern.
2. One nudge only — don't enter debate mode unless asked.

## Execution Mode

- Preserve: meaning, factual content, intent, commitments, hedges.
- Transform: clarity, brevity, structure, tone alignment.
- If source already meets capsule: return MINIMAL CHANGE plus lightly cleaned version.

## Quick Prompt Template

```text
Rewrite the text below using the STYLE CAPSULE. Preserve all facts, commitments, and hedges. Flag ambiguities or unsupported claims. Do not add a CTA. Return only rewritten text plus any concerns.

[PASTE STYLE CAPSULE]

[RAW TEXT]
```

## When NOT to Use This Capsule

- Full blog post or structured content → use AGENTS-writing.md (and PROJECT_CONTEXT.md if available).
- Legal/contract language → requires separate precision rules.
- Large, fragmented brain dump → outline first (not a straight rewrite).

## Relationship to AGENTS-writing.md

This capsule is a distilled version of the voice and tone guidance in AGENTS-writing.md, designed for quick, context-agnostic rewrites. Significant updates to voice or tone in either document should be reflected in the other.

End of STYLE CAPSULE.
