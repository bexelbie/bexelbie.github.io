---
title: "Day 4: Microsoft Hackathon — Threading Failure, Recursion Repair, and Model Limits"
date: 2025-09-19 00:50:00 +0200
excerpt: "Debugged a broken email threading approach, replaced it with a simple recursive pass, and resumed grading LLM-generated summaries."
---

Today’s work (really posted just after midnight) started smoothly: I pushed a candidate set of mailing‑list threads all the way through summarization to validate the next phase of the pipeline. Then it cratered - duplicate subject lines that exposed my threading logic was flawed.

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

## Test run before failure

I wasn’t choosing “important” threads yet - just seeing what wholesale summarization output looked like so I could later score, filter, and review. That smoke test did its job by flushing out a structural bug instead of letting it lurk until the importance pass.

## The threading bug

I’d tried to get a little “clever” with heuristics while lacking full headers (older emails, inconsistent client behaviors). The result: unrelated conversations collapsed because headers like `In-Reply-To` and `References` were not always present or complete. I also rely on some supplemental external data for stitching things together when the headers fail. Deterministic structure first, cleverness later - apparently I needed to relearn yesterday’s lesson.

## Recursion beats cleverness

I rewrote the logic as a plain recursive rebuild of parent/child relationships using what reliable metadata I do have. This was basically a CS 101 traversal plus extra credit for malformed inputs and odd nesting. The LLM handled the boilerplate once I spelled out the core structural invariant: each message links to at most one parent (by `Message-ID` via `In-Reply-To` / `References`), roots have none, and no cycles. I owned that mental model and the test cases. The model filled in syntax. That division worked. Watching multiple models miss the full shape of the bug was useful: they offered partial patches, none produced the end‑to‑end correction without guided constraints.

## On expectations (and “LLM denying friends”)

To my LLM denying friends (you’re not skeptics and you know it!): nobody promised you could type “make Jira but with cat memes” and go to lunch. Marketing slides might imply that. Reality is still stochastic autocomplete with oversight and bite-sized work needed. It’s good at cranking out a recursive walk or refactoring a loop. It is terrible at handing you judgment, taste, or guardrails. I got cute, collapsed unrelated threads, paid the tax, rewrote it. That’s the actual human‑in‑the‑loop job: think, state the few non‑negotiable structural rules, let the model grind, verify, repeat.

What you *do* get: fast pattern completion over training data. “Traverse this tree and stitch orphan replies” lives there. “Subtly infer intent from half-missing mail headers and not overmerge” does not unless you spell it out. So yes, some of the debugging prompts contained some profanity. That didn’t summon intelligence, it just vented mine.

## What I learned (again)

- Deterministic scaffolding first. Probabilistic layers second.
- “Clever” heuristics without gold tests are debt.
- LLMs are fast at churning variants. They still need a crisp structural rule set to follow or test against.
- A blunt recursive pass is often the right baseline even if it feels unsophisticated.

## Back to the pipeline

With threading fixed I’m back to grading summarization output and preparing the next human‑in‑the‑loop pass for importance ranking. Tomorrow’s goal: start scoring threads with the heuristics + enrichment stack from earlier days and see if explanations remain concise enough not to drown me.

Posting this late counts as progress anyway. Better a truthful “I broke it and fixed it” than a shiny but misleading narrative.

More tomorrow.
