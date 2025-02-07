---
date: 2025-02-07 11:55:00 +0100
title: Nostalgic Noises
excerpt: 
tags:
  - Life Lessons
  - Personal
  - Random
categories:
  - Ramblings
---

While walking through my hall yesterday, I heard the sound of rushing water. No, wait—some kind of machine? A window open to the wind? No. It was my NAS (Network Attached Storage), hard at work.

In October last year I bought a Synology NAS and decided to get my data story straight.  It was long past time to just tuck things away on cloud drives or Patrick's NAS and ignore thinking about a solution that really met my needs.  I dutifully set it up and moved all of my tiny amount of data on to it.  I put it above the front door in my "network closet" and left it to do its thing.

Fast forward to yesterday, when I unexpectedly started hearing it.  Earlier that day, I realized I was again going to need to, frustratingly, `grep` my old mail archive to find the right email with its attachment.  It is stored in `offlineimap` curated maildir folders.  I had changed mail providers and the idea of dumping it all into Google or Apple mail just didn't sit well with me.  And Patrick said grepping the mail was fine for him.

I am not Patrick--let's just say, grepping mail wasn't working for me with all the MIME encoded attachments.  Synology has a Mail Server application.  It seems pretty straightforward so I turned it on.  Huzzah - imap.  Perfect.  Now `offlineimap` was slowly copying over a decades old email from one part of the NAS to another.  This was the rhythmic noise I heard.

A chat exchange with my friend Adam said it well:

![Me: It is funny how much I am aware of the noise of the NAS while it chugs at moving emails from Point A to Point B.  Adam: I love the noise, it's a nostalgia machine! :D.](/img/2025/nostaligia-noise.jpg)

Hearing my NAS chug away reminded me of an essay I'd recently read, but now can't find.  The author described how you used to know what a computer was doing based on how it sounded.  They went on to point out that you could tell your compile failed immediately because you hit enter and the fans didn't kick in a few seconds later.

This morning I woke up to find my terminal session to the container on the Synology running `offlineimap` disconnected.  But I knew everything was fine and there was no need to take action.  I could hear the rhythmic chant of email marching from place to place—-proof that everything was working just fine.