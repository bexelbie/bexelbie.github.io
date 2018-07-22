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

# How do my goals and needs apply to each kind of data?  What Rule is best for each type of data?

This series of articles details my thoughts and ultimate process for solving data backup.  In the [first part](part1.md) we set up the background by tossing a phone in a river.  I encourage you to start there if you haven't already read the preceding parts.  Let's continue by applying our goals to the types of data we have.  This way we can make sure we know how to 

## Homework Review

In the homework, I asked you to think about what actual data you have, how large it is and how it applies to the categories.  First, here is a snapshot of my data:

### bex's Data

I analyzed the broad categories of data I have saved and discovered these numbers:

---|---|---
Size|Description|Current Locations|Notes
---|---|---
150 GB|Photos|Mobile Phone Cloud Storage; External Hard Drive
135 GB|Music|External Hard Drive x 2; also on Mobile Phone but may not be able to be copied out|The majority is commercial music
9.3 GB|Software Install Media|External Drive x 2
3.5 GB|ebooks|laptop|Various PDFs and ebooks
3.4 GB|Personal Data - old|External Drive x 2|Financial Records, journals, etc.
1.6 GB|Personal Data - current|laptop
0.5 GB|Personal Data - cloud|laptop; cloud provider|A mounted cloud drive that I use mostly to move files or make them available easily everywhere
0.1 GB|Personal Data - online|online provider|a few spreadsheets and docs I maintain only in an online office suite; much less than 0.1 GB

Raw Total: 303.4 GB

A few of these data buckets are stored on a pair of manually mirrored external hard drives.  To ensure accurate cost estimates, I am going to proceed as though there is only one copy so I make a conscious decision about the cost of making a manual mirror copy.

Also, this is a lot less data that I realized I had.  Over the years I have been purching unneeded data and I have about 300 GB in transient data that is either in Future Trash[^2] or otherwise is unimportant to gurantee.

[^2]: Files with a known deletion data that are unlikely to be needed again are stored in a series of Year-Month directories in the Future Trash.  They get deleted when their directory Year and Month are over.

### Data Categories

I [defined](part3.md) the following categories of data (with their values, where defined):

* How easy is this data to recreate or get from someone else? (Easy, Hard)[^1]
* How important is this data? (High, Medium, Low)
* Is the data hot? (Hot, Warm, Cold)
* Where else is my data naturally? (Auto Saved, Only Others)

[^1]: To make the table nicer, these categories represent the difficulty of getting the data from a third party.

### bex's Data Categorization

Now let's put it all together

---|---|---
Description|Ease to get|Importance|Temperature|Elsewhere?|Notes
---|---|---
Photos|Easy|High|Hot & Cold|Auto Saved|Easy to get back because auto-saved; Hot for new photos and Cold for old ones
Music|Easy|High & Low|Cold|n/a|A few files are unique, but the bulk are trivially replaceable commercial music
Software Install Media|Easy|Low|Cold|n/a|A few may have to get re-bought to be downloaded again ...
ebooks|Easy & Hard|Low|Cold|n/a|I rarely read these books twice and many are commercial titles ...
Personal Data - old|Hard|High|Cold|n/a
Personal Data - current|Hard|High|Hot|n/a
Personal Data - cloud|Hard|Medium|Warm|Auto Saved|Most files are duplicates or ephemeral but it isn't sorted ...
Personal Data - online|Hard|High|Hot & Warm|Only Others

## Goals Refresher

Let's review my goals, so we can keep them in mind when assigning probable backup rules rules.  Several of the goals only apply to the overall system, not the data, so let's eliminate those from consideration.

### System Goals

* is automatic
* is easy to add new data too, ideally in an automatic way
* is easy to restore from, including from bare metal, ideally in a systematic well documented way
* is relatively "future-proof"
* upgrades my level of security (Nice to Have)
* upgrades my level of data/process documentation (Nice to Have)
* is based on free and open source processes and principles (Nice to Have)
* is built on services where I am the customer, not the product (Nice to Have)
* can be adapted and adopted by others (Nice to Have)

### Data Goals

* saves data that I know should be kept
* strikes a balance between cost (money, effort, etc.) and loss of data when making decisions

These two data goals can be used to think about the rules we might want to assign to the data.

## Rules Refresher

In [part 2](part2.md) I proposed some backup rules:

* 3-2-1: The highest level of protection
    * 3 copies of your data
    * 2 copies on different mediums which are local
    * 1 copy stored remotely
    * Note: A variant of this rule that will occur is 3-1-2 where there are two remote copies and one local copy.
* 2-1-1: Great for data already automatically saved by a reliable third-party; also useful when there is naturally only one local copy
    * 2 copies of your data
    * 1 copy stored locally
    * 1 copy stored remotely
    * Note: A variant of this rule that will occur is 2-0-2 where there are two remote copies stored separately.
* 1-1: Data that I won't be upset if I lose, but I don't want to just delete
    * 1 copy of your data
    * 1 copy stored locally

### bex's Data by Likely Rule

Now let's assign a likely rule to each data element.  It is only a likely rule as we don't have the costs figured out yet.  These rules may be modified as we make trade-off decisions during implementation.  In a few cases, our desired rule varies from the natural state of the data.  If the natural state is potentially acceptable, both will be listed.

---|---|---
Description|Likely Rule|Notes
---|---|---
Photos|2-1-1 => 3-2-1|No raw access makes me feel like a second copy is needed.
Music|2-1-1|For the easily replaceable songs
Music|3-2-1|For the hard to replace songs
Software Install Media|1-1
ebooks|2-1-1|Given how little re-reading I do, probably not worth extra costs.
Personal Data - old|3-2-1
Personal Data - current|3-2-1
Personal Data - cloud|2-1-1|Should I back up a cloud provider that has raw access?
Personal Data - online|2-1-1|It's too important to have only one copy.

## Conclusion

We've now determined the magnitude of the challenge (relatively small in my case) and some likely rules to apply to achieve my goals.  Now we can start designing a system.  It looks like we are going to need to consider solutions for every rule and most every combination.

Read the next part to begin exploring an implementation to make this happen. I've included some optional homework below.  You may find it useful if plan to adopt or adapt this for yourself.

## Homework

Categorize and classify your data using the rules to generate your own likely rules matrix.  This will allow you to determine what parts of the system you need.  While doing this notice if you have only a little data in a particular rule.  One trade-off you may want to make early is forcing a data rule "upgrade" to avoid having to develop a solution for a small amount of data.
