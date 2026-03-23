---
title: Reflecting on “Warranty Void If Regenerated”
date: 2026-03-23 11:50:00 +0100
excerpt: Reflecting on “Warranty Void If Regenerated” and why calling LLMs “slop generators” misses the real issues.
---

I’ve seen [“Warranty Void if Regenerated”](https://nearzero.software/p/warranty-void-if-regenerated) going around, particularly among the subset of my friends who believe “LLMs are slop generators”. They typically characterize it as overly optimistic - hopeful, if not downright fantasy.

The "slop generator" position is, in my opinion, demonstrably false, as countless successful code generation outcomes contradict such a sweeping generalization. The dogged pursuit of this position clouds the issue of the real concerns with LLMs as built and used today.  I believe there are legitimate company ethics, environmental, and license/copyright concerns worthy of consideration in this space.  I also believe that we are still in a highly emotional place where those concerns tend to be both understated and overstated depending on who is talking.

The story consists of three vignettes told from the perspective of Tom, a post-transition specification repair person who works with farmers. In this universe, all code is generated from specs and average humans are making custom software constantly. Domain experts are needed to refine, debug, and in some cases wholesale write the specifications.

There is also a great discussion of the human impact of this post-transition existence. I encourage you to read it, but I’m not addressing that below - not because it isn’t important, but because I want to preserve focus on the “slop generator” drumbeat that feels so misguided.

All in all, I think the piece is well written and that [Scott Werner](https://substack.com/@scottwerner) did a great job. This isn’t a critique of the writing or the story itself.  I also don't know what Scott's perspective is on LLMs, though their public pages and site lead me to believe they are not anti-generative AI.

I’d been harboring a delusion in the back of my mind about trying to write a story about a “machine whisperer”. Scott’s piece reminded me that I am likely still not a creative writer, and I’m glad for their work here.

My thesis here is simple: this story reads like a set of specification and contract failures. It does not read like evidence that code generation inherently produces “slop” or that opaque code from code generation is inherently a failed concept. To be clear here, this is not a critique of Scott's view, but instead of the "slop generator" view point.

## Margaret

Margaret has generated software that pulls in various data sets from both their farm and external sources to predict the best time to harvest. Their latest harvest was harvested before it should have been, and Tom realizes that the specification failed to include a requirement that it raise an error if a data source’s structure or methodology changed. Instead, the system absorbed the data from an updated methodology and didn’t change how it used that data.

This is shown to be a specification problem. The spec as written didn’t suggest that changes were possible or that they should be monitored for, so the generated system didn’t do that.

While this happens with, I suspect, regularity in hand-coded systems, my point isn’t that this is normal. When it happens in a hand-coded system, it is wrong too. And, importantly, it is also a specification error.

There may never have been a specification in the first place and the developer was just expected to figure this out. Depending on their experience and other conditions, they either did ... or they didn’t. A clearer spec or set of standards (a/k/a a system prompt) would have fixed this in both cases.

### Pit Crew

Scott introduces pit crews in this anecdote. These are people who monitor ongoing quality and concerns.

Today we often approximate this with monitoring systems that we hope are checking the right things, perhaps even with real end-to-end live tests running on a regular basis. We don’t generally dedicate human teams to it.

Whether we ever hit post-transition or not, this begs for a conversation: is QE/QA solely a pre-ship function, or should we be leveraging that knowledge to monitor delivered software in ways that go deeper than what we typically monitor today?  What does the SRE practice in this space look like?

Framed that way, the pit crew in the story is less a bandage for sloppy generated code and more the missing extension of our specifications and contracts into how we watch systems evolve over time.

## Ethan

Ethan has generated a multitude of tools and they are all communicating with each other. Ethan is a microservice machine.

Ethan, much like Margaret, has a data feed problem. This time one of his own tools made a change in the methodology and calculated a value per-hundredweight instead of per-head. While not stated in the story, this unit for output was chosen at generation because it wasn’t in the specification and the specification also didn’t have a way (or likely even a requirement) to flag changes. The downstream tool didn’t get a read failure but began using this new data value as though it was still per-head. This resulted in poor market price prediction.

The story is similar to Margaret’s except it is more like when Team A breaks Team B in your own company.

For me it raises the interesting point that while we tend to believe otherwise, in many cases our APIs and data formats are our only true contracts. They operate only at the level where they exist. The internals of our dependencies, or the work of other teams,  are opaque, and you could say that they may “regenerate” their code every day of the week and you just have to hope it still works for your consumption and use. You have to rely on them not breaking the contract and ensure the contract provides the guarantees you need.

### Choreographer

A choreographer is a post-transition architect. It is, in my opinion, the thing we should all be if we are going to use LLMs to generate code.

Here a choreographer goes through Ethan's systems and defines their interface contracts and layers. They also notice that some tools are unnecessary, while others have formed a sub-network that has no effect.  The output of this person's work is a cleaned up system that functions as a whole and not a set of discrete parts.

This is something we already have to do in large systems, and it’s something that people generating code still have to do. I suspect that some concepts like [Gastown](https://github.com/steveyegge/gastown) try to push parts of this work into a different layer of tooling. And it may even work.

LLM generation and reasoning capacity is getting higher, but none of this eliminates the need for this role or for specification correctness.  This is something which we’ve basically never had. Even waterfall failed here.

In this sense, the story reads less like an indictment of generation and more like a warning about what happens when we refuse to name, own, and maintain those contracts across a growing system.

## Carol

Carol’s farm illustrates the ugly mess of things we give automation and then complain about.

In this specific case there is a new irrigation system that is using all of the sensors it has to maintain a 60% moisture level across the farm. This results in under- and over-irrigation in some places because the moisture level in those places is influenced by external factors. The system is doing exactly what it was asked to do. The problem is that the target it was given is a bad fit for the actual farm not that the generated system is inherently bad.

Note: I am not a farmer, so I am taking this example at face value.

The short version is that drainage is funny in some places, other places are getting more wind, and still others need slightly differing levels based on the actual crop in that spot. None of this data has been provided to the system, and the story makes it clear that most of it is not in any system.

The farmer just understands their land and can look at it and tell you what is going to happen based on 30 years of real history and 30 years of experience. This is also not new. This is the art and practice of both coding and system administration, and we have failed to codify it usefully to date. We shouldn’t hold our new system accountable for that, but we also shouldn’t pretend that “just write a better spec” is an easy button when so much of the domain is still tacitly known and not shared beyond tribal means.

This is perhaps the one vignette that gives me pause. Even if we can find code generation (it doesn’t have to be LLMs) that writes to a specification, we may still be unsuccessful when our measurements, abstractions, and language can’t yet capture the thing we actually care about.

Right now we make surgical tweaks to the code to encode these lessons as we learn them. Specifying them in human language is often difficult, and maybe that is the core problem. The boundary here isn’t really “hand-written vs generated code”, it is between where, as technologists, we have experience stating precisely enough and where we don't have a history of doing that well.

But we work in a precise space. In the case of Carol’s farm, Carol and Tom are able to describe the core problems pretty quickly, and I suspect, given time, could come up with data feeds, additional sensors, or equations that describe the issues sufficiently to fix the irrigation system.

It would be hyper-customized to Carol’s farm, but in many ways that is what she wants and needs - and it’s something we fail to deliver, in general, today. Even here, though, calling the outcome “slop” feels like a category error: the system is faithfully pursuing the narrow, naive target we gave it, not spewing random garbage.

## The Real Conversation

I wrote this piece in part because the anti-LLM rhetoric of “they are slop generators” gets under my skin. There are a lot of valid reasons to be anti-LLM today. This is not one.

Reading the story reinforced that for me: what fails in these vignettes are specs, contracts, and incentives, not some inherent “slop” property of generated code. The story isn't an indictment of generated code, it's a parable about the timeless need for human wisdom, clear communication, and rigorous oversight, no matter how the code comes to be.

I'd like to see our LLM conversations stick closer to the concrete and demonstrably true. Let's focus on what these systems do, where they fail, and how our specs and contracts are part of that story, instead of getting pulled into slogans like “slop generator” that, by being false, derail the conversation.  This creates space for us to have the real conversations that matter around ethics, the environment, and training data usage.
