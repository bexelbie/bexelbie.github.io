---
title: "Day 2: Microsoft Hackathon — Distractions, Brainstorming, and Infrastructure"
date: 2025-09-16 21:50:00 +0200
excerpt: "Day 2: tackling distractions, brainstorming with ChatGPT, and shifting to SQLite for scaling."
---

Today was a mixed bag. I started with the goal of advancing the central metadata architecture, which is critical for figuring out what’s worth surfacing in the notebook. However, distractions and infrastructure challenges dominated the day. The day included a hot project at work, a meeting that couldn’t be skipped, and the ever-present TPS reports (or in my case, an expense report from a recent trip). These interruptions made it hard to focus on the metadata work.

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

## Brainstorming with ChatGPT

Despite the distractions, I spent some time brainstorming with ChatGPT on methods for surfacing important information. We explored various heuristics and LLM concepts. It was a productive session that gave me ideas to refine and potentially turn into something valuable.

One area we explored was how to determine if a thread was "important." This included qualitative factors like the number of unique participants in a thread and, in a future with more data, the history of those participants’ involvement in the list. We also discussed keyword surfacing as a way to highlight significant topics and the potential for trend analysis to predict emerging themes over time. While we touched on some additional qualitative measures, I don’t recall all the specifics.

## Infrastructure Challenges

The day ultimately became about infrastructure. Scaling issues forced me to shift to a database for the MVP, and SQLite came to the rescue. While not ideal, it’s a practical solution for now.

The motivation for SQLite was scalability. To ensure thread completion, I had to load more than one month of data into the MVP. Bonus months from testing added even more data, so it made sense to work with fresh data rather than repeatedly processing the same old files. SQLite also provided a way to query the data efficiently without having to read through tons of JSON files. While this approach works for the MVP, it’s clear that a more robust solution—like an MCP server—might be needed in the future.

## Final Takeaway

One thing this day reinforced is how fragile AI-driven development can feel without proper context management. Whether brainstorming with ChatGPT or coding in agent mode using Sonnet in Visual Studio Code, I’ve noticed that when tools lack memory or context, things can quickly go off the rails. For example, fragile solutions like resorting to regex to parse HTML instead of using a proper library like BeautifulSoup can emerge. This highlights the need for better agent hints or configuration files, though the idea of managing those feels cumbersome.

Tomorrow, I hope to meet with a teammate to advance the more interesting parts of the project. With the infrastructure in place, I’m optimistic about making real progress.

This remains a work in progress, but I’m hopeful that the brainstorming and infrastructure work will pay off in the coming days.
