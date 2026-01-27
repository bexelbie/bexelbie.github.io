---
title: "On EU Open Source Procurement: A Layered Approach"
date: 2026-01-27 09:10:00 +0100
excerpt: "Treat OSS as recurring OpEx: hire contributors, contract experts, and fund internal IT so the EU participates, not just buys."
---

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

The European Commission has launched a consultation on the EU's future Open Source strategy. That combined with some comments by [Joe Brockmeier](https://toot.io/@jzb@hachyderm.io) made me think about this from a procurement perspective.  Here’s the core of my thinking: treat open source as recurring OpEx, not a box product. That means hiring contributors, contracting external experts, and funding internal IT so the EU participates rather than only purchases.

A lot of reaction to this request has shown up in the form of suggestions for the EU to fund open source software companies and to pay maintainers. In this [Mastodon exchange](https://toot.io/@jzb@hachyderm.io/115939723318453222) that I had with Joe, he points out that these comments ignore the realities of how procurement works and the processes that vendors go through that, if followed by maintainers, would be both onerous and leave them in the precarious position of living contract to contract.

His prescription is that that the EU should participate in communities by literally "rolling up [their] sleeves and getting directly involved." My reaction was to point out that doing these things has an indirect, at best, relationship to bottom-line metrics (profit, efficiency, cost, etc.) and that our government structures are not set up to reward this kind of thinking. In general people want to see their governments not be "wasteful" in a context where one person's waste is another's necessity.

As the exchange continued, [Joe pointed out](https://toot.io/@jzb@hachyderm.io/115940797583976313) that "it's not FOSS that needs to change, it's the organizational thinking."

In the moment I took the conversation in a slightly different direction, but the core of this conversation stuck with me. I woke up this morning thinking about organizational change. I am sure I am not the first to think this way, but here's my articulation.

An underlying commentary, in my opinion, in many of the responses from the "pay the maintainers / fund open source" crowd is the application of a litmus test to the funded parties. Typically they want to exclude not only all forms of proprietary software, but also SAAS products that don't fully open their infrastructure management, products which rely on cloud services, large companies, companies that have traditionally been open source friendly that have been acquired (even if they are still open source friendly), and so on. These exclusions, no matter which you support, if any, tend to drive the use of open source software by an entity like the EU into a 100% self-executed motion. And, despite the presence of SAAS in that list, these conversations often treat open source software as a "box product" only experience that the end-user must self install in their own (private and presumably all open source) cloud.

A key element of most entities is that they procure the things that aren't uniquely their effort. A government procures email server software (and increasingly email as a service) because sending email isn't their unique effort; the work that email allows to happen is. There is an inherent disconnect between the effort and therefore the corresponding cost expectation of getting email working so you can do work versus first becoming an email solution provider and expert and then after that beginning to do the work you wanted to do. (A form of Yak Shaving perhaps?).

While I am not sure I will reply to the EU Commission - I am a resident of the EU but not an EU citizen - I wanted to write to organize my thoughts.

## Why Procurement Struggles With OSS

Software procurement is effectively the art of getting software:

- written
- packaged into a distributable consumable
- maintained
- advanced with new features as need arises
- installed and working

Over time the industry has become more adept at doing more of these things for their customers. Early software was all custom and then we got software that was reusable. Software companies became more common as entities became willing to pay for standardized solutions and we saw the rise of the "box product." SaaS has supplanted much of the installation and execution last-mile work that was the traditional effort of in-house IT departments. From an organizational perspective, these distinct areas of cost - some one-time and some recurring - have increasingly been rolled into a single, recurring cost. That is easier to budget and operate.

Bundling usually leads to discounting. Proprietary software companies control this whole stack and therefore can capture margin at multiple layers. This also allows them to create a discount when bundling different layers because they can "rationalize" their layer-based profit calculations. Open source changes this equation. There is effectively no profit built into most layers because any profit-taking is competed away in a deliberate and wanted race to the bottom. When a company commercializes open source software, it has to build all of its profit (and the cost of being a company) into the few layers it controls. We have watched companies struggle to make this model work, in large part because it is hard and easy to misunderstand. There is a whole aside I could write about how single-company open source makes these even worse because it buries the cost for layers like writing and maintaining software into the layers that are company-controlled, but I won't, to keep this short. But know this context. What this means, in the end, is that I believe procuring open source can sometimes lead, paradoxically, to an increase in cost versus procuring the layers separately ... but only if you think broadly about procurement.

Too often we assume procurement == purchasing, but it doesn't have to. [Merriam-Webster](https://www.merriam-webster.com/dictionary/procuring) reminds us that procurement is "to bring about or achieve (something) by care and effort." Therefore we could encourage entities like the EU to procure open source software by using a layered approach and have an outcome identical to the procurement of the same software in a non-open way at the same or lower cost. Open source doesn't need to save money; it just needs to not "waste" it.

The key is the rise of software as a service. From an accounting perspective, software as a service moves software expenses from a model of large one-time costs with smaller, if any, recurring costs to one of just recurring costs. The "Hotel California"[^saas-exit] reality of software as a service - the idea that recurring costs can be ended at-will - is an exciting one organizationally as it gives flexibility at controllable cost, but in practice exit is often constrained by vendor lock-in, data egress limits, and portability gaps.

## The Layered OpEx Model

Here's how the EU can treat open source as a recurring cost:

1. **Hire people to participate in the open source project.** They are tasked with helping to maintain and advance software to keep it working and changing to meet EU needs. These people are, like most engineers at open source companies, paid to focus on the organization's needs. They differ from our typical view of contributors as people showing up to "scratch their own itch."

2. **Enter into contracts with external parties to provide consulting and support beyond the internal team.** These folks are there to give you diversity of thought and some guarantees. The internal team is, by definition, focused just on EU problems and has a sample size install base of one. External contractors will have a much larger scope of interest and install base sample size as they work with multiple customers. Critically, this creates a funding channel for non-employees and speaks to the "pay the maintainers" crowd.

3. **Continue to fund internal IT departments to care and feed software and make it usable instead of shifting this expense to a single-software solution vendor.** These folks are distinct from the people in #1 above. They are experts in EU needs and understand the intersection of those needs and a multitude of software.

Every one of these expenses is recurring and able to be ended at-will. But only if ending these expenses is something we are willing to knowingly accept. We already implicitly accept them when we buy from a company. The objections I expect are as follows. Before you read them though, I want to define at-will. While it denotatively means "[as one wishes : as or when it pleases or suits oneself](https://www.merriam-webster.com/dictionary/at%20will)" in our context we can extend this with "in a reasonable time frame" or "with known decision points."

## Expected Objections

1. **If you can terminate the people hired to participate in open source projects like this, they're living contract to contract.** To this I say, yes in the sense that they don't have unlimited contracts, but no in the sense that they are still employees with employee benefits and protections, like notice periods. The big change is that they can be terminated solely due to changes in software needs.

2. **But allowing for notice periods is expensive. EU employees are often perceived as more expensive than private sector ones or individual contractors.** To this I say, maybe. But isn't that the point? Shouldn't we want to be in a place where we are *not* creating cost savings by reducing the quality of life for the humans involved?

3. **If everything is either an employment agreement with a directed work product (do fixes/maintenance for our use case or install and manage this software) or a support/consultancy contract we aren't paying maintainers to be maintainers.** To this I say, you're right. The mechanics of project maintenance should be borne by all of the project's participants and not by some special select few paid to do that work. There is a lot of room here to argue about specifics, but rise above it. The key thing this causes is that no one is paid to just "grind out features or maintenance" on a project that isn't used directly by a contributor. A key concept in open source has always been that people are there to either scratch their own itch or because they have a personal motivation to provide a solution to some group of users. This model pays for the first one and leaves the second to be the altruistic endeavor it is. Also, there are EU funds you can get to pay for altruistic endeavors :D.

4. **This model doesn't explain how software originates. What happens when there is no open source project (yet)?** To this I say, you're also right. This is a huge hole that needs more thought. Today we solve this with VC funding and profit-based funding. VC funding is predicated on ownership and being able to get return on investment. If this model is successful there is very little opportunity for what VCs need. However, profit based funding, when an entity takes some of its profit and invests in new ideas (not features) still can exist as the consulting agreements can, and likely should, include a profit component. Additionally, the EU and other entities can recognize a shared need through the consensus building and collaborative work on participation in open source software and fund the creation of teams to go start projects. This relies on everyone giving the EU permission to take risks like this.

5. **The cost of administering these three expenses will eat up the cost more than paying an external vendor.** To this I say, maybe, but it shouldn't matter. While I firmly believe that this shouldn't be true and that it should be possible for the EU to efficiently manage these costs for less than the sum of the profit-costs they would pay a company, I am willing to accept that the "expensive employees" of #2 above may change that. But just like above, I think that's partly the point.

6. **Adopting this model will destroy the software industry and create economic disaster.** To this I say, take a breath. The EU changing procurement models doesn’t have the power to single-handedly destroy an industry. Even if every government adopted this, which they won't, the macro impact would likely be a shift in spend rather than a net loss. This model is practical only for the largest organizations; most entities will still need third-party vendors to bundle and manage solutions. If anything, this strengthens the open source ecosystem by providing a clear monetization path for experts, while leaving ample room for proprietary software where it adds unique value. Finally, the private sector is diverse; many companies and investors will continue to prefer traditional models. The goal here is to increase EU participation in a public good and reduce dependency, not to dismantle the software industry.

## What To Ask The Commission

- When choosing software, the budget must include time for EU staff (new or existing reassigned) to contribute to the underlying open source projects.
- Keep strong in-house IT skills to ensure that deployed solutions meet needs and work together
- Complement your staff with support/consultancy agreements to provide the accountability partnership you get from traditional vendors and to provide access to greater knowledge when needed
- Make decisions based on your mission and goals and not your current inventory; be prepared to rearrange staffing when required to advance

This was quickly written this morning to get it out of my head. There are probably holes in this and it may not even be all that original, but I think it works. As an American who has lived in the EU for 13+ years, I have come to trust government more and corporations less for a variety of reasons, but mostly because, broadly speaking, we tend to hold our government to a higher standard than we hold corporations.

I’m posting this in January 2026, just before FOSDEM. I’ll be there and open for conversation. Find me on Signal as `bexelbie.01`.

[^saas-exit]: Many software as a service agreements allow you to stop paying but still make true exit difficult due to data gravity, integrations, and proprietary features. In practice, you can “check out,” but actually leaving is often costly and slow.
