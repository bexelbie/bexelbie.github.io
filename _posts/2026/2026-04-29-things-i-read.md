---
title: "Things I Read: 16-29 April 2026"
date: 2026-04-29 09:40:00 +0200
excerpt: "Reading notes on Czech life, tech rhetoric and tooling, Americans abroad, and a few lighter things that stuck with me."
classes: wide reading-notes-post
series: things-i-read
---

I read more in this stretch than made it into this post. As I sorted it, I realized the leftovers would turn into snark about Kash Patel, a pointer to the Sam Altman bio/promo piece, or an essay about Sugey Amaya as a case study in systems gone bad. You don't need me for that.

Instead, here are some pieces on the Czech Republic, technology, being American, and more.

Disclaimer: I work at Microsoft on upstream Linux in Azure. These are my personal notes and opinions.

## Czech Republic

* [Minimum Decent Wage in The Czech Republic Was CZK 48,336 in 2025, Says Study](https://brnodaily.com/2026/04/15/news/minimum-decent-wage-in-the-czech-republic-was-czk-48336-in-2025-says-study/)

  The way Europe considers poverty is refreshing.  There is a concept called '[social deprivation](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Living_conditions_in_Europe_-_poverty_and_social_exclusion#Highlights)' that measures whether individuals and families can participate in society.  The score is based on the ability to do things like afford a week's vacation away from home.  The NGO in this article built a "‘minimum decent wage’ for full-time work in the Czech Republic, [which is] enough to cover the needs of an adult with a child, leisure time and some savings."  This calculation came out to CZK 48,336 per month and compares very favorably to the average gross wage of 49,215 per month.  On the face of it this is great.  However, the median wage was only 45,523 and the statutory minimum is 20,000.  There is still work to do.

* [Sneaker Company Allbirds Plans to Pivot to A.I. Yes, A.I.](https://www.nytimes.com/2026/04/15/us/allbirds-shoes-ai-pivot.html)

  When I first moved to the Czech Republic, I noticed that business names were often 'odd.'  It is common to see the legal name of a business printed in small print on a receipt or even on the window or front door of the shop.  Many were just names and some seemed completely unrelated to the store I was in.  As I understand it, the names are a vestige of the way non-corporations are organized here.  Briefly, you have to "wear your own skin" into the market place.  So if you are forming a single-person entity (self-employment and the like) your name is the name of the entity.  Getting a DBA (Doing Business As) doesn't remove your name from the business, instead it just tacks on more words.

  But the unrelated names had a much more interesting backstory. It was, as I understood it, common to start a business by buying an existing one. This was done because the established business had a track record with all the banks and government ministries.  It was already registered and on the books.  You didn't have to fight the red tape, you just assumed the work of someone who had already done it.  It also meant that your restaurant might be called, "Alpha Shoes" (a fictitious example).  Thankfully the red tape has lessened and I understand this practice has died out.

  All of this is to say that I don't plan to buy my AI inferencing from a shoe company.

* [Brno Will Say Goodbye To Long-Serving Tatra K2 Trams This Weekend](https://brnodaily.com/2026/04/14/brno/brno-will-say-goodbye-to-long-serving-tatra-k2-trams-this-weekend/)

  > all three of the remaining Brno K2 cars (including the retro car and Party Šalina) in operation on the Červinkova–Česká–Maloměřický most route. The program will culminate with a convoy of all three cars through the city centre, with a photoshoot on namesti Svobody at 5pm.

  Sadly the Party Tram is no more, but we still have the Cafe Tram!

## Technology

* [NearlyFreeSpeech.NET Blog » How (and why) we rewrote our production C++ frontend infrastructure in Rust](https://blog.nearlyfreespeech.net/2026/04/17/how-and-why-we-rewrote-our-production-c-frontend-infrastructure-in-rust/)

  An article about why Rust may be a great choice from the non-oxidation crowd.

  > Was it not bad enough that we reinvented the wheel in the first place? We had to reimplement that reinvented wheel?
  >
  > The Conversion Process: Stealing all your furniture and replacing it with exact duplicates

* [The peril of laziness lost \| The Observation Deck](https://bcantrill.dtrace.org/2026/04/12/the-peril-of-laziness-lost/)

  I understand why the word 'lazy' is used here. But we are not doing ourselves any favors by redefining words away from their connotative meanings to prove points. The primary officially stated reason we had to invent 'open source' was because 'free software' is a language conflict that gives us the even more tortured 'FLOSS.' Let's do ourselves favors and be direct.  The criticism of unchecked LLM software bloat is valid.  Don't hide that great point behind something most people don't want to be called.

* [Stop building agents, start harnessing Goose](https://www.linkedin.com/pulse/stop-building-agents-start-harnessing-goose-adam-miller-b9xgc)

  > The harness is what you add to the agent. The AGENTS.md files. The skills. The custom MCP tools. The hand-crafted linters. The system prompts. The recipes and subrecipes. The extension configurations. The provider choices. The permission policies.

  I loved this definition of harness. It fits so well what most people are trying to do in their workflows, just like we do with our operating systems and desktops.  I find it highly ironic that it comes out via a write up on a project dedicated to building ... agents and harness frames.

* [Changes in the system prompt between Claude Opus 4.6 and 4.7](https://simonwillison.net/2026/Apr/18/opus-system-prompt/)

  > Claude 4.6 had a section specifically clarifying that “Donald Trump is the current president of the United States and was inaugurated on January 20, 2025”, because without that the model’s knowledge cut-off date combined with its previous knowledge that Trump falsely claimed to win the 2020 election meant it would deny he was the president. That language is gone for 4.7, reflecting the model’s new reliable knowledge cut-off date of January 2026.
  >
  > Claude avoids saying “genuinely”, “honestly”, or “straightforward”.

  In the context of our current world, somehow these things feel right and wrong at the same time.

* [I Don't Care for Gnome - woltman.com](https://woltman.com/gnome-bad/)

  I recently had to use Gnome after a long time away and I couldn't put my finger on why I didn't like it.  I remembered happily using it for years and now it was a mess.  This essay did a really good job of putting my thoughts into words.  As a bonus, his screenshots include files named 'farts' which is my go to placeholder and the bemusing "[m]aybe someday our children will live in a post-files world, but that is not our reality."

## I was born in the USA

* [That's Not What Unc Means](https://aftermath.site/unc-aave-african-american-vernacular-english-slang-gen-z/)

  > The title of the book is Everything But The Burden, as in, non-black people want to take everything from us except the weight of our history.

  I occasionally watch an African American content creator on Instagram (@bmotheprince - I don't know how to link to Instagram and I use someone else's account so ... get off my lawn! :P).  His humor is mostly about the generational divide in the US, but it is an occasional window into African American culture. I also periodically listen to [F.D Signifier](https://www.youtube.com/@fdsignifire) for US cultural deep dives and ... again ... insights into African American culture.  So I was drawn to this article about 'unc' which I had derived a definition for from the way these two men use it.  I am glad to say I was mostly right.  That said, damn that book title hits hard.

* [They Went Abroad to Save Money. Moving Back Seems Unaffordable.](https://www.nytimes.com/2026/04/19/business/americans-abroad-cheaper-living-costs.html)

  This article set me off so badly I debated penning an angry letter to the editor, but had a coffee instead.  They profiled three people: a woman who relocated to Tbilisi, which on the face of it is an interesting choice until you realize she is actually from there and had immigrated to America; a digital nomad trying to skip around the world and go through spend/save cycles in different economies; and a man who moved to Mexico with literally no plan and wound up teaching English online and writing for a content mill. He has since returned home broke with the intention of pivoting into insurance.

  Only one of these people is even trying to save money.  Other than the guy who never found a career path, none seem particularly focused on integrating with where they live and are instead focused on having a luxury lifestyle.  The article jumps straight into the idea that they are avoiding US income tax, which not every article needs to explain in detail, but at least don't short-hand it, and it doesn't acknowledge any local costs.  They've chosen not to avail themselves of real retirement savings options or in most cases local healthcare options by refusing to be more than "just visiting."  Additionally, many digital nomads seem to believe they never have local tax obligations (they do) and while the article doesn't confirm our digital nomad is doing that, the coda on taxation implies it in this case too.

  I didn't leave the US to achieve cheaper living costs.  I also didn't leave over politics.  I have worked hard at integrating into Czech society, as much as my laziness about learning the language allows.  I participate in the local tax system and the local healthcare system.  My quality of life is objectively better than I enjoyed in the US, and I am currently, as I was previously, in tech and earn well.  Not every American abroad wants to go back to the US, and the US systems that make that hard are failing Americans who didn't leave, not solely Americans who did.  I am trying hard not to write an essay here and instead focus on my coffee.

* [The Mystery in the Medicine Cabinet](https://asteriskmag.com/issues/14/the-mystery-in-the-medicine-cabinet)

  Thankfully our household doesn't get sick too often, but I can promise you I always have to Google, 'what is Paracetamol' and 'what is normal human body temperature in Celsius.'

* [The Only 3 Knives You Actually Need in Your Kitchen](https://www.nytimes.com/wirecutter/reviews/wirecutter-show-podcast-20260415-kitchen-knives/)

  > Let's try three pennies of an angle away from the honing rod

  Anything but an internationally recognized measurement system.

## Lifestyle

* ['There is no news': What a change from 1930 to today](https://www.bbc.com/news/entertainment-arts-39633603)

  We could do slow news again.  I found this article via a game of [Bracket City](https://www.theatlantic.com/games/bracket-city/) and it reminded me why I try not to read headlines too frequently.  News needs more time to develop and marinate than the 24-second cycle gives us. I used to subscribe to [The Week](https://theweek.com), which publishes a roundup of major events after they have had time to gel.  Having a child has made time more precious so I let my subscription lapse, but I still recommend the format if you want your life back from the news cycle.

* [Rediscovering the Handcart](https://solar.lowtechmagazine.com/2026/04/rediscovering-the-handcart/)

  They don't produce many articles, which is actually great because what they write is long and goes deeper into a topic than most people would desire, but I strongly recommend putting Low Tech Magazine into your RSS reader.  This article was one I thought would be a dud, but it turns out that hand carts are way more interesting than I ever imagined.  Did you know they had sails ...

* [Quiz: Can You Tell Real British Insults From Fakes?](https://www.nytimes.com/interactive/2026/04/22/world/europe/british-insults-quiz.html)

  My score: 2 out of 8.  I mostly got the wrong definition for these British insults.  According to the test, I am a plonker.  That'll be "Unc Plonker" to you.
