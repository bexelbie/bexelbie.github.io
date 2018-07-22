---
layout:   post
title:   "'Reading' XXX Emails A Day"
subtitle:  "and staying sane"
date:    2018-05-05 08:50:00 +0100
author:   "Brian Exelbierd"
#header-img: ""
published: true
category: Technology
tags:
 - Fedora
---

**Fix links with ...**

I estimate that I receive about XXX emails each working day.  This is just the email I receive related to my contributions to [Fedora](https://getfedora.org), a few projects I monitor for personal reasons, and my work at [Red Hat](https://community.redhat.com) as the [Fedora Community Action and Impact Coordinator](https://docs.fedoraproject.org/..../fcaic.html).  It's a lot of email.  It's less than some people, I know and compares to the average (best guess) 800 emails a day my colleagues receive.

I read all of this email and figure out how to handle it using a 3 step system to filter incoming email for further processing.  Before I continue, I should define "read."  I consider an email "read" when it has received the amount of attention it deserves.  This doesn't mean I read every word of every email.  This sounds like cheating to some of you, but I know no one who I believe can claim they read every word of every email at these volumes.

Please note, this is not an Inbox Zero article.  There is nothing wrong with Inbox Zero, but this isn't about that.  Also, for reasons beyond the scope of this article, all of this email is delivered to Gmail.  Therefore I describe these tiers in terms of labels and, where needed, offer some example filters.  This can be implemented in any reasonably capable email filtering system and I have used similar ideas with my personal email which is is hosted at [PoBox.com](https://www.pobox.com).

The 3 steps define 5 tiers of email that ultimately result in 4[^1] inboxes (in this article, your main inbox is denoted as `INBOX` while other places email can land are called `inbox` or `inboxes`) where new mail can go.  One is a traditional inbox as you're accustomed too.  The other three are just folders (or labels in Gmail) where new mail will arrive.  If you check all four places you will have read everything.  Tiers are described in reverse numerically moving from least important to most important.

[^1]: Why 3 steps to define 4 inboxes based on 5 tiers?  You'll see in the next section that one tier trashes email.  This also sets up the opportunity for the worst ever rewrite of the 12 nights of Christmas.  Don't tempt me!

Get yourself into a "happy place," and follow along:

# Step 1: Take out the Trash

We all have some email we can't avoid getting that we already know is trash.  For me, this comes in several forms, including an email list at work that has no value to me but which I am not supposed to unsubscribe from and automated system emails (i.e. cronjob output[^0]) sent to otherwise useful mailing lists I receive.

[^0]: As of today, I am not "empowered" to fix any systems that report failure via these mechanisms.  This may change over time.

These emails should be trashed immediately.  In Gmail I just archive them so they can be found later.  If I was on a system with more limited space, I would consider either immediate deletion or having them held for only 30 days in case I found a reason to need them.  More about this later.

For these emails I have developed a set of filters that do the following:
* Skip the `INBOX`
* Label it `auto-archive`

Why the label?  The labels are serve as flags for what filters were executed for email.  This greatly aids debugging.  For example, if I discover that mail I wanted to see is missing, the label will tell me which filter triggered the archive.  Conversely, if I find email I didn't want being shown to me, I can figure out which filter caused that too.

# Step 2: Identify the emails

A co-worker of mine, [Stef Walters](https://....) has been giving a great talk on [hybrid robot human teams](https://....).  Watch it if you haven't already.  One of the key tenants of having robot coworkers is that you have to train them to do their jobs, much like many junior colleagues.  This step is all about training the bots.

In this step think about your email as different kinds of things.  Don't stick to traditional buckets, "like from mailing list X."  Instead, think about the different kinds of email you get in broader categories that consider the nature of the email separately.  Your list will vary, but mine includes:

* Email from Bug/Issue Trackers and Git Forges
* Email from my boss or important colleagues
* Email that require specific action from me (i.e. Approve held messages for a mailing list)
* Email from a mailing list that is usually "interesting"
* Email from a mailing list that is rarely "interesting"
* Calendar/Meeting notices
* Email about a particular project or technology
* Email actually addressed to me!

For each of these categories, create a filter which will label it.  These filters just label.  They don't Skip the `INBOX` or do anything else.

There is one *gotcha* here.  You need to think a bit about the order of the categories.  What you may discover is that some filters should be allowed to act on email you threw away in step 1, while other filters shouldn't.  At least in Gmail, all email is tested against every filter.  Therefore you may need to use a bit of "magic" to change your labeling.  Let's look at some examples:

## Email from Bug/Issue Trackers and Git Forges

These days I am a "spare-time" engineer.  Therefore I receive some issue reports from Bug Trackers like [Bugzilla](https://bugzilla.redhat.com) and from git forges like [Pagure](https://pagure.io).  Fedora's use of Pagure includes both code and non-code work so the issues from it can vary a lot.  In this category I also include the automated alerts I've signed up for from the [Fedmsg System](https://....).

To capture these, I've created a series a filters that label email based on conditions such as:

    (from:notifications@github.com OR from:git@pagure.io OR from:bugzilla@redhat.com OR from:bugs@centos.org OR from:pagure@pagure.io) AND NOT has:userlabels

The label again serves as a way to debug if there is an error and to ultimately land things where I will read them.  There is an interesting element to this filter, the `has:nouserlabels` condition.  This condition (and the corresponding `has:userlabels`) allows you to make decisions based on the presence of any labels on the email (or thread).  In this case, the presence of other labels mean I decided the email was trash (see Step 1).  Because of this, I am using `has:nouserlabels` as a way of not processing the email further.

## Email from my boss or important colleagues

In contrast to the first example, here we definitely want to flag these emails, no matter what.  For this I have a filter that labels the email based on a set of email addresses.  With the addresses omitted, it looks like this:

    from:a@example.com OR from:b@example.com OR from:c@example.com

These emails all get labeled with the 'from-people' label so they can be sorted out later.  I do not test for the presence of other labels because these people are important to me and I want to see anything they write.

## Email from a mailing list that is usually "interesting"

Many filtering systems, including Gmail allow you to filter on List-ID.  As you saw above, I am not advocating just creating a label for each list.  You can do this if you want, but I find it very unnecessary.  First, later on when we go to sort the email you're going to wind up with very long filter conditions and may run up against length limitations.  Second, I find it useful to consider lists as a group based on the likelihood of my reading an email from them.  More on this in a bit.

To label the lists in Gmail I use a filter like this: 

    list:(a.example.com) OR list:(b.example.com) OR list:(c.example.org)

Notice that the value being tested for is the List-ID, not the from address.  Find it by looking at the message headers.  I label these by category, i.e, `interesting-lists` or `tier2-lists`.

## Email about a particular project or technology

One last example.  I have a few filters that just look for keywords.  For me, one of them is around keywords related to documentation.  I've been doing a lot of work on the tooling for [Fedora Docs](https://docs.fedoraproject.org) so these technologies and projects are worth flagging to me.

To do this, I am labeling each category of technology/projects using a filter like this:

    list:(docs-related-list@example.com) OR asciidoc OR asciibinder OR antora

This grabs all the things related to docs and labels them with the `docs` label.

# Step 3: Show Me the Email!

At this point you need to divide your email so you can later conquer it.  As I mentioned at the start, I use 4 inboxes.  You should use as many as you need, but I believe the fewer the better.  My inboxes are:

* INBOX: This is for email that is highly likely to be important and need my attention.
* Tier-2: This is for email that is potentially interesting and may want to be read.
* Tier-3: This is for email that is unlikely to want to be read, but can't be eliminated by the bots.
* Tier-git: This is for email from various systems that may require action or monitoring.

These levels aren't as arbitrary as they may appear.  Each one is designed to contain email that requires a specific way of thinking.  I'll explain more when I talk about reading email.  For now, let's divide it up.

## Pull out the Tier-git Emails

With my four inboxes, I discovered that I really wanted to make sure that my git emails only were delivered to my git inbox.  Therefore, I first pull those out, then I divide up the rest.

To get the git emails, I filter for their labels and label those emails `tier-git`:

    label:from-git OR label:from-automated

The remaining inboxes are labeled in a similar manner, but it is a bit more complicated as you'll see.

## Identify your INBOX emails

Very much like the filter for `tier-git`, this rule labels emails `to-inbox` based on their other labels:

    (label:me OR label:from-people OR label:fedora OR label:1-Monday OR label:2-Tuesday OR label:3-Wednesday OR label:4-Thursday OR label:5-Friday) AND NOT (label:ignore OR label:tier-git)

Notice how I a filter condition which excludes emails that are already in `tier-git`.  This is important to prevent things from landing in more than one inbox[^4].

A couple of notes:

* `to-inbox` is not an actual reading label.  I am just using this label to make sure that I have these emails blocked from other inboxes.  See below.
* The day of week labels above are part of how I handle Waiting For and Delayed tasks.  I can share more about that at a later time if you're interested.
* The ignore label is manually applied to email the bots think is important but really isn't.  This is an easy way for me to silence emails[^3].  These typically, for me, are threads about topics that aren't important to me, but that happened to have an important keyword used (for example in someone signature or as an example) or where someone who is important to me replied.

[^3]: Theoretically I could just mute the threads in Gmail, but I am not sure what the consequences of that action are.
[^4]: I do get some threads in more than one inbox.  This is caused by the way Gmail treats labels on threads.  See the Gmail specific notes for more details.  Right now the level of duplication has been so small it isn't worth trying to code around.

## Identify Likely Interesting Emails (Tier-2)

Continuing the theme established above, this inbox.  This filter also has some extras.  First, the filter:

    (label:tier2-lists OR label:osas OR label:announce-rh OR label:docs OR label:devconf) AND NOT (label:ignore OR label:to-inbox OR label:auto-archive OR label:auto-archive2)

As you can see the list of labels to ignore got a bit bigger.  First, continue to ignore things I want `ignore`d.  I also don't want to put things already in the `INBOX` into this inbox.  Lastly, I am explicitly ignoring my auto-archived (or trashed) emails.  I am doing this because I noticed that some of them also meet some other criteria, despite also clearly being trash.

## Everything Else (Tier-3)

Everything that is left is the email that is unlikely to be interesting, but should at least get a cursory review.  To catch these I use this filter:

    NOT (label:to-inbox OR label:tier2 OR label:tier-git OR label:auto-archive OR label:auto-archive2)

Basically, if I didn't put it in another inbox or throw it away, put it in `tier-3`.  

# How to read

Now that you've got your email sorting, it is time to learn how to read it.  I encourage you to strongly consider taking an approach to reading email that tries to focus your day.  For some days this may mean reading only the important email.  On other days this may mean really reviewing everything.

For me, reading consists of 5 steps.  They are modified as you'll see below, based on other conditions and activities.  I try to do a full read in the morning and an abbreviated read in the afternoon.  I try to read email only twice a day.

## 1. Skim the INBOX

This is really just a skim.  Read through the new email and make sure nothing is "on fire" or worthy of aborting everything to deal with right now.  This is also a chance to send a quick reply on time sensitive issues, for example, too coworkers who are about to end their day.

On super busy days, this is all of the email reading I will do before I launch into my most important tasks.  Because I trust my system to be good at flagging important emails, I feel confident in my ability to stop reading here.  However, assuming it is a normal day (or I have time), I move on to the next step after a quick skim.

## 2. Read the Tier-3 Inbox

Tier-3 email is highly unlikely to be important.  Out of 50 emails, I might actually feel like 2 are worthy of attention.  I do this quickly by hitting the `Select All` button.  I then skim the subject lines and uncheck any that look interesting.  Once I get to the bottom, I remove the `tier-3` label.  This leaves me the few emails that could possibly be interesting.

At this point I either read them right now, if I have time, or they look only mildly interesting, or I move them to the `INBOX` for later reading/processing, or I leave them where they are to be gotten to later.  I usually choose the third option at the end of the day if I am just doing a quick prune before leaving.

This is a relatively easy task to perform because all of these emails are unlikely to be interesting.  There is very little thought involved.

## 3. Read the Tier-2 Inbox

Tier-2 ramps the thought required up.  With Tier-2, perhaps 4-10 emails out of 50 will be worthwhile.  However, these are more likely to have subject lines that will catch my eye and may require me to stop and consider if there is a next-action or need for concern.

When I read Tier-2 I quickly skim to get a gut feel for which kind of email is more prevalent that day, likely to be read or likely not to be read.  If it looks like more chaff than wheat, I use the select all option like in Tier-3.  If it is more wheat than chaff, I manually mark the chaff and remove it.

After that I take on of the same three actions as as in Tier-3: read now, move to `INBOX`, or leave for another day.

## 4. Read the Tier-git Inbox

This is a place where I wish Gmail supported sorting threads in a label.  Unfortunately they don't.  If I have a lot of messages here, I sometimes do some targeted searches to, for example, gather all messages from a certain repository together for consideration at once.  In general though, I typically work email by email.  If the notice is interesting, I open the corresponding ticket in my web browser and immediately go to the next email.  Either way, I remove the label.  If I know the ticket is going to require lots of work/thought, I'll often just move the email to the `INBOX` instead of opening the ticket.

## 5. Process the INBOX

We're back to the `INBOX`.  Now go through your important mail and [do work](https://bigblack ...).  How I do this is outside of the scope of this post, but I can describe it later if there is interest.  Don't forget about any tickets you opened in the last step.

# But What If You Miss Stuff

This has so far not been a problem for me.  My rules are catching what matters.  I do tweak my rules periodically as my needs change.  I also work to fix misfiles that are recurring as soon as I notice them.  Ultimately it comes down to the fact that I believe all of the following:

* Trust by verify

    For the few first weeks of trashing emails like in Step 1, I actually reviewed the labels that were trashed periodically to make sure nothing fell through the cracks.

* I rely on other people

    I don't exist in a vacuum and I don't work alone.  Others will point out to me if they see an email they think I should have replied too.

    I realize this doesn't help if your reply wasn't needed, but you should have "known" what was sent.  For this I rely on my filters and have so far not had a problem.  If I found one, I'd fix my filters and move forward.  My current role doesn't have a "miss an email and lose your job/destroy the company" issue.  I hope yours doesn't either.

* It's all archived

    The email isn't gone.  Because I use Gmail I have access to decent search and can find anything if it gets lost.

# A Few Notes about Gmail

## Labels

### Set the Label Options

In the settings page you can change how labels behave.  Two settings are important, in my opinion:

* Show in Unread or Hide

    Every label should either be hidden from the label list in the sidebar or marked `Show if Unread`.  Your inboxes (and any other actual labels) should appear if you need them.  Your classifying labels should all be hidden.  They aren't inboxes, don't read them!

* Don't Show in Message List

    Only allow labels that provide useful actionable data to appear in your message list.  This means hide all your classifying labels and pretty much just show your actual inboxes and other used labels.

    The reason an email landed in an inbox isn't useful when figuring out what to do.  On the other hand, knowing it is already in a project label (not discussed in this article) may allow you to skip the thread when reading because you know already that the email is ready for you in the project label.

### Labels are Additive

* Threads have labels and so do emails

    When Gmail labels an email, every email in that thread is considered to have it if you view your email in conversation view.  This is only important when you are writing classifying rules and want to use the `has:userlabels` or `has:nouserlabels` conditions.

* You can't remove a label with a filter

    This is why we have to do so much of the `AND NOT` condition writing when sorting mail into our inboxes.  This is also why one email conversation can wind up in several inboxes.  For example consider this timeline:

    1. You fall asleep
    2. You receive email about a not interesting topic.  It gets labeled to `tier-3`
    3. Some important person responds to that email,  It gets labeled to `INBOX`.
    4. You wake up and read email and see the same thread twice.

    This happens.  So far the incidence of this has been low enough for me that fixing it will take more time than I'd save.  If this is a big deal for you, there appear to be two solutions:

    1. Run a script on your inbox from Google Scripts that removes lower priority labels from emails with higher priority labels.
    2. Use an extension or saved linked to run saved searches and use those instead of the `tier-2`, `tier-3`, etc. labels.

## Filters

### Filter Order Matters

This doesn't seem to be documented anywhere, but filter order matters.  Gmail filters are processed from top to bottom.  What you'll find is that the sorting we did in Step 3 requires those filters to be at the bottom of the list.

What you'll also find is that editing a label in the web interfaces moves that filter to the bottom of the list.  I get around this by using the export function on the filters page.  This gives me an (not quite horrible) XML file to edit.  To update my filters, I just delete all existing filters and import new ones.  If you do it in a staged way as listed below, you don't get misfiles:

1. Go to the import filters section of the settings.
2. Click Select File and select your XML
3. Click Open File and watch your new filters load on the screen
4. Select all existing filters
5. Delete all filters.  Watch the countdown.  Hum "The Final Countdown"
6. Click Import Filters and load your new filters

### You Can't Stop Processing

There does not appear to be a way to not have every filter run against every email.  This is why we use some the `has:nouserlabels` conditions and why our sorting of the email into inboxes is so complex.

# Further Thoughts on Email Productivity

If there is interest, I am can to write a post about how I process my INBOX and handle waiting for and deferred tasks.  Below are a few quick ideas that may also be useful.

* Hide the sidebar

    I don't quite trust myself to know I'll read my inboxes if I hide their labels (even with Show if Unread).  Unfortunately, I am also a person who gets easily distracted by unread notifications.  If I am not careful, every time a new email lands in `tier-3` I'll go read it.

    To fix this, I am trying out a browser extension that automatically hides the sidebar.  It comes back if mouse to the edge of the screen.  This plus keyboard shortcuts has helped me keep greater focus.

* Use bookmarks

    I haven't done this yet, but it sounds great.  First, turn off all labels from the label list.  Second, if needed install the extension to hide the sidebar (mostly for screen real estate).  Third, set up bookmarks for each inbox that go straight to the inbox.  This way you have the visual reminder to check your inboxes, but you don't get a notification that it should be done **RIGHT NOW**.

    As a bonus, use this [cool trick](https://...) to have a short cut that just composes new email.

# Bonus Song

I know I said I shouldn't, but I did.  Enjoy, if that is possible!

On the first day of email fixing, bex gave me this advice: Always be in a happy place

On the second day of email fixing, bex gave me this advice: Throw out the trash and always be in a happy place

On the third day of email fixing, bex gave me this advice: Classify your email, throw out the trash and always be in a happy place

On the fourth day of email fixing, bex gave me this advice: Use four inboxes, classify your email, throw out the trash and always be in a happy place

On the fifth day of email fixing, bex gave me this advice: There are 5 tiers. Use four inboxes, classify your email, throw out the trash and always be in a happy place

On the sixth day of email fixing, bex gave me this advice: Read email twice a day. There are 5 tiers. Use four inboxes, classify your email, throw out the trash and always be in a happy place

On the seventh day of email fixing, bex gave me this advice: Gmail filters have caveats, read email twice a day. There are 5 tiers. Use four inboxes, classify your email, throw out the trash and always be in a happy place

On the eighth day of email fixing, bex gave me this advice: Hide all the labels, Gmail filters have caveats, read email twice a day. There are 5 tiers. Use four inboxes, classify your email, throw out the trash and always be in a happy place
