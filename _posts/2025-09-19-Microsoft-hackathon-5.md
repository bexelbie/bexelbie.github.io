---
title: "Day 5: Microsoft Hackathon — Model Grading, Parameter Friction, and Next Questions"
date: 2025-09-19 19:15:00 +0200
excerpt: "Pipeline runs, thread summaries graded, and model friction surfaced. Next test: can insights drive action?"
---

So this is it - the last day of Hackathon week.

Today (after a late night) was about tuning and observing how models graded candidate threads. No polished newsletter yet, but the code is published: [mailing-list-surfacing](https://github.com/bexelbie/mailing-list-surfacing)[^1]. It’s a one‑person PoC with plenty of LLM‑authored code that still needs deeper review.

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

## Model Evaluation

I only wired up two models because they were immediately available via an existing setup in Azure OpenAI: `gpt-4o` and `gpt-5-chat`. The latter performed better (unsurprising). Light prompt and heuristic tuning helped a bit, but I clearly need a labeled corpus of threads I have personally reviewed before pushing further.

Right now I’m only passing “tokens of note” + heuristic metadata (participants, entities, etc.) rather than full thread text. I still need to decide how much raw content vs distilled features to include for the importance phase.

## Parameter Friction

Switching from `gpt-4o` to `gpt-5-chat` wasn’t seamless: parameter names and availability shifted. There is (as far as I can find) no machine‑readable catalog of model parameter schemas. Abstraction layers (LiteLLM et al.) exist, but they flatten differences I may care about and add operational overhead I didn’t want for a hack week.

I’m debating a future micro‑spec project: machine‑readable model capability / parameter descriptors. I'm not committing yet as doing it right is a big job. There are some specific needs that don't occur in my daily routine that need to be accounted for by a contributor with passion.

## Reflection: Insights vs Metrics

Short version of a longer, still‑draft argument: many of us in open source / OSPO circles say we want “community insights,” but we mostly instrument what’s easy (repo / activity / contributor counts) because APIs are clean and numbers feel objective. That produces dashboards but it may not impact decisions. This experiment is a probe: can summarization + heuristics surface thread‑level signals that actually change what I do next month? Until I can log “signal → action → outcome,” it risks becoming dashboard theater. A longer reflection is coming, but I need to zen on it a bit longer.

## Next Steps

If I keep working on this next, the list is:

- Build a reviewed corpus of labeled threads (importance / interesting / ignore)
- Iterate heuristic weighting + prompt style once labels exist
- Improve cross-month linking and explore values you can derive from history (i.e. participant tenure)
- Experiment with feature payload size to balance detail and efficiency

## Closing

I reached the directional goal: the pipeline runs end‑to‑end, summaries exist for grading, and I surfaced real friction (threading earlier in the week; model swap today). Good enough for hack week. Now the real question is whether any surfaced “insight” will cause a concrete action. That’s the bar.

All that said, I know that my boss already has expansion ideas; we’ll see if time materializes.

[^1]: I would not run this in production without a thorough review.
