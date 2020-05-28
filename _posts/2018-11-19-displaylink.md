---
title:      "Getting the Asus MB169B+ working on Fedora"
date:       2018-11-19 15:40:00 +0100
excerpt: ""
categories:
  - Ramblings
tags:
  - Slice of Cake
  - Fedora
header:
  overlay_image: "/img/2018/displaylink-wall.jpg"
  og_image: "/img/2018/displaylink-desk.jpg"
  teaser: "/img/2018/displaylink-desk.jpg"
  caption: "Photo credit: author"
  overlay_filter: 0.3 
---

I recently got three Asus MB169B+ USB Monitors to help with showing of Fedora and other projects at conferences.  I was inspired by [Rich Bowen](https://twitter.com/rbowen) of the CentOS project to do this (and CentOS helped pay for these units).

![Monitor on a desk](/img/2018/displaylink-desk.jpg)

There are some decent reviews of these online, so I won't go into too many details.  The short version is they are lightweight, easy to pack and work well.  They don't replace a large screen tv/monitor or projector, but they do make it easy to do more than just run laptops.  The one draw back is that they require X11 and not Wayland today.

Getting them running on Fedora has been super easy, but had a few "gotchas."

1. Download the Linux driver from [Displaylink](https://www.displaylink.com/downloads/ubuntu)

    They call it the *Ubuntu* driver, however it works on Fedora, and I suspect all reasonably modern and **normal** Linux distributions.  In particular, the installation package uses `dkms` and supports `systemd`.

2. Install the driver and manager package

    `$ sudo ./displaylink-driver-4.4.24.run`

    If you'd like to examine the source or determine what it does, expand the [makeself](https://makeself.io/) archive with the `--noexec --keep` options.

3. Fix the systemd service file by editing `/usr/lib/systemd/system/dlm.service` and updating the following line:

    Old: `ExecStart=/opt/displaylink/DisplayLinkManager`
    New: `ExecStart=/bin/sh -c '/opt/displaylink/DisplayLinkManager'`

4. Reboot

Note: The first time I plugged in the display, I had to manually set the resolution in Gnome's settings to 1920x1080 as well as configure mirroring/joint display.

![Monitor on a wall](/img/2018/displaylink-wall.jpg)

The picture above shows the monitor in use at [Build Stuff](https://buildstuff.lt).  We hung the displays on the backdrop using [Command Strips](https://www.amazon.de/Command-Klebestreifen-Aufh%C3%A4ngen-Bildern-30-Paar/dp/B01FEJ3OA4/ref=sr_1_5?ie=UTF8&qid=1541864133&sr=8-5&keywords=command+strips) similar to these.

Addendum: After figuring out all of the above, I discovered a group is [producing RPMs](https://github.com/displaylink-rpm/displaylink-rpm) on GitHub.  [David Halasz](https://twitter.com/halaszdavid) tested it on his laptop and it seemed to work without changes or modifications.
