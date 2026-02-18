---
title: "The CentOS Project Changes: And How It's Better for Production Kernels"
permalink: /talks/2022/lund-centos-production-kernels/
entry_type: talk
speaking_event: "Lund Linux Con"
speaking_date: 2022-05-12
speaking_links:
  details: /talks/2022/lund-centos-production-kernels/
  slides: /img/2022/Lund%20Linux%20Conference%20-%2012%20May%202022.pdf
layout: single
author_profile: true
classes: wide
---

## Presented at [Lund Linux Con](https://www.lundlinuxcon.org/) in Lund, Sweden on 12 May 2022

[Recording](https://www.youtube.com/watch?v=mk1_uLIxQ_o) | [Slides (PDF)](/img/2022/Lund%20Linux%20Conference%20-%2012%20May%202022.pdf)

## Talk Description

In 2020, the CentOS Project shifted its focus from CentOS Linux, a downstream rebuild of Red Hat Enterprise Linux, to CentOS Stream, which sits mid-stream between Fedora and RHEL. By 2022, the change was still widely misunderstood. This talk made the case that it was actually a significant win, especially for kernel developers.

The argument starts with a number: 65% of all Linux machines in production were running either the RHEL kernel or a kernel derived from its sources. Before Stream, contributing directly to that kernel was nearly impossible. Fedora contributions waited for the next major RHEL release. CentOS Linux did not accept contributions. RHEL itself was closed to outside patches. Stream changed that equation. With CentOS Stream as the development target for the next RHEL minor release, anyone could now propose changes that would flow into RHEL and, by extension, into every distribution derived from its sources. The former RHEL rebuilds now drew from Stream rather than from a finished RHEL release, meaning contributions landed faster and reached further.
