---
layout:   post
title:   "We Need a Password Change API"
subtitle:  "because I got pwned"
date:    2017-03-09 08:50:00 +0100
author:   "Brian Exelbierd"
#header-img: ""
published: true
category: Technology
tags:
 - Fedora
---

# What is the Sound of One Phone Drowning

We are walking down the street together and I ask you what kind of phone you have.  You answer by showing me your phone and I say, "Oh, like this one?"  We swap phones and you're mildly amused to discover I have a brand new phone just like yours.  However, at the same time you're horrified as you see me take your phone and throw it into a nearby river, destroying it.  I turn to you and say, "you can keep the new phone."  After you recover from the shock, how upset are you?

Depending on your phone's settings and software, you may be completely OK.  Almost no data is stored solely on your phone.  In many cases, even data that is created by your phone, such as pictures, is immediately backed up to a cloud storage system.  You may have lost your favorite phone case or some settings which for some reason aren't backed up, but for the most part you can be back up and running quickly by just downloading your apps and logging in again.  Your phone's software has done most of the hard work of backing up your data for you.  Replay this scenario with your laptop and for the vast majority of us the world just got more complicated and the data loss is very very real.

It doesn't have to be like this.  I've been wondering how I would handle this situation recently and I realized that my poor backup habits have put me at serious risk of problems.  I'm going to use this article series to explore the kinds of data I have and how they should be backed up.  Along the way I want to learn to think about data security and to carefully consider the kinds of backup, and most important restore options I should be using.  I expect to write answers to the following questions:

1. What kind of data do I have?
2. What are the general principals for data security and backup that apply to each kind of data?
3. What does it mean to restore?
4. How do I do implement all of this?
5. Bonus: What about my phone or my cloud data?

To limit the scope of this article, I will only be considering data on my primary laptop and external drives.  I will not be considering the difference between personal and work data.  What this means is that you may need to consider your work data relative to your employer's policies and not my suggestions.  Also, I'm going to make the false assumption that my phone is self-backing up as in the example above and that I only need to worry about it's data when it becomes available on my laptop.  Lastly, I am completely ignoring data that is mine but lives solely on other people's servers.  I'd like to revisit those last two in the end.

# What kind of data do I have?

Data is like water[^0].  OK, not really.  Regardless, I think there are about 5 kinds of data that I need to worry about.  The first three kinds are my user-generated data.  These are things like this article, photos of my cat, my tax returns,  This data has three temperatures, cold, warm and hot.  These data types suggest two (or three) different sets of requirements for backup.  The last two have to do with the operating system itself.

[^0]: People like analogies and I tried really hard to come up with one.  Well, it didn't quite work out as you'll see.

## Cold Data

Cold Data is data I want to ensure gets backed up but is rarely used.  This is data like old photos.  I want it to be available pretty much forever, even if I am not using it right now.

This data can be backuped up in inconvenient ways (not online) or be slow to recover in the case of a serious need for disaster-based recovery.

This data is easy to identify and segregate from the rest of my stuff.  I don't mind manually deciding that something is *cold*.  I call it cold mostly because the marketplace has chosen that analogy for many products in the space, think of Amazon Glacier and Google Coldline Storage.

## Hot Data

The opposite of cold is hot.  Hot Data is data I am using right now.  No, seriously **RIGHT NOW**.  The drafts of this article are hot data.  This data is constantly changing or needed immediately.  In a disaster situation this is the first stuff I will restore.  Some of this data might even be restored to a temporary device just to let me keep working while I wait on replacement hardware.

Backups of this data needs to be fast and easy.  Ideally this data can also be backed up in a versioned manner so that I have multiple possible restore points.  While I've almost never needed it, this takes care of the "ooops, I deleted the file yesterday and need it today" problem or the "I want the text I deleted from this document back" problem.

## Warm Data

Warm Data is what happens when *hot* data starts to cool. This is data I've recently worked with but which is unlikely to get further heavy use.  This is also data that has a known next use date that can be planned for and predicted.  This weird category is things like receipts that may get used just once more to prepare my year-end financials.  It also contains things with relatively short shelf lives, such as photos.  If I don't post them online pretty soon after they are taken, they get more unlikely to be used again as time passes.

This data should start out backed up like *hot* data.  Versioning isn't needed.  At some point, it would be nice if the system would transition it to be being backed up like *cold* data, assuming there is a cost or management savings for doing so.

## Stove Data

And this is where the analogy completely fails.  Stove data is the actual Operating System and programs I use to do my work.  There is basically no reason to back this up.  99% of the time this is available from multiple sites and easily re-downloaded.  If I have software that is likely to disappear, such as that from a small software vendor or a specific version that is required by me but may get replaced on the mirrors then I may need to back this up like *cold* data above.  But, in general, I am willing to stipulate that my restore process starts with installing the base OS and programs from their vendor provided sources.

## Kettle Data

You didn't think this analogy could get worse.  If my data is like water and my OS is a stove, then obviously I have to have a kettle to heat the water.  Kettle data is the configuration settings for my system.  I can use any number of kettles to heat my data, but I like mine and you like yours.  Our different kettles therefore are what make our systems unique.  Kettle data is a weird combination of *hot* and *warm* data.

2. What are the general principals for data security and backup that need to be considered?
3-2-1 backup rule
  3 copies
  2 different devices/media
  1 copy offsite
  http://www.networkcomputing.com/storage/3-2-1-backup-rule-recovery/108368175
evaluate actors per FSFE or whatever
Trust No One

3. What does it mean to restore?

4. How do I do implement all of this?
If you're writing your own backup script I feel bad for you son,
I've got 99 problems,
but not being able to restored because I messed up the options to `rsync` isn't one.

4a. What about versioning hot data

5. Bonus: What about my phone or my cloud data?
