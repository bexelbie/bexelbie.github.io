---
layout:   post
title:   "Flock to Fedora: Krakow, PL Edition"
subtitle:  "Community Means Hanging with Your Friends"
date:    2016-08-11 18:23:00 +0200
author:   "Brian Exelbierd"
header-img: "img/2016/flock.png"
tags: "fedora"
published: true
---

[Flock](https://flocktofedora.org/), the Fedora Contributors conference
held annually in August has happened again.  This year the conference was
in Krakow, Poland.  I was one of the organizers and my employer, Red Hat,
paid for my trip.  I continue to be thankful to Red Hat for their
support of the Fedora community and, in this case, me.  Completely without
bias (hah!) I must also point out that this is the single best organized
conference I have ever attended in my life.  So strap in, this is a
long roundup!

My organizing duties kept me busy, as did the evening activities so I
didn't get to to as many talks as I wanted too.  As you might expect, the
hallway track was fantastic and made up for some of the talks I missed.
In particular, I got to have some key discussions around usability,
Fedora's structure, and translations amongst other things.

Knowing the talks would be recorded and that several of my colleagues
were in attendance, I tried to attend sessions they may not have
chosen to attend.  My goal was both to see something different and
to hopefully generate some serendipity to help me in both Fedora and
at work.  Look for the recordings of most talks to appear on the [Fedora
YouTube Channel](https://www.youtube.com/channel/UCnIfca4LPFVn8-FjpPVc1ow)
soon.

Tuesday started with the *State of Fedora* Keynote.  [Matt
Miller](https://twitter.com/mattdm), the Fedora Project Lead, delivered
a talk updating information he had presented in February at DevConf.cz.
His talk focused on not just sharing the state of the project,
but ensuring we all knew the general direction it was heading in.
One interesting statistic from the talk is that almost two-thirds of
contributors to the Fedora project are not Red Hat employees.  It merits
constant repeating: Fedora is a community directed and produced effort.

The core of Fedora contributors is roughly 2 non-Red Hatters for every Red Hatter.
{:.quote}

I followed this up with two talks, *A year managing the Italian
Fedora Community* and *I contributed! but, what now?*.  Both [Fabio
Locati](https://twitter.com/f4l3) and [Bee
Padalkar](https://twitter.com/BeePadalkar) talked about
communities and patterns of interaction.  In my $dayjob part of
our goal is to grow the community of users and contributors
for [Project Atomic](http://www.projectatomic.io/)
and more specifically the [Atomic Developer
Bundle](https://github.com/projectatomic/adb-atomic-developer-bundle).

Fabio focused on the challenges the Italian Fedora community has faced
with low participation and a lot of aging infrastructure and outdated
information.  He outlined how they have taken steps to fix both of these,
including reducing the amount of information maintained in Italian
because the corresponding English resource is reasonably able to be
considered usable.  In the case of Atomic, I believe this means we
have to keep driving our on-boarding to the bite sized chunks that entice
new users and contributors while making sure the backup and detail
docs are only a click away.

Bee presented a lot of data on the activity of users, including some
data on how there is a magical 3-month activity cliff after which many
users have "scratched their itch" and go inactive.  Thinking about my
work on the ADB, I believe this means we should consider making sure
there is a significant release every 60-90 days to keep users "itchy"
and desiring to stick around and contribute.

*How to use personal kanban for better organization* by [Haikel
Guemar](https://twitter.com/hguemar) tried to help us all bring order
to our own personal chaos.  The talk was focused mostly on keeping your
tasks on an "information radiator" which allows you to quickly see what
is going on.  He touched on tools ranging from low-tech solutions like
Paper to self-hosted solutions like [Kanboard](https://kanboard.net/)
and cloud-based solutions like [Trello](https://trello.com/).  I suggest
you watch his talk if the mechanics of Kanban are still new to you.
The idea to use it to manage your own life is a good one, as long as
you can deal with any other task systems you have to interface with like
Bugzilla or project kanban boards.

My involvement with the [Fedora Docs
Project](https://fedoraproject.org/wiki/Docs_Project?rd=DocsProject)
led me to attend [Alex Eng's](https://twitter.com/loones) session,
*Zanata - translation platform.* Alex presented a round up of the
new features available in the next release of this translation tool
and how it can help community and corporate users make the language
of their output more accessible.  I had hoped to learn more about how
Zanata connects to sources in the session, but instead wound up having
a brief conversation with him afterward.  Translation is challenging on
many levels, but there is no excuse for not building your workflow to
accommodate it from the beginning.

The *Fedora Council Update & Town Hall* was short and sweet and long and
interesting at the same time.  Original envisioned as a Q&A, it didn't
have a lot of 'Q' so there wasn't a need for a lot of 'A.'  However, the
council, all being in one room, took advantage of the time to have some
informal planning discussions around, amongst other things, future Flocks.
Having been involved in planning this one and being enough of a masochist
to want to keep helping doing it, this was a great discussion to attend.

*How to start a Fedora movement in a new country* by [Redon
Skikuli](https://twitter.com/rskikuli) continued my theme of looking
at community building.  Redon has worked to start a technology space in
Albania to introduce open source.  The group is affiliated with several
different technology communities.  Fedora's exposure seems to be being
increased by these associations, a strategy that is also going to be
key for the ADB.

On Wednesday I partnered with [Dusty Mabe](https://twitter.com/dustymabe)
to present [*Bringing Developers into the
Flock.*](http://www.winglemeyer.org/bexelbie-talks-demos/Flock.2016.developers/#/)
The talk had two parts.  In part 1 we introduced and demo'ed the ADB.
In part 2 we discussed how the ADB fits the Fedora Foundations and
provides opportunity for growth.

The audience was small as we were in competition with
[Langdon White's](https://twitter.com/1angdon)
Modularity talk, but they seemed to really understand the
topic.  As a measure of success, we received a documentation
[PR](https://github.com/projectatomic/adb-atomic-developer-bundle/pull/491)
1 day after the talk from someone who was in the room.  The audience
seemed to understand how this project could help developers, especially
those not on Linux platforms.

There are two big challenges with talking about the ADB.  The first,
and the biggest, is the name.  The abbreviation ADB is overloaded and
most commonly collides with the Android Debug Bridge.  While the target
markets are very different, the Android debugger is widely known.
This causes many audience members to "short-circuit" over the name.
When this happens the conversation stops being about the ADB and
becomes one about how "naming is hard."  To this end, I worked with
[Daniel Veillard](https://twitter.com/danielveillard)
to propose a new name, [Project Atomic Developer Bundle
(PADB)](https://github.com/projectatomic/adb-atomic-developer-bundle/issues/495).
(See what I did there?)  There has been nothing but quiet approvals so
I expect to submit a PR to change the name sometime next week.[^0]

The other big challenge when presenting the ADB is that it is designed
to get out of the way.  Once you have it running and integrated into
your environment you can develop with it using your traditional tools
and not have to use it directly too often.  This means demos often feel
like they have been abbreviated or are missing something as they stop
at the end of the integration.  One way to fix this may be to have a
more end-to-end demo that includes developing with the ADB while not
focusing too much on any particular deployment target.

The four Fedora foundations are strongly supported by building the ADB.

- **Freedom** is easy as the upstream project is free open source
  software.

- **Friends** has the biggest story related to the ADB.  A big push for
  Fedora is to attract more developer users.  However, our conversation
  today starts with "install our desktop" which is a non-starter for
  lots of developers for various reasons.  With the ADB we can start
  the conversation with "use this fantastic developer environment"
  and get people on Fedora with less friction.

- **Features** are a key part of Fedora and the ADB is an opportunity
  for Fedora to not only leverage its existing commitment new features
  and software but also adds the opportunity to share best practices.

- **First** is achieved by allowing the Fedora platform to help move
  the ADB forward.  For example, the current ADB virtual machine image
  is bigger than we want it to be and may be able to easily be slimmed
  down by leveraging the work Fedora has already done to reduce the size
  of Fedora Atomic Host and the Fedora docker image.

Dusty and I also set up talks later in the day.  Specifically,
Dusty's talk, *Don't Destroy Your Machine with Development,*
which provided a lot of information about Vagrant and the Fedora
Vagrant virtual machines and [Ratnadeep
Debnath's](https://twitter.com/rtnpro) talk about
[Nulecule](http://www.projectatomic.io/docs/nulecule/) in a session
called *Nulecule - Packaging multi container applications.*

Bright and early at the crack of 9am on Thursday
I had the pleasure of doing emcee work at the
Lightning talks.  These talks featured no slides, no
demos, just 5 minutes for people to deliver their idea.  We had [10 great
talks](https://fedoraproject.org/wiki/Flock/Lightning_Talks_2016#Lightning_Talks_2016_-_4_August_2016_.40_09:00_Local_Time_in_Krakow.2C_Poland)
on topics ranging from Marketing to Haskell to OpenShift on AWS.  It is a
shame these weren't recorded as they were really really good.  Therefore I
encourage you to plan to attend Flock next year and participate in the
Lightning Talks!

Later in the day I moderated a session called *Hackfest: Fedora Docs
Learn and Hack.*  A blog post about the session will soon appear on
the [Fedora Community Blog](https://communityblog.fedoraproject.org/).
This was originally going to be a 20 min presentation on the outcomes
from a Fedora Activity Day for Docs which was held in May and a hackfest.
However it turned into a fantastic discussion and brainstorming session.
The blog post has more details.

The final session I got to attend was the *Fedora Budget Workshop* led by
[Joe Brockmeier](https://twitter.com/jzb).  A lot of the session was
spent hashing and rehashing the challenges which sometimes accompany
reimbursement requests.  However parts of the session helped us move
forward with thinking about how money is allocated and how we can
think about making sure we using our resources to accomplish our goals.
If you haven't already looked at the Logic Model prepared by Matt, do so
[now](https://pagure.io/FedoraLogicModelTemplate).

The evening activities of a conference can really allow people to relax
and make friends.  This is super critical at a conference like Flock where
we want people to meet and remember each other through a year's worth of
IRC meetings.  We also need a strong hallway track to make sure that the
various parts of the project stay connected and on roughly the same path.
We had fantastic evenings going on a tour of Krakow, playing games (board
and computer), a dinner cruise on the Vistula, and an evening in Browar
(Brewery) Lubicz.

Photo Credit: [Mary Shakshober](https://marygraphicdesigns.wordpress.com/)
and the [Fedora Design Team](https://fedoraproject.org/wiki/Design)

[^0]: There is a people reason to wait.  A core contributor is away unexpectedly.
