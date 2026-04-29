---
title: "Day 1: Microsoft Hackathon — Building a Focused Summarizer for Upstream Linux"
date: 2025-09-15 20:50:00 +0200
excerpt: "Hackathon MVP: building a lightweight LLM-driven summarizer for Debian mailing lists — architecture, data collection, and early lessons."
---

This week is the Microsoft Hackathon, and I’m using it as a chance to prototype something I’ve been thinking about for a while: a tool that summarizes what’s happening in upstream Linux communities in a way that’s actually useful to people who don’t have time to follow them day-to-day.

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal opinions.

For my MVP, I’m going to try to produce a “What happened in Debian last month” summary from selected mailing lists. It’s not a full picture of the community, but it’s a solid basis for a proof of concept.

## Why this project?

Part of my work at Microsoft involves helping others understand what’s going on in upstream Linux communities. That’s not always easy — the signal is buried in a lot of noise, and most people don’t have time to follow mailing lists or community threads. If this works, I’ll have a tool that can generate a newsletter-style summary that’s actually useful.

## Why Debian?

For this MVP, I chose Debian. It’s a community I work with but haven’t traditionally followed as closely as Fedora, where I have deeper experience. That makes Debian a good test case — I know enough to judge the output, and I have colleagues who can help validate it. I’m focusing on August 2025 because I already know what happened that month, which gives me a baseline to evaluate the results.

## Agentic coding, not vibe coding

Agentic coding, in my view, is when you rely on an LLM to do the heavy lifting — generating code, suggesting structure — but you stay in the loop. You review what’s written, check the inputs and outputs, and make sure nothing weird slips in. It’s not fire-and-forget, and it’s not vibe coding where you just hope for the best. I don’t read every line as it’s generated, but I do check the architecture and logic. One of my frequent prompt inclusions is “don’t assume, ask and challenge my assumptions where appropriate.” This helps uncover ideas as I develop, similar to an agile process.

## A breakfast pivot

This morning over breakfast with a friend, I walked through the architecture I’d outlined with Copilot on Friday. Originally, I was planning to build a vector database and use retrieval-augmented generation (RAG) to power the summarization. But as we talked, it became clear that this was overkill for the MVP. What I really needed was a simpler memory model — something that could support basic knowledge scaffolding without the complexity of full semantic search.

So I pivoted. Today’s work focused on getting the initial data in place: downloading a couple of months  of Debian mailing-list emails to ensure I had full threads from August, storing them locally to avoid putting any load on Debian’s infrastructure, and building scaffolding to sort and store the data so it supports both metadata generation and LLM access.

Could I have used a vector database or IMAP-backed mail store? Sure. But this was quick, easy, and gave me a chance to practice agentic coding in Python — something I don’t get to do much in my day-to-day product management work.

## What I’m hoping to learn

This MVP is about testing whether AI-generated insights from community data are actually useful. In OSPO and community spaces, we talk a lot about gathering insights — but we don’t always ask whether those insights answer real questions. This is a chance to test that. Can we generate something that’s not just interesting, but actionable? It feels a bit like the tail wagging the dog, but sadly that’s where we seem to be.

## Any surprises?

Nothing major yet, but I appreciated that the LLM caught a pagination issue I missed. I’d assumed a dataset was complete; while reconstructing threads it exposed an oddly truncated dataset. Today’s work also reminded me to be deliberate about model selection — not all LLMs are created equal, and the choice matters if you don’t arbitrarily default to the latest frontier models.

## What’s on deck for tomorrow?

Thanks to how some data structures came together, I’m rearchitecting the metadata store. This lets me defer generating the basic, memory-style knowledge passed to the LLM until I’m closer to using it, which should prevent some ugly backtracking.

I keep relearning this: don’t build perfect infrastructure for an MVP - ship the smallest thing that answers the question.
