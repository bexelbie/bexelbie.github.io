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

# What is the Sound of One Phone Drowning

We are walking down the street together and I ask you what kind of phone do you have.  You answer by showing me your phone and I say, "Oh, like this one?"  We swap phones and you're mildly amused to discover I have a brand new phone just like yours.  However, at the same time you're horrified as you see me take your phone and throw it into a nearby river, destroying it.  I turn to you and say, "you can keep the new phone."  After you recover from the shock, how upset are you?

Depending on your phone's settings and software, you may be completely OK.  Almost no data is stored solely on your phone.  In many cases, even data that is created by your phone, such as pictures, is immediately backed up to a cloud storage system.  You may have lost your favorite phone case or some settings which for some reason aren't backed up, but for the most part you can be back up and running quickly by just downloading your apps and logging in again.  Your phone's software has done most of the hard work of backing up your data for you.  Replay this scenario with your laptop and for the vast majority of us the world just got more complicated and the data loss is very very real.

It doesn't have to be like this.  I've been wondering how I would handle this situation recently[^0] and I realized that my poor backup habits have put me at serious risk of problems.  I'm going to use this article series to explore the kinds of data I have and how they should be backed up.  Along the way I want to learn to think about data security and to carefully consider the kinds of backup, and most important restore options I should be using.  I believe I need to answer a series of questions to find a solution.

1. What are my goals or needs?
2. What is the general theory of backups and archives? What does it mean to restore?
3. What kind of data do I have?
4. How do my goals and needs apply to each kind of data?
5. How do I do implement all of this?

This is part 1 of the series that addresses these questions and more.  This series is not for you if you don't want to have to think about your backup strategy.  This series is not for you if you consider your effort and time to be worth more than your money.  In both of these cases you should probably just purchase a monthly backup services from one of the major providers and move alone.  If you'd like to optimize your backup for cost or to give more consideration to security and methodology, you may find this series useful.

To limit the scope of this series, I will mostly focus on data on my primary laptop and external drives.  I will not be considering my employer work-related data.  What this means is that you may need to consider your work data relative to your employer's policies and not my suggestions.  Also, I'm going to make the false assumption that my phone is self-backing up as in the example above and that I only need to worry about it's data when it becomes available on my laptop.  Lastly, I am not worried about local drive corruption destroying my backups.  This is real, but not something I'm focused on.

[^0]: Where recently is defined as "over a year of long forced conversations on those around me."

# What are my goals or needs?

Along the lines of thinking about [tidying up](https://www.amazon.com/Life-Changing-Magic-Tidying-Decluttering-Organizing/dp/1607747308) or [Swedish Death Cleaning](https://www.amazon.com/Gentle-Art-Swedish-Death-Cleaning/dp/1501173243) I suggest you start by thinking about why you need backups and what you hope to accomplish.  For a variety of reasons, not everyone needs a backup and not every file needs to be backed up.

## Goals (Must Haves)

Below I am listing my goals and a brief rationale.  These are my goals.  Your goals may be radically different or very similar.  However, you need to define them yourself.  You can't just adopt someone else's values/goals and expect them to work for you.  I hope you will find these inspirational.

My goals are to finish with a process that:

* is automatic.

    If it isn't automatic, it won't get done or won't get done on time.  Over the years, I've resisted automatic billpay services.  I can count, thankfully on one-hand, the number of missed payments I've had.  Automatic is a key factor for me.

* saves data that I know should be kept.

    If it is important, it had better be there.  I don't want to ever lose some of my photos, for example.

* strikes a balance between cost (money, effort, etc.) and loss of data when making decisions.

    On the other hand, not everything is worth a huge effort to save.  While calculating a vanity metric[^1] I needed access to my paystubs from 2008.  I am glad I had them, however the world would not have ended had they been lost.  In fact, [most folks](http://wealthyaccountant.com/2017/07/12/how-long-should-you-keep-your-records-and-tax-return/) would tell you they should have been tossed years ago.

[^1]: A metric that makes you feel good but doesn't convey much useful information.  In my case, the [LWR](http://www.budgetsaresexy.com/total-lifetime-earnings-wealth-ratio/).  Maybe I'll write more on that later ...

* is easy to add new data too, ideally in an automatic way.

    If I have to work hard to add data, I will just get back to where I am today.

* is easy to restore from, including from bare metal, ideally in a systematic well documented way.

    A backup is only as good as its restore.  I don't forsee restore events being often, so I need to have this documented so I know what to do.  In an enterprise environment, I suggest you have periodic bare-metal recovery tests.  In my case, I will probably only manage this every three years when I get a new laptop.

* is relatively "future-proof."

    Backups are for the long-term.  I need to know that it is unlikely that the software and services that I use will go away or become unsupported/unusable.  This is obviously not predictable, but I am going to take my best guess.  This also means deciding how much notice I think I will get when, not if, the software or service is deprecated.

## Goals (Nice to Haves)

* upgrades my level of security.

    My current security practices are reasonable.  Since I am going to be creating a process that touches a lot of my data, this is a great chance to "get it right."  So, while I am here, do some [threat modeling](https://ssd.eff.org/en/glossary/threat-model) and plan accordingly.

* upgrades my level of data/process documentation.

    I have started, but never published, an Ansible playbook to rebuild my system.  It is a once every three-years event, assuming no failures.  This needs to get cleaned up and published so that it becomes something I can really use in a failure scenario.

* is based on free and open source processes and principles.

    Sharing is caring.

* is built on services where I am the customer, not the product.

    I believe that service providers deserve to be paid.  If I am not, [I am the product, not the customer[(https://www.quora.com/Who-originally-suggested-that-if-youre-not-paying-for-the-product-you-are-the-product)[^2].  I have mixed feelings about listing the services I use.  Let me know if you think this data would be useful.

[^2]: Note: Just because you pay doesn't magically mean everything is better.  See [Derek Powazek](http://powazek.com/posts/3229).

* can be adapted and adopted by others.

    If this is useful for, I win.  If this is useful for you too, we both win!  Everyone winning is better in this case.

## Conclusion

By knowing my motivations I can quickly evaluate strategies and make decisions.  Thinking through what I want also allows me to make trade-offs, i.e., is security more important than automatic functioning?

Read the next part to begin exploring the general principles behind backups so you have a firm starting point.  I've included some optional homework below.  You may find it useful if plan to adopt or adapt this for yourself.

## Homework

Develop your own goal list and figure out what you need.  You don't have to figure out how to do it yet, but think about what you really want.
