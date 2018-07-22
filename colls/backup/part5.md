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

5. How do I do implement all of this?

should I implement at all

local drive corruption and versioning

evaluate actors per FSFE or whatever
Trust No One

4. How do I do implement all of this?
If you're writing your own backup script I feel bad for you son,
I've got 99 problems,
but not being able to restored because I messed up the options to `rsync` isn't one.

4a. What about versioning hot data

5. Bonus: What about my phone or my cloud data?


Backups

Cold storage
Working data
Configs
Keys and passwords

Privacy

VPN + TOR
Encryption
Passwords not fingerprints
Social media

monthly email out `dnf history info #..# | grep ^Command` to capture new/removed packages to update ansible
backup periodic to amazons3
  - need to separate my system configs from my personal data
  - avoid work data
monthly do a full backup
archive data in glacier
