---
layout:   post
title:   "Docs Project update from Flock 2016"
subtitle:  "posted on the Fedora Community Blog"
date:    2016-08-15 08:15:00 +0000
author:   "Brian Exelbierd"
header-img: "img/2016/docs-update-flock-2016.jpg"
published: true
category: Technology
tags:
 - Fedora
 - Documentation
 - Conferences
redirect-from:
 - /2016/08/15/flock-docs-update/
---

At [Flock 2016 in Krakow, Poland](https://flocktofedora.org), I had the
privilege of updating the community on the status of the [Fedora Docs
Project](https://fedoraproject.org/wiki/Docs_Project?rd=DocsProject).

I made a small presentation and moderated a discussion in the [Hackfest:
Fedora Docs Learn and
Hack](https://flock2016.sched.org/event/76oX/hackfest-fedora-docs-learn-and-hack)
panel. Unfortunately, my co-presenter and Fedora Docs Project Lead,
[Pete Travis](https://fedoraproject.org/wiki/User:Immanetize), could not
attend this year. Therefore a lot of the conversation reflected my
opinions and what I have gleaned from others.

Read more over at the [Fedora Community
Blog](https://communityblog.fedoraproject.org/docs-project-update-flock-2016/)
where this was originally posted.

*Image courtesy [João Silas](https://unsplash.com/@joaosilas) –
originally posted to [Unsplash](https://unsplash.com/) as
[Untitled](https://unsplash.com/@joaosilas?photo=UGQoo2nznz8), modified
by [Justin W. Flory](https://fedoraproject.org/wiki/User:Jflory7).\
*

<!--
The presentation
[slides](http://www.winglemeyer.org/bexelbie-talks-demos/Flock.2016.docs/#/)
are online. Unfortunately, the session wasn’t recorded or transcribed,
so I wanted to try and present the conversation here. I am not
attributing any comments in order to avoid mistakes. Additionally, I am
working from my memory and the memory of other attendees, so omissions
are accidental.

## Two focuses for the Docs Project

There was a
[FAD](https://communityblog.fedoraproject.org/event-report-fedora-docs-fad/)
in May 2016 to formulate ideas for moving the project forward. Two big
ideas came out of this meeting:

First, a desire to move to a topic-based style of writing. This changes
our writing to thinking about “every page is page one”. This style is
shorter and refers to pre-requisite steps and knowledge as needed. This
makes it easier to submit new material as writers don’t have to figure
out how to fit their contribution into the narrative flow of a large
book. Lastly, it is easier to consume this more directed and
self-contained writing and it will score better in search.

Second, tools were debated. [DocBook](http://www.docbook.org/) and
[publican](https://fedorahosted.org/publican/) seem to have led to
problems with contributions, lots of friction in the project, and longer
on-boarding. Additionally, there are the problems associated with a
relatively unmaintained upstream. Prior to the FAD,
[nb](https://fedoraproject.org/wiki/User:Nb) had moved our repositories
from FedoraHosted to [Pagure](https://pagure.io/) as part of the effort
to join the new git forge. At the FAD, a lot of tools were analyzed and
considered. In the end, the discussion led to the idea of using the work
flow provided by [Pagure](https://pagure.io/) and building the site with
[Pintail](https://github.com/projectmallard/pintail).

The real value came with the questions and comments raised as part of
the discussion. In no particular order, these major points were raised.

## Outcomes from discussion at Flock

#### How do we move to topic-based writing? Is there a plan?

After the FAD, there was not a finalized plan, but planning began during
this session. Many ideas were mentioned and consensus seemed to form
around just writing new topic material. Folks from the GNOME project
pointed out several reasons, including efficiency, for why they rewrote
their materials when shifting from books to topics. Another benefit of
starting from scratch is that new material can be written in a priority
order, possibly based on [search
keywords](http://paste.fedoraproject.org/392172/84893614/).

One challenge is right now is that we have no place to put and publish
these new topics. It was quickly pointed out that this is the “tools
problem” and it has many solutions. Instead of letting tools be a
blocker, it was proposed to have people just write. “Write it in any
format, any markup, any program, even on paper and just send it to us.
We will get it published.” This turned into a discussion of how many
topics are also good for the [Fedora
Magazine](https://fedoramagazine.org/). So the suggestion was made for
folks to consider submitting material there first and we can pull it
back into docs later. Additionally, folks can email the docs mailing
list or me. **I am super excited to tell you I got an email with a topic
35 minutes after the session ended**

Continue the conversation in this
[thread](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/message/NRJXIMANF7VACI2G7RPRQLXPILOGEKWE/).

#### Should we stop publishing the current guides now?

The requirement to keep publishing the current guides feels very
self-imposed. Continuing to publish them is a challenge for the new
tooling as it has to be built to accommodate the past and therefore
slows down the future.

Additionally, publishing the current books spreads our resources very
thinly, if not past the breaking point. It also creates inertia which
prevents the move to topics. Confusion can result from this as well
because contributors don’t know what to update (old books or new
topics).

Lastly, there is a growing belief in the larger documentation community
that no docs is better than old docs. Here this is a direct reference to
the fact that we don’t republish all the docs for every release and we
don’t thoroughly review every doc that is published. Versioned docs are
important, but some old materials are probably going to cause problems
(i.e. references to `yum` or `iptables`.)

One proposal was to have a “flag day” where we stop updating the current
docs and another day (or same day) where we stop the publication. this
would definitely need to be moderated for versions not yet end-of-life.

Continue the conversation in this
[thread](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/thread/7TNTUJ5RZMCWNN7SQ3P76T2AC6UNOJG2/)**.**

#### Translation needs clarity on how to get updates published and the process.

This seemed like a communication problem between the two projects that
needed to be resolved with better docs on the process and hand-off
procedures. Because the tooling proposal will hopefully include
continuous deployment, this may become a lot easier in the future.

Continue the conversation in this
[thread](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/thread/575VDARFIL6DJ4LQFD3NPYNY5RHLO36S/)**.**

#### Tooling, tooling, tooling

There was strong consensus around changing to new tools and markups. In
fact, most of the tooling conversations were held in small groups near
the end of the meeting. There was a desire to continue to see a drive to
simpler contribution and publication.

The only significant question was around the community, upstream
adoption, and contributor base for
[Pintail](https://github.com/projectmallard/pintail), which is the
central tool in the new processing flow. People were concerned that
there wasn’t evidence of enough adoption and contribution to prevent the
project from being at risk of going either unmaintained or slowly
maintained.

Continue the conversation in this
[thread](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/thread/B5ZKLR65DELT4MTLOY7ZZ6NMTL44SXB4/)**.**

## Add your voice

You are strongly encouraged to continue these conversations on the
[Fedora Docs Mailing
List](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/),
in IRC in
[\#fedora-docs](https://webchat.freenode.net/?channels=fedora-docs) on
freenode, and in our weekly IRC Meeting on Mondays at 1400 GMT in
\#fedora-meeting on freenode.

<hr/>

*Image courtesy [João Silas](https://unsplash.com/@joaosilas) –
originally posted to [Unsplash](https://unsplash.com/) as
[Untitled](https://unsplash.com/@joaosilas?photo=UGQoo2nznz8), modified
by [Justin W. Flory](https://fedoraproject.org/wiki/User:Jflory7).\
*
-->
