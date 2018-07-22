---
title:   "GrimoireCon"
excerpt:  "Event Report"
date:    2017-07-13 16:30:00 -0500
categories:
  - Technology
tags:
  - Conferences
  - Fedora
classes: wide
header:
  overlay_color: "#333"
---

# GrimoireCon

## Austin, TX USA

## 7 May 2017

GrimoireCon is a 1 day programmed set of talks by [Bitergia](https://bitergia.com/) about their open source project, [GrimoireLabs](http://grimoirelab.github.io/).  This project provides a customized ELK stack to do metrics analysis.  The work in Grimoire Labs represents all of the lessons Bitergia has learned from trying to do analysis on data streams, similar to Fedmsg.  They have built plugins for many different kinds of data sources, such as code repository activities and mailing lists.  These statistics allow you to examine what is going on in a project and where the activity is, or isn't.

Samsung's Open Source Office presented on their use of Grimoire Labs to do second order analysis of the impact of Samsung engineering contributors to open source.  The presentation was recorded and I am still waiting on Bitergia to post it.  It was a fantastic talk and showed off a lot of the kinds of statistics we need in Fedora.  These included calculations of time between contributions by a contributor and the paths that tended to lead to continued contribution.  It also pointed out problems where slow review and patch merge processes in some Samsung projects was leading to loss of contributors.  I am following up to see if the video is available.

I believe it would be interesting to look at setting up an instance of Grimoire Labs and feeding it with data from pagure, hyperkitty, and fedmesg.  I belive this will allow us to see better information about our community.  I know that some work has been done in the past using other solutions, however this one seems to have both active development and a user community.  I believe we get more value out of joining and contributing to an active community than trying to build it ourselves.  If you're interested in helping with the coding (python) or the analysis and set up, let me know.
