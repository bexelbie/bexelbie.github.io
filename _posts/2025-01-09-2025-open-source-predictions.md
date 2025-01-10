---
date: 2025-01-08 18:44:00 +0100
title: 2025 Open Source Predictions
excerpt: 
tags:
  - Conferences
  - Community
  - Strategy
categories:
  - Ramblings
---

Inspired by [Ben Cotton’s 2025 Open Source Predictions](https://duckalignment.academy/open-source-trends-2025/), I decided to do a little predicting of my own. My mind has been on AI and how I can leverage it so that has colored a lot of my predictions. I do not mean to imply that AI is the most important thing that will happen in 2025.

## Open Source Continues To Democratize Access To LLMs

More developer tooling to leverage LLMs is coming this year. The game of trying to one-shot entire programs is going to morph into a new emphasis on working with code without personally editing it. Our current approaches of integrating with existing editors, such as [Cline](https://github.com/cline/cline) in Visual Studio Code and, my go-to tool of choice, “terminal” editors like [Aider](https://aider.chat/) is not going to solve this problem directly. New ideas will be explored.

We will not get there this year, however there will be a large number of new tools focused on having an LLM/AI driven inner loop. Specifically, the user will prompt with the next feature or bug to fix to implement and the AI will drive the entire inner loop until complete. Doing this will require creativity in the face of LLM non-determinism and context windows. Startups and open source developers are likely to find this challenge exciting, investing significant time and resources into solving it.

Open source tools will drive most of this democratization. Selling dev tools is challenging; few developers are willing to pay and many corporate developers avoid seeking managerial approval. They will want to download something, get it working and get the same amount done in less time without their task masters being any wiser.

This is an opportunity for open source projects to attract contributors and for open source, in general, to once again, prove that collaboration beats silos.

## LLMs Are A Threat To Open Source

The rise of generative AI and its accessibility through various tools poses a threat to open source. Hand-in-hand with the increase in people using LLMs to develop software will be an increase in people viewing software purely as a revenue generator. Open source business models are still messy, primarily because open source itself isn’t a business model, contrary to popular belief. Therefore these folks are likely to fall hard into the proprietary code camp.

Why? Because these new developers are going to almost exclusively focus on consumer (business or personal - money is money yo!) problem solving in order to create SAAS opportunities for themselves. They don’t see themselves as building on the shoulders of giants, probably don’t fully grasp that libraries were actually written and made available to them via open source, and honestly, don’t care because they entered through the “side door” and didn’t have the experiences of starting from nothing and being grateful you could finally call quicksort.

These are not bad people. However, they are unprepared for the open source of today which tends to be either attraction oriented, meaning no one really welcomes you, or religious litmus testing gatekeeper oriented. Neither of these concepts are going to work for these new folks and there seem to be few projects interested in AI-based help, even when delivered with care and concern and not thrown at the wall like so much spaghetti.

This dynamic is going to have a long-term impact on AI. Today’s LLMs rely on a ton of open source software for training. If less novel open source software is created the LLMs are, at best, going to have what is essentially synthetic training material by harvesting what their clients write. Today’s coding LLMs excel when the problem to solve can be stated in the form of known-solved problems. While that covers a lot of territory, LLM creation efforts will require more. Some companies have large pools of proprietary code they can tap for training - think about Microsoft and Windows (disclosure, while I work for Microsoft I don’t work on Windows nor do I speak on Microsoft’s behalf here) and [Red Hat with Ansible Playbooks.](https://developers.redhat.com/products/ansible/lightspeed). Other companies may suddenly find themselves in the business of supporting and enabling open source communities in order to get human-generated training material. Interesting times make for strange bedfellows.

## License Skirmishes

Continuing with our theme on strange bedfellows, one place we aren’t seeing that dynamic is in the ongoing licensing skirmishes. I call them skirmishes and not a war because war requires both sides to be committed, and, candidly, the companies aren’t committed. This is not crowing over the walking back that Elastic did. This is the opposite. Companies basically don’t care. 

Companies will follow the rules and the law. When what they have to do is no longer convenient they will choose another legal path. They are playing for revenue not idealism. So far, this has been rewarded as their revenue providers (i.e. customers) have so far made it clear that license and open source is far down on their list of reasons to part with cash.

## Projects Need AI

Contributions of documentation and being present to help users are still hard to come by for most projects. Documentation is hard to keep up-to-date and usually suffers from terrible tool chains and inner loop processes. The lack of project product management means that use cases are either in a developers head and hyper specific or an afterthought beyond some immediate need which has minimal provided context. In order to succeed here you need scale which mostly serves to make the funnel big enough to have the small percentage of contributors matter. Absent that you need something where it is natural to want to share your successes and by accident or purposefully help others achieve their goals too. A great example of a community that has this in spades is Home Assistant.

Everyone else needs an LLM, despite their tendency to MSU (hallucinate). LLMs can be trained to help users where the docs fail or don’t exist. They can help users restate their problems in terms of solutions the project can actually provide (a huge new user issue). Critically, LLMs take the mountain of mailing lists and chats and make them something consumable and usable. That said, no one has really figured out how to do this at scale yet in a way that is reproducible by communities.

As an aside, if this problem interests you, I am thinking about it right now and open to some collaboration. If you have solved this problem already, hit me up and save me a lot of time.

## Project Conferences Are Over

Building on [Ben’s 2025 prediction](https://duckalignment.academy/open-source-trends-2025/#Inequity), I believe 2025 will mark the end of traditional project conferences. While contributors will still get together, all pretense that the non-contributor community should care and show up is going to be gone. These meetups, increasingly virtual-only, are places to make project plans and friends. These are not places to discuss the intersection where the software becomes useful to the user.

The intersection conversation takes place at conferences that bring together users and lots of different solutions and options. These kinds of conferences are, as Ben points out, places where businesses can do business and are likely to be the only survivors.