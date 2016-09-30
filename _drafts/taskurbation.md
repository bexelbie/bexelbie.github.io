---
layout:     post
title:      "Taskurbation"
subtitle:   "Urgency and the Art of Algorithmic Choice"
date:       2020-01-01 08:00:00
author:     "Brian Exelbierd"
header-img: ""
published:  false
---

Recently I decided to switch to [taskwarrior](https://taskwarrior.org/)
to manage my to do list.  I have been using
[OmniFocus](https://www.omnigroup.com/omnifocus/) for several years,
but it doesn't support all of the desktop operating systems I now
regularly use[0].  It also doesn't have a web app for those systems
not directly supported.

This switch is also giving me a push to do a bit of "taskurbation"
and figure out a new way to handle my to do list.  I've resisted
the standard productivity porn moves of trying out a new system
every few months.  However, I've never been great at getting it all
into the system (or done, but that is a different story).  My
challenges seem to be:

* Getting things into the system is a bit cumbersome.  Therefore I
  don't fully trust it.  I tend to have at least one running paper
  list and a few emails of tasks floating around.  This isn't
  directly the fault of OmniFocus.  There are clients and entry
  points galore (well except on that one machine ...).

* Because of the unsupported machine, I am not regularly using my
  to do list for part of the day.  This causes time sensitive issues
  to get left behind on some days.

* My to do list is overwhelming.  I have lots of projects (in the
  GTD sense) and several "buckets" for random tasks related to parts
  of my life.  A quick scan of available actions is not quick or a
  scan.  This leads to me cherry-picking tasks which leads to "ugly
  bits" staying unfinished.

All of this leads me to not have faith in the system which defeats
the purpose of the system.  It also leads to me trying to make the
system more complex to account for everything making task entry
harder, etc.  Rather. Rinse. Repeat.

Enter taskwarrior.  Taskwarrior has a different approach:

1. The core client is a CLI which can be compiled for all of my
   desktop operating systems.

2. There is an open source sync server and webclient (good for
   phones too), however this requires me to set up a server and
   probably means that I no longer have access to tasks on my phone
   without internet connectivity.

3. Taskwarrior shows either a full list of all available actions,
   or just the first "page"[1] of them.  But, it orders the tasks
   by an Urgency value it calculates for you.  You can tweak this
   extensively (potential rabbit hole) to get it to align with your
   values.

4. It is task oriented, not project oriented.  While tasks can be
   grouped into projects, projects don't seem to have any inherent
   properties.  They can't be set to prompt you when they complete
   so that you add more to the project during a review.  They can't
   be set to auto-manage dependencies (for example all tasks in
   this project are sequential and block successive tasks).  These
   things all have to tooled around (another potential rabbit hole).

5. There is a vibrant community of add-ons, frontends and cool tools
   like [bugwarrior](https://github.com/ralphbean/bugwarrior) to
   extend the system.

These things are mostly positive or not overwhelmingly negative.
Things like the sync server are just finally giving me a good excuse
to setup another server.

The big eureka/fear for me is the Urgency ordering.

[0] In the last two years I have begun regularly using a laptop
with [Fedora](https://getfedora.org/).  As my responsibilities have
increased a simple text file to do list has no longer been practical.
I also regularly use a [MacBook Pro running OS X](https://www.apple.com/).

[1] It can actually limit on any arbitrary number of tasks to
display.  However, the number isn't the issue, it is the logic
behind choosing it.
