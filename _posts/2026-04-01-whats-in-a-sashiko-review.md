---
title: "What's Actually in a Sashiko Review?"
date: 2026-04-01 23:20:00 +0200
excerpt: "I pulled Sashiko's public review data and tested two hypotheses about what's driving kernel maintainer frustration."
---

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions. And, yes, I'm aware of the date. The data is real - and in 40 minutes it won't be April 1 anymore, at least where I live.

Daroc Alden's [LWN article on Sashiko $](https://lwn.net/Articles/1064830/) captures a real tension in the Linux kernel community. Andrew Morton wants to make Sashiko - an LLM-based patch reviewer - a mandatory part of the memory management workflow. Lorenzo Stoakes and others say it's too noisy and adds burden to already-overworked maintainers. Morton points to a ~60% hit rate on actual bugs. Stoakes points out that's per-review, not per-comment, so the individual false positive rate is worse.

Reading the thread, I kept wondering about two specific mechanisms that could be driving maintainer frustration beyond the false positive question.

## Two Hypotheses

**Hypothesis 1: Reviewers are getting told about bugs they didn't create.** Sashiko's review protocol explicitly instructs the LLM to read surrounding code, not just the diff. That's good review practice - but it means the tool might flag pre-existing bugs in code the patch author merely touched, putting those problems in their inbox.

**Hypothesis 2: The same pre-existing bugs surface repeatedly.** If a known issue in a subsystem doesn't get fixed between review runs, every patch touching nearby code could trigger the same finding. That would create a steady drip of duplicate noise across the mailing list.

I pulled data from Sashiko's public API and tested both.

## Method

I fetched all 406 patchsets from the linux-mm mailing list and a 500-patchset sample from LKML as of April 1, 2026. Of the 252 linux-mm reviews with findings, 204 had full review text available for analysis.

I had an LLM write Python scripts to classify the 466 extracted findings into three categories using deterministic regex pattern matching - roughly 50 weighted patterns that look for specific language in the review text. The classification code runs the same way every time on the same input. An LLM wrote it, but the scanning itself involves no inferencing.

The three categories:

1. **Patch-specific** - about the actual changed lines. Patterns match phrases like "this patch adds," "the new code," "missing check."
2. **Interaction** - about how new code interacts with existing code. Patterns match references to callers, callees, lock state, concurrent access.
3. **Pre-existing** - about bugs in surrounding code not introduced by the patch. Patterns match "not introduced by this patch," "pre-existing," "noticed while reviewing."

When a finding matched multiple categories, the most specific won: pre-existing > interaction > patch-specific. About 7% of findings didn't match any pattern and were excluded from further analysis.

For duplication, the scripts computed pairwise text similarity across reviews within the same subsystem. Again - deterministic comparison, LLM-authored code.

The full methodology, including the code used, a cached copy of the reviews, and the classification patterns and caveats, is in the [analysis document](https://github.com/bexelbie/sashiko-analysis/blob/main/analysis-review-scope.md) in [github.com/bexelbie/sashiko-analysis](https://github.com/bexelbie/sashiko-analysis).

## What the Data Shows

**Hypothesis 2 is dead.** Cross-review duplication was essentially zero. Across 16 LKML subsystems with 5+ reviewed patches each, only one pair of findings exceeded the similarity threshold - and that was the same author submitting similar patches, not the same bug recurring. Whatever is driving maintainer frustration, it's not the same findings appearing over and over. While it is possible this would surface in a larger sample size, I personally find it unlikely.

**Hypothesis 1 is partially supported, but the story is in the distribution.** About 9% of findings explicitly discuss pre-existing issues. Averaged across all reviews, that's roughly 12 words per review - barely noticeable.

But the average is misleading. The distribution is bimodal: 81% of reviews contain zero pre-existing findings. The other 19% contain pre-existing findings that constitute 28% of the review on average, adding roughly 19 lines to what the patch author reads. A few reviews are 75-82% pre-existing content.

Here's the breakdown of what an average review with findings contains:

| Category | % of findings | Avg words |
|---|---|---|
| About the submitted patch | 72% | 74 |
| Patch × existing code interactions | 12% | 103 |
| Pre-existing issues | 9% | 62 |
| Unclassified | 8% | 47 |

The interaction findings (category 2) are worth calling out. They're the longest - 103 words on average, 39% more than patch-specific findings - because explaining how new code breaks against existing behavior requires describing that behavior. These are arguably the hardest findings for a human reviewer to produce and exactly where a tool with codebase-wide context adds value.

## Who Owns This Bug Now?

The sharpest question the data raises isn't statistical. It's social.

When you submit a patch to linux-mm and get a Sashiko review, there's roughly a 1-in-5 chance that a meaningful chunk of that review describes a bug you didn't write - a race, a leak, a use-after-free in the code you're modifying. Some of these are trivial (typos in nearby comments). Some are substantive.

Either way, the review has put it in your inbox. You are now the person who has been told about it.

Morton's position - "don't add bugs" as Rule #1 - makes sense if the tool's output is mostly about your patch. And it is: ~85% of findings concern either the submitted change or its direct interactions with existing code. But 1 in 5 reviewees is also getting handed someone else's problem, with an implicit expectation to respond.

Stoakes's concern about maintainer burden lands differently when you see the bimodal distribution. The average review is manageable. The tail is not.

## What This Doesn't Answer

This analysis classifies *scope* - whether a finding is about the submitted patch, its interactions, or pre-existing code. It does not measure *correctness*. The core Morton/Stoakes disagreement is about false positive rates within on-topic findings - how often Sashiko flags something in your patch that turns out to be wrong. That question requires domain expertise to evaluate each finding individually, and this data doesn't go there.

The classification also has limits. The regex patterns achieve ~93% coverage but aren't semantic - borderline cases between categories get decided by pattern specificity, not understanding. The proportions are directionally sound but not precise.

The full data, methodology, and API references are in the repository, [github.com/bexelbie/sashiko-analysis](https://github.com/bexelbie/sashiko-analysis) if anyone wants to reproduce or extend this.

