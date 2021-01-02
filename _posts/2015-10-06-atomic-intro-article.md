---
title:      "Project Atomic or: How I Learned to Stop Worrying and Love Containers"
excerpt:   "posted at Linux.com"
date:       2015-10-06 12:32:00
categories:
  - Technology
tags:
  - Project Atomic
header:
  overlay_color: "#333"
redirect_from:
 - /2015/10/06/atomic-intro-article/
 - /technology/2015/10/06/atomic-intro-article/
---

# Project Atomic or: How I Learned to Stop Worrying and Love Containers

Project Atomic is a set of technologies that make containers easier to develop, configure, deploy, run, administer, and deliver in a wide variety of execution environments.  This interconnected set of technologies starts with tools that make it easier to run a single container and continues to tools that help deploy complex multi-container applications.  

Many of these projects include the word 'atomic' in their name.  Therefore, discussions turn into conversations about 'atomics' and people get confused.  In this post, you will be introduced to the main 'atomics' and a few of their friends.

Read more over at [linux.com](https://www.linux.com/news/enterprise/storage/858082-project-atomic-or-how-i-learned-to-stop-worrying-and-love-containers) where this was originally posted.

<!--
## Atomic Host

Containers need a operating system to run on, and that's Atomic Host.  [Atomic Host](https://www.projectatomic.io/download/) represents a design pattern for distributions to build an environment that is  optimized for running Linux containers.  This pattern can be implemented by existing distributions, which is critical.  This eliminates the need to wrap your head around building a new operating system while developing a container deployment environment at the same time. 

Some key advantage of an Atomic Host are:

    Built on a trusted distribution

        Pulling the components that are required to support containerization from a distribution that is trusted and then layering on additional capabilities for containers means that the operating system already has:

    Hardware  and software support, including known kernel support and drivers

    Broad ISV and IHV support

    Established and familiar ways to get involved, file bugs, submit patches and get support often from the same colleagues and communities you are familiar with.

    The ability to reuse existing skills instead of having to learn a whole new operating system

    Atomic Updates

    Single-step, or atomic, upgrades and reversioning  of the operating system.  This is done via the delivery of an OSTree, or a complete system tree, to the server which is used to boot the server into a new operating system version.

    No half updated systems or unpacking RPMs and running scripts on every host.

    A Streamlined package set that only includes what is required to build a docker and kubernetes environment.


You can find Atomic Host variants of [Fedora](https://getfedora.org/en/cloud/), [CentOS](https://seven.centos.org/2015/09/announcing-a-new-release-of-centos-atomic-host/) and [Red Hat Enterprise Linux](https://access.redhat.com/products/red-hat-enterprise-linux/#atomic-host).  These distrubtions use [rpm-ostree](https://github.com/projectatomic/rpm-ostree) to implement the Atomic Host pattern.  It allows existing and trusted RPMs to be leveraged to construct the OSTrees.  It is also optimized for delivering the tree because it implements what is essentially git for the operating system.

# Nulecule and Atomic App

Question: What do you call a containerized application?
Answer: A mess of images, containers, READMEs and configuration files pretending to be easily deployable. 1990 called and wants its install process back!

Most applications are made of multiple containers.  Even a simple web application will typically require a web-frontend and a database.  Different container environments  will connect those applications in different ways.The [Nulecule Specification](https://www.projectatomic.io/docs/nulecule/) allows a multi-container application to be specified and configured once and then deployed and  run in many  execution environments. Today there is support for Docker, Kubernetes and OpenShift and more are welcome. It's worth noting, that Nulecule is a made up word derived from molecule by fictional nuclear plant operator Homer Simpson.  Even the specification name has something to with atomic!

A specification is great, but an implemenation is needed for it to be useful. [Atomic App](https://www.projectatomic.io/docs/atomicapp/) is a python based implementation of the Nulecule specification. It lives inside a container that is run by the application user.  The user never runs atomic app directly, but benefits from the configuration that atomic app provides.

# Atomic Command

In contrast to Atomic App, the [Atomic Command](https://www.projectatomic.io/docs/usr-bin-atomic/) is a tool to make running containers easier. It provides additional functionality and adds syntactic sugar.  For example, using [special labels](https://github.com/projectatomic/ContainerApplicationGenericLabels) atomic can install, start and stop containers easily by turning long `docker` commands into short commands like `atomic run projectatomic/helloapache`.  Atomic Command is available for many distributions and has been tested on Fedora, CentOS, Debian and Red Hat Enterprise Linux in both standard and Atomic Host (where available) variants.

If you're using an Atomic Host, the atomic command does double-duty and provides access to host-specific administration, including upgrades.

# Atomic Developer Bundle

The [Atomic Developer Bundle (ADB)](https://github.com/projectatomic/adb-atomic-developer-bundle) provides a platform for developers on Linux, Windows, and OS X to use when packaging containerized applications.  The ADB encourages good packaging patterns and integration with native, PaaS, and IaaS environments. The ADB is a virtual machine that contains all the tools needed to package containerized applications for these environments.  Included in the box is a fully functional kubernetes pre-configured for you to develop against.

# Atomic Reactor & OpenShift Build System Client

[Atomic Reactor](https://github.com/projectatomic/atomic-reactor) is a command line addressable source-to-image builder for docker containers.  Starting with a git repo it can resolve all dependencies and build requirements to allow you to build and push a container to a registry easily.  Using atomic reactor will allow your build chain to be clean and automatable.  Look for it to appear in the Atomic Developer Bundle.  A similar tool, [OpenShift Build System (OSBS) Client](https://github.com/projectatomic/osbs-client), can trigger builds and deployments in OpenShift.

# Atomic Enterprise

In between PasS and IasS sits a project with 'atomic' in its name.  [Atomic Enterprise](https://github.com/projectatomic/atomic-enterprise) builds on the power of Atomic Host and embeds the operational enablement technologies of OpenShift into a simple, powerful, and easy-to-approach experience for deploying and scaling applications in containers. Atomic Enterprise is an infrastructure platform that is designed to run, orchestrate, and scale multi-container based applications and services. It provides a scale-out cluster of Atomic Host instances that together form a foundation for delivering traditional and cloud-native applications via containers.

Project Atomic has an 'atomic' for every container situation.  Individuals experimenting with containers on their laptops can use the Atomic Command, developers the Atomic Developer Bundle, Atomic App, and Nulecule, and operators can use Atomic Reactor and Atomic Enterprise.  With all these 'atomics', I am sure you will find one to love.
-->
