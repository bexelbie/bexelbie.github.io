---
title:      "Nulecule: Packaging, Distributing & Deploying Container Applications the Cloud Way"
excerpt:   "Delivered at Config Management Camp EU 2016"
date:       2016-02-02 14:00:00
categories:
  - Technology
tags:
  - Containers
  - Project Atomic
header:
  overlay_color: "#333"
redirect_from:
 - /2016/02/02/configmgmtcamp/
 - /2016/03/11/Nulecule-talk/
---

![Config Management Camp EU Logo](/img/2016/configmgmtcampeu2016-logo.png){: .align-left}
I had the privilege of speaking at [Config Management Camp EU
2016](http://cfgmgmtcamp.eu/schedule/speakers/BrianExelbierd.html)
([lanyrd.com](http://lanyrd.com/2016/cfgmgmtcamp/sdxytt/)) in
beautiful Ghent, Belgium on 2 February 2016.  At the last moment I
was asked by [Vaclav Pavlin](https://twitter.com/vpavlin) to do the
talk for him when he couldn't attend.  I am grateful to him for the
opportunity to talk and to the organizers of Config Management Camp
EU 2016 for holding such a fantastic conference and letting me
speak.

The talk was on
[Nulecule](https://github.com/projectatomic/nulecule/blob/master/docs/getting-started.md)
a sub-project of [Project Atomic](http://www.projectatomic.io)
focused on multi-container application lifecycle management.

Nulecule is just a specification that is tool agnostic.  Thankfully
there is a great reference implementation, [Atomic
App](https://github.com/projectatomic/atomicapp), that I used to
create a demo of the project.

I started with Vaclav's slides and made them my own, including
adding the demo.  The demo shows how to use a Nulecule for multiple
orchestrator and includes a demo of launching the entire process via
configuration management.  Specifically an
[Ansible](http://www.ansible.com) playbook is used to deploy a
[Etherpad Nulecule
Application](https://github.com/kadel/nulecule-library/tree/cfgmntcmp-etherpad/etherpad-centos7-atomicapp)
on a [Mesos-Marathon](https://mesosphere.github.io/marathon/)
orchestrator running in the demo on an [Atomic Developer
Bundle](https://github.com/projectatomic/adb-atomic-developer-bundle).

I could not have done this without the great work that has gone
into all of these projects.  I must give a **huge shout-out** to
[Tomas Kral](https://github.com/projectatomic/adb-atomic-developer-bundle)
and Michael Scherer for their help in making the demos work.  Together
we were able to ramp the demo up and get past a few unexpected
hurdles faced when working with an evolving spec and implementation.

[Slides and Demo Code](https://github.com/bexelbie/nulecule-talk-demo)
is available online.  I strongly encourage folks to kick the tires
and submit PRs and Issues to help me improve the talk.
