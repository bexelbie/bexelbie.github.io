---
date: 2025-03-11 09:50:00 +0100
title: "Did I vibe code?"
excerpt: "My Experience with Vibe Coding: Successes, Challenges, and the Road to Production"
tags:
  - Coding
  - AI
categories:
  - Technology
---

> "There's a new kind of coding I call 'vibe coding,' where you fully give in to the vibes, embrace exponentials, and forget that the code even exists."
>
> <cite>Andrej Karpathy</cite>

This [blog post](https://simonwillison.net/2025/Mar/6/vibe-coding/) by Simon Willison discussing an [article](https://arstechnica.com/ai/2025/03/is-vibe-coding-with-ai-gnarly-or-reckless-maybe-some-of-both/) by Benj Edwards about vibe coding, and from which the above quote is pulled, got me thinking.

I've definitely vibe coded in the sense of yolo-ing some specific small utilities and tools.
I also vibe coded implementations of Connections and Strands from The NY Times Games group in order to share some jokes/ideas with friends.
But I want to think through here the idea of vibe coding your way to production.

> "Where vibe coding fails is in producing maintainable code for production settings. I firmly believe that as a developer you have to take accountability for the code you produce - if you're going to put your name to it you need to be confident that you understand how and why it works - ideally to the point that you can explain it to somebody else. … If an LLM wrote every line of your code but you've reviewed, tested and understood it all, that's not vibe coding in my book - that's using an LLM as a typing assistant."
>
> <cite>Simon Willison</cite>

I agree with the accountability call out Simon makes and while I could nit pick at edge cases and codebase sizes I won't because that is not the point.
Instead I'll share an example.

I've written some phone apps, one of which I've already published.  I used AI to code in languages that I'm not usefully competent in (why can't we use Perl 4?).
I've done some review and some basic automated tests and rather extensive manual tests.
A friend has also looked at some of the code.
They're low stakes apps with no real attack surfaces as they only locally process data and return results.
They do download updated data from the Internet. However, this data comes from a site I control and manage.  

Tthey are written in Swift and Kotlin (iOS and Android respectively).
I have never studied or tried to learn Swift and I am allergic to Java and its friends.
That said, I can usually read the logic of code based on experience in other languages so I can spot bad math, logic and know enough to ask why something is being done.
This doesn't mean, though, that I wasn't misled by the AI.

These apps are the result of a long process of "learning to prompt" and exploring ideas I have seen from others as well as where my thoughts naturally went.
While they do have testing, it is mostly LLM generated, and honestly, not all that great.
Swift is a less commonly consumed language in training sets, as far as I can tell, so the LLMs aren't great at it.
Writing Phone apps is also pretty low-frequency so even the Kotlin, which I suspect is of higher quality, is often challenging to get right as the idea of restricting yourself to what Android can do is tough for the LLM.

Looking at this, I definitely can't explain every line of the code.
There is just a ton of boilerplate and other setup work required by a phone app that I don't know.
I didn't look into how the layouts work or why the various screens that are created are implemented the way they are.
However, I can explain what is happening in broad strokes and why.

When it comes to the logic of my app, I can 100% explain it and how the data is being used, even if I may not be able to tell you exactly why the data is retrieved via that specific call or stored in that specific data structure.

However, I don't think I used, as Simon suggests, an LLM as a typing assistant.
I think I am somewhere in between.

While drafting this post, I had the need to write a small go-lang program that uses an SDK to access 1Password.  It does some Linux effective user manipulation as well.  I understand everything I wanted done in principal, but I am not a go-lang developer and have never used the SDK before.  I haven't written effective user code since college and when I did it was in lower level C.

I wrote a simple spec and rounded up the SDK's sample code and gave the whole thing to Deepseek.  The [result](https://github.com/bexelbie/op-secret-manager) is 100% AI generated down to the README (which needs work!).  I have it running on a server solving a problem I actually have.  It is a simple program for sure.  But, it is also one where I am unprepared to explain the intricacies of every line or the selection of one methodology over another.

Did I vibe code?
Did I do a "bad thing"?
When I go add more features is it going to be a problem or a mistake that this is how I started?
I am on the fence right now, but I am thinking the answers are: no, maybe, and unlikely.  In particular, on the last one, I have found the biggest challenge is getting the LLM context for the change.  With larger codebases, that is a problem others are working on too so I have faith it will be solved.

What do you think?