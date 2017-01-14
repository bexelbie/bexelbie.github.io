---
layout:   post
title:   "Postulating the Backlog Laxative"
subtitle:  "Write The Docs Europe - 2016 Prague"
date:    2016-09-20 14:00:00 +0200
author:   "Brian Exelbierd"
header-img: "img/2016/WTD/header.jpg"
published: true
tags: no-navigation
---


Reading through bkp's requirements (Gina, I didn't have a chance to
read yours yet), It seems like the requirements break down into:

Writing - familiar, easy, submission is simple
Editing - ability to go back/forth with author, easy, commenting, simple
Posting - reliable, controllable, schedulable
Hosting - simple, safe, low admin overhead, easilly integrate with
static and other content
Bonus points - editorial calendar, status overview, reminders

It also sounds like our current push to static sites has pushed the
balance in the direction of Hosting and away from editing (and
writing?).  What about a monkey-hybrid horror :)

Writing and Editing Platform: Google Docs - While not open source,
this platform is familiar and simple.  It allows writers and editors
to have robust back/forth conversations and features notifications on
modifications.  Submission of stories is accomplished by sharing a
google doc to the editor alias which would automatically add all
editors. (see below for expansions)

Hosting: Static site generation via jekyll/middleman/etc. using a
lightweight markup such as  Asciidoc or Markdown.  This is easy to
manage and host with simple build and rebuild possibilities.  It has a
low security footprint.

Posting: Accomplished via our own Max Andersen's gdoc2adoc (or the
related projects) [http://xam.dk/blog/gdoc2adoc/]  This would need
some slight modification.  Posting could easily be done by anyone with
commit access, cleanly providing access controls.  Most of the static
site engines provide a way to put a posting date in place and block
future posts until the right time (with regeneration).

Bonus Points: Trello - long used by the AOS team, and several other
teams at Red Hat, Trello's Kanban boards make it easy to see where
things are in a process.  If there is an editorial calendar, this can
be maintained on a public board along with a list of story ideas
needing pitches.  The actual editorial and publishing planning, can
occur on a closed board (with or without public read).  AOS has an
advanced trello bot that can be leveraged for a lot of this.

The trello bot could be extended to do the following:
1. Receive Google Doc share notifications from new submissions (it is
the editor alias in Gdocs) and create a card in the "needs an editor"
column in trello.  When an editor takes the card, the bot can add that
person with edit permissions to the doc.  This would even support the
assignment of editors to stories (they would get a doc share
notification when the bot added them).
2. Monitor cards for timelines and provide email reminders
3. Move cards through the process automatically when states change (if
detectable - which I think they are)
4. Close out article docs that have completed the editorial process.

To be even more fancy, a front end could be written that writers visit
to initiate submissions.  This front end could ask if they are
responding to a specific card on the editorial calendar to link those
cards to their submissions (and optionally move those cards from the
"need a pitch" to the "have a pitch" column).  This front-end would
then create and share a doc to the user, making gdoc management even
easier.

While there is code to be leveraged, there is still going to be new
infrastructure code needed.  Some of the bonus point stuff is "hard"
in as much as it is a problem I haven't seen directly solved.  Most of
the rest is between 50% and 90% solved by existing tools that just
need to be wired together.

While this idea has a lot of moving parts, none of them are really
connected, so a failure in one part shouldn't crash out the whole
system.  This seems to meet every actor's individual needs while still
providing the end result.  This also leverages our existing
investments in things like Project Snowflake where we are doing work
with static site theming, calendars, search, etc.  Each part is
replaceable without disturbing the other bits too badly.  In the
unlikely event any of the non-RH hosted bits shuts down castrophically
and unexpectedly we lose in progress posts and the editorial overview,
not the site or history.  Additionally, we can replace Trello with
it's open source clone (which is not perfect and in my opinion is a
bad example of FOSS - but that is a "beer" conversation) and we can
revert to alternative methods for replacing google docs.  I am less
concerned about Google Docs because RH has a corporate depedency there
so we should have access to a replacement plan if one becomes
necessary.
