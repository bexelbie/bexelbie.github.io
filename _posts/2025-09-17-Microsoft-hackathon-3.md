---
title: "Day 3: Microsoft Hackathon — Thread Heuristics, Importance Signals, and Agent Editing"
date: 2025-09-17 20:00:00 +0200
excerpt: "Filtered 424 threads to ~250 candidates, added package/entity tagging, and built an agent writing editing workflow."
---

Today started with a plan: drop my kid at school, head to a coworking space, meet my teammate, and push the importance model forward. Reality: unexpected stuff pulled me back home first. Momentum recovered later, but the change in expectations reinforced how fragile context can be when doing iterative LLM + data work.

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

## Thread heuristic exporter

I built a first pass “thread stats” exporter: sender count, participant diversity, tokens of note, and other structural hints. Deterministic, fast, and inspectable. This gives a baseline before letting an LLM opine. The goal: reduce the search space without prematurely deciding what’s “important.”

## Planning importance signals

With that baseline, I worked (with ChatGPT-5) on how to move beyond raw counts. What *makes* a thread worth surfacing? Some dimensions that matter to me:

- Governance, Policy or consensus decisions
- Direct relevance to Azure or adjacent cloud platform concerns
- Presence of Debian package names (as a proxy for concrete change surface)
- Diversity of participants vs. a back-and-forth between two people
- Emergence of unusual or “quirky” sidebars that might signal cultural or directional shifts (these are often interesting even if not strictly impactful)

I want to avoid letting pure volume masquerade as importance. A long bikeshed is still a bikeshed.

## Data enrichment

I experimented with a regexp to match Debian package names.  That worked a bit too well.  Claude Sonnet was reporting threads moving forward and I couldn't believe the numbers.  A little investigation and it turned out the regexp was capturing everything.  Sonnet suggested pulling in a Debian package list to tag occurrences inside threads. That, plus spaCy-based entity/token passes, lets me convert unstructured text into a feature layer the LLM can later consume. The MVP now narrows roughly 424 August 2025 threads to ~250 candidates for deeper scoring. Not “good,” just narrower. False negatives remain a risk; I’d rather over‑include at this stage.

## Why deterministic first

Locking down deterministic extraction serves to reduce some of the noise before LLM scoring. It also provides a dial I can change as part of the review from the human-in-the-loop process I envision.

## Next phase: human-in-the-loop LLM

Tomorrow I plan to let the model start proposing which threads look important or just interesting, then review those outputs manually - back and forth until the signals feel reliable. Goal: lightweight human-in-the-loop review, not handing over judgment. Keeping explanations terse will matter or I and any hypothetical readers will drown in synthetic prose.

## Agent editing workflow

While agents “compiled[^1],” I created an `AGENTS.md` doc to formalize how I want writing edits to work. This is about editing my prose, not letting a model co‑author new ideas. Core rules I laid down include:

- Challenge structure and assumptions when they look shaky - do not invent content
- Preserve hedges; mark uncertainty with `[UNCLEAR]` instead of guessing
- Keep my voice; I review diff output before accepting anything

Most importantly, I am not an emoji wielding performative Thought Leader(tm) turned Influencer(tm). The new guidance has already reduced noise. I still refuse to let a model start from a blank page; critique mode is the win. Visual Studio Code diff views make trust-building easier - everything is inspectable.

## Closing

Today was half heuristics, half meta-process. The importance problem still feels squishy, but the scaffolding is there. Now I'm going to stop and pick the kid up and let her redeem a grocery-store stamp card for a Smurf doll. Grocery stores are weird and since [she speaks Czech]({% post_url 2025-09-17-the-couple-across-the-way %}) she can do the talking.

[^1]: Obligatory [xkcd](https://xkcd.com/303/). In this case, letting an LLM grind out code for review.
