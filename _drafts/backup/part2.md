---
layout:   post
title:   "Thinking about Backups"
subtitle:  "because disks gonna fail, yo!"
date:    2017-03-09 08:50:00 +0100
author:   "Brian Exelbierd"
#header-img: ""
published: true
category: Technology
tags:
 - Fedora
---

This series of articles details my thoughts and ultimate process for solving data backup.  In the [first part](part1.md) we set up the background by tossing a phone in a river and began thinking about our goals.  This part picks up with knowledge and introduces principles needed to be successful.  This is not intended to be a comprehensive primer on backups and it doesn't detail implementation at all.  Theory is critical at this point, implementation details now would just be distracting noise.

Normally I'd start by sharing my answers to the homework, but in this case, my answers were the writing.

# What is the general theory of backups and archives?

Backups are just copies.  Archives are when you begin store multiple copies so you can store your data as it was at different points in time.  In this series, I am not concerned about archives.  I have not found them to be of much use to me personally.  Typically the old version or deleted file I want back was destroyed in the last few minutes, not a long time ago.

## The 3-2-1 Rule

The [consensus](https://www.linkedin.com/pulse/backup-best-practices-3-2-1-1-0-golden-rule-raymond-goh) [opinion](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/) [about](https://www.carbonite.com/blog/article/2016/01/what-is-3-2-1-backup/) backups has converged on something called the 3-2-1 rule.  The rule states that for your data you should have:

* 3 copies of your data
* 2 copies on different mediums which are local
* 1 copy stored remotely

For typical data, this means that I have a copy on my laptop, on an external hard drive and backed up to a cloud provider.  I have technically failed the "2 different mediums" rule, but can cheat by saying the goal is to either ensure I don't have a single machine failure delete all my local data, or I can point out that my laptop has an SSD and the external drive is a spinning disk.

## The 2-1-1 Rule

I agree with the 3-2-1 rule in principal, although, I believe that like most rules, it can be broken.  Also like most instances where you break a rule, you need to be sufficiently skilled to know when and how to break it.  I believe that for some types of data, the rule is really 2-1-1:

* 2 copies of your data
* 1 copy stored locally
* 1 copy stored remotely

This rule is most often seen in cases where data is not naturally in two places locally during your daily use.  A large data set stored on an external drive, for example, and mirrored to a cloud provider may not not naturally also be on your laptop. Therefore, you have only 1 local copy.  This data can be forced into the 3-2-1 model by having a second storage device you keep in sync with your primary storage.  This adds a layer of human effort that I am not sure is practical.  If you want to do it, or you determine it is required, then substitute 3-2-1 wherever I write 2-1-1 and happy mirroring.

## The 1-1 Rule

There is also a tiny amount of data that I believe can be treated even more radically.  This is the 1-1 rule:

* 1 copy of your data
* 1 copy stored locally

This is data that is never stored twice and you decide to gamble on not having a storage failure.  I strongly discourage choosing this policy without fully understanding the risks.  Interestingly, this is actually the policy most of us have adopted by default.  This is sad.  This will not be a cute story.

We'll explore these rules, especially the 1-1 rule,  relative to data types later.

# What does it mean to restore?

Restoring is the act of getting your data back from an backup.  It is a lot more than just reversing the process though.  Depending on the kind of situation you have, you may be starting with a brand new computer that needs an operating system and settings.  In other cases, such as with mobile phones, you have a functioning device but just need to get your data back.  There is no point in backing data up, if you don't have a plan for recovering it.

Restoring can also mean recovering very specific files, such as those you accidentally deleted, or going back to previous versions of files you have overwritten.

A good way to think about restoring is to consider your likely needs.  For example, if you always buy your laptop with an operating system pre-installed, you're unlikely to need to do a bare-metal restoration.

For me, I believe these scenarios are likely:

* Recovery of all data and settings to a brand new laptop that has no operating system.  I currently run [Fedora](https://getfedora.org) and it doesn't come pre-installed.
* Recovery of all data stored on an external disk due to disk failure.  There are only two kinds of disks, those that have failed and those are that are going to fail.
* Recovery of all data and settings to my mobile phone, which comes pre-installed with an operating system and uses the vendor's application store.

As I mentioned above, recovering recently deleted files and rolling back to older versions is rarely something I need.  It is not important enough to make my list of recovery requirements.  For most files I am solving this problem with version control systems such as `git` that are outside of the scope of this series.

## Conclusion

This short introduction to the theory behind backups, especially the 3-2-1 Rule will allow you to start making choices.  As you'll see in the next section, not all data is easy to think about and a lot of companies and devices are trying to solve parts of this problem for you.  Take advantage of that.  We also talked about recovery, possibly the most important part of the whole question.  If you can't recovery it, you may as well have never backed it up.

Read the next part to begin thinking about how to classify data so you can figure out what to do about it.  I've included some optional homework below.  You may find it useful if plan to adopt or adapt this for yourself.

## Homework

1. One of the major principles of the 3-2-1 rule is the separation of backups into "remote" copies and "local" copies.  What do these places mean to you?  For some of you remote could mean everything from the trunk of your car to the cloud.  Local may harder to define if you're a digital nomad where even local copies are always literally right next to each other.  If you had to store objects or buy services, what are the things about them that make them local or remote.

2. What are the likely recover scenarios for you?
