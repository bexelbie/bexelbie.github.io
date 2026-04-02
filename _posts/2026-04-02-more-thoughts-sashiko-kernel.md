---
title: "A Few More Thoughts on Sashiko and the Kernel"
date: 2026-04-02 13:50:00 +0200
excerpt: "False positives aren't the real problem with LLM code review. The burden is social, not statistical."
---

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

I kept thinking about the [LWN article $](https://lwn.net/Articles/1064830/) and the [basic analysis I did yesterday]({% post_url 2026-04-01-whats-in-a-sashiko-review %}). I kept coming back to one of the central themes of the mailing list conversation: false positives. Sashiko's false positive rate is debated, but, I'm gathering, is pretty good by LLM standards. Still, there was a complaint about the number of false positives focused on the burden that false positives put on contributors and maintainers.

I wanted to understand if the false positive rate, and by extension the burden, was higher from an LLM than from human reviewers. To run that experiment, I needed to define what a false positive actually is. That turns out to be the interesting part.

## The Definition Problem

My initial naïve definition of a false positive was any substantial comment that doesn't yield a code change. If you said something and the code wasn't changed, then even if it generated future work, it wasn't applicable to this change now. The obvious hole is a comment that raises a future code change coming in a different patch set. But it felt like this number could be directionally accurate for understanding if we get more false positives or not.

The deeper problem is that "comment that doesn't change code" isn't really what false positive means in review. The act of questioning code can lead to greater confidence in the patch being proposed. It can reveal unrelated changes that are required or surface features that should also be considered. Not a negative outcome, but potentially not relevant to the actual patch set under discussion. So I tried reframing from false positives to burden: any comment that doesn't result in a code change and was actually read by the contributor or maintainer is burdensome. It doesn't matter whether a human or LLM reviewer raised the comment. If it didn't result in a change, it was work or thought they didn't need to do. For example, a back-and-forth conversation to prove the correctness of something that was already correct.

But that definition fails too, and the reason it fails is the real insight.

If two humans are engaged in a review process and there's a back-and-forth conversation that does not result in a code change, most likely neither human would describe this as unnecessary burden. They would probably describe it as work they had to do or effort they expended, but both humans have likely come out of that conversation changed. Greater understanding of different parts of the system. Better ability to express oneself so the questions aren't raised next time. Increased confidence in the correctness of a solution. There is a change assumed to have happened to one or both of the people.

A review conversation that doesn't change code but changes the people having it isn't a false positive. It only looks like one when the reviewer is a machine that won't be changed.

For what it's worth, I did look at existing studies of human review false positive rates. In my brief and non-exhaustive look, I've come to believe they aren't useful here, not only because the question is moot when both parties come out changed, but because many are flawed or non-comparable. Some are in domains where reviewers are generalists talking to a specialist, unlikely in the kernel. Others misclassify trivial exchanges like "LGTM" or "thanks" as false positives. And none have been conducted over the kernel.

## When the Reviewer Is a Machine

When a finding or probing question is raised by an LLM agent, the assumption that both parties come out changed breaks down.

Probing questions may not even be welcome from an LLM agent. One could never really be sure whether this was a "humans normally say this kind of thing in this context" situation versus an "I see something that maybe is wrong" situation.

But the more important part is this: if a human has to read a false positive, they have to put in their side of the work to validate, verify, explore, or test the question, and ultimately determine that it's not an issue. They are unlikely to be changed in the absence of an exchange. And we know for a fact that the machine is not going to be changed.

In theory, we could wire up a training loop for Sashiko to take these back-and-forth exchanges and learn from them to reduce the incidence of false positives. I suspect it would have very little impact overall. First, the analysis showed that there's almost no situation where the same bug is being surfaced over and over again. The machine is unlikely to run into the same finding and then have learned that finding isn't valid. Second, the machine is not arguing from a position of true reasoning, therefore it is never clear if it backed down because it decided to be an agreeable sycophant or because the additional commentary made the correctness argument airtight.

## The Social Problem

At its true core, I think the conversation around false positives, based on what I read in the article, is likely a social problem, like most truly intractable problems in computer science.

If an LLM agent reviews my contribution and the maintainer insists that I address the review, I am not only forced to do what turns out, in the case of a false positive, to be unnecessary work, but forced to performatively defend myself against a machine. Or worse, argue with the machine performatively. The combination of unnecessary work that generates no value, plus being forced to do so performatively in the face of knowing it generates no value, but now having to do more work to show that I generated the work that did no value is a line too far for most of our psyches.

## A Possible Path

Setting aside the separate question of whether LLM ability will continue improving and therefore the number of false positives will go down, the core question of how to deal with false positives needs to be addressed at a social level.

In a space like the kernel, I would argue it may be appropriate to allow those whose code has been reviewed to react to LLM-generated findings with something along the lines of "smells like bullshit" and not have to go through the performative exercise of proving it's bullshit, because we trust their instinct.

That said, it is probably worth creating some kind of long-term profile or scoreboard, both of those being the wrong words, for a contributor, so that they can over time understand if their intuition has blind spots. If an LLM is consistently raising a certain kind of feedback that they are dismissing, but we later discover a bug and have to fix it, or if human reviewers come back and their synthesis of their own experience plus what the LLM provided leads them to believe there's a real, demonstrable problem, that's a learning opportunity for the contributor.

The challenge is that there are no systems I'm aware of in modern use where these kinds of profiles are ever not used abusively against those profiled. Which is yet another social problem.
