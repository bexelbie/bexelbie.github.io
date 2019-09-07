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

This series of articles details my thoughts and ultimate process for solving data backup.  In the [first part](part1.md) we started by tossing a phone in a river.  We then explored what backup and recovery means, learned about the theory and started thinking about what we should be doing.  I encourage you to start with [part 1](part1.md) if you haven't already read the preceding parts.  This part picks continues by exploring how we can think about data and classify it.  As you'll see below, it is less important to think about what the data is, i.e., pictures versus tax returns, and more important to think about the characteristics it has.

## Homework Review

In [part 2](part2.md) I asked you to think about the definition of local and remote.  I also asked you to think about recovery scenarios.  I've detailed my answers for remote and local below.  My thoughts on recovery were in the [previous part](part2.md).

While I travel a lot for work, I am not a digital nomad and I have a permanent home-base and an office I can visit.  Here are my answers:

### Remote

For me, remote is going to be cloud storage.  I know I don't have the personal discipline to regularly move drives between my home and my office.  I also no longer drive to work, so options like the car truck are out (and kind of a joke anyway).  Cloud storage is going to allow me to really have my data far away from my local copy, possibly even on a different continent.  I debated and rejected storing an internet accessible drive at a family members home.  This creates another piece of equipment to maintain and that is something I don't want.

### Local

The 3-2-1 rule suggests the need for two local copies.  One is easy, my laptop.  The working copy of my data is on my laptop.  This is true for the data that will meet the 3-2-1 rule requirements.  Some of the variants that were introduced in the [second part](part2.md) have fewer local copies.

My other remote is going to be one or more external hard drives.  I may wind up doing some local mirroring to guard against drive failure.  I don't know for sure, as I haven't gotten to implementation yet.  Today I own three external hard drives, however they are quite old, a 1TB drive from 2010, a 3TB drive from 2012, and a second 3TB drive from 2013.  These need to be thought about carefully during implementation.

I hope you had some good thoughts about these topics.  I encourage you to keep sharing your ideas with others so your forced to explore them fully.

# What kind of data do I have?

## How easy is this data to recreate or get from someone else?

There are a lot of ways to define data.  An easy one is based on the ease of getting it again from a third-party or recreating it.  For example, your operating system files are, generally, trivial to retrieve again from the distributor so you don't need to bother backing them up.  Your system configuration (or photos, etc.) are almost impossible to get back from a third-party and may be impossible to recreate.  This classification is a great way to think about what you may want to backup versus what you don't have to backup, however, it doesn't help you apply the 3-2-1 rule and its variants.

## How important is this data?

Another way to look at data, is to divide it by value.  How important is this data?  A simple model is to rank the value of data as:

* High - has lots of value to me, such as photos of my family or financial records.
* Medium - has some value to me, but loss would not cause me serious harm, such as a boring personal movie file that I never watch again, but don't outright want to delete.
* Low - commodity data that is easily replaced, such as copies of commercial songs or movies.  If infrequently accessed, it might even be worth deleting this data to free up resources.

These dimensions start to provide us with a way of looking at the 3-2-1 rule and its variants.  High value data should get the full 3-2-1 treatment.  Medium data may need that or could qualify for 2-1-1 treatment if it is infrequently accessed.  Low value data is a candidate for the 1-1 rule.

## Is the data hot?

Storage providers often use terms like 'hot', 'warm', and 'cold' when classifying their products.  "Hot" products are data storage that is quickly consistent and always available for read, write, and delete.  "Warm" products are typically slower to read, but faster to write and delete.  They may also have delayed or eventual consistency.  "Cold" products are often structured to be effectively write-only.  The data may take a long time reach consistency and is not expected to be needed for read or delete without notice and it can take a long time to perform those actions.

I believe these terms apply to data in this manner:

* Hot - This is working data that is in frequent use and would need to be recovered quickly in case of loss, such as a novel you are in the process of writing.
* Warm - This is infrequently changing data that may have a higher frequency of read activity, such as old photos.
* Cold - This is data that is being saved but may never be needed, such as old tax returns.

The level of inconvenience you are willing to put up with in a backup/restore solution increases the cooler data is.  It is ok if restoring a 10 year old tax return takes significantly longer than restoring a picture of my child.  Not having access to my active work effectively puts me out of business until it is recovered.

Hot data is a strong candidate for versioned or archive-style storage, if that is an option or consideration.

## Where else is my data naturally?

Some of my data is automatically saved in other places.  For example, photos taken on my phone are automatically uploaded to a cloud storage provided by my phone vendor.  Spreadsheets I create in an online editor are automatically, and only, saved in the vendor's cloud storage.  I believe this leads to two more data divisions:

* Data automatically saved by others: This data is probably safe to consider as already being remotely saved, even if it isn't in a "raw" form for access[^2].
* Data only saved by others: This data is tough.  I need to decide if I need to force a new copy into existence.  By default it is 1-1 (1 copy; 1 copy stored remotely).  I suggest that you need to decide how reliable you believe the vendor is to decide if you need to do an additional backup.

In general, I believe that data stored by a major vendor, such as Google, is probably significantly safer than data stored on a random etherpad provided by a random human.  For both of these types of data you need to also consider if you will likely have notice in the case of service shutdown or failure.  A major service provider is more likely to provide notice and a transition plan for services, even free services.  Lastly, I think that data stored by a vendor is almost always going to be more reliably maintained than data I manage on my own.  I know myself ...

[^2]: In this case, "raw" means that I can't necessarily directly access the file with a traditional file manipulation tool such as `rsync` but may instead be required to use my vendor's application to access my data.

## Conclusion

Classifying your data by attribute will make it much easier to think about the backup strategy to employ.  Whether time, money, or energy, backing up data costs something.  Let's minimize that cost.

Read the next part to take the data in each category and apply our goals to it.  I've included some optional homework below.  You may find it useful if plan to adopt or adapt this for yourself.

## Homework

Thinking about these data classifications, make a list of what actual data you have in each category.  Estimate the size of that data.  Is it bigger or smaller than you thought?  When thinking about how data is classified, it is often useful to go with your first instinct.  Don't let the size of the data (and the perceived potential costs) distract you right now.  Trade-offs, if required, will get made once those costs are fully known.
