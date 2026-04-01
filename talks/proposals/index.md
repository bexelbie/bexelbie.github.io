---
title: "Proposals & Rejections"
excerpt: "Submitted and rejected CFP proposals"
permalink: /talks/proposals/
redirect_from:
  - /cfp-submissions/
  - /talks/cfp-submissions/
layout: single
author_profile: true
classes: wide
---

If you're looking for talks I've actually given and articles I've published, see [Talks & publications](/talks/).

{% comment %}
  Collect all pages and posts with entry_type: proposal.
{% endcomment %}

{% assign proposal_pages = "" | split: "" %}
{% for page in site.pages %}
  {% if page.entry_type == "proposal" and page.speaking_date %}
    {% assign proposal_pages = proposal_pages | push: page %}
  {% endif %}
{% endfor %}

{% for post in site.posts %}
  {% if post.entry_type == "proposal" and post.speaking_date %}
    {% assign proposal_pages = proposal_pages | push: post %}
  {% endif %}
{% endfor %}

{% assign proposal_pages = proposal_pages | sort: "speaking_date" | reverse %}
{% assign rejected_proposals = proposal_pages | where: "proposal_status", "rejected" %}

## Proposed

{% assign any_proposed = false %}
{% for item in proposal_pages %}
  {% if item.proposal_status != "rejected" %}
    {% assign any_proposed = true %}
- [**{{ item.title | strip }}**]({{ item.permalink | default: item.url }})<br>Submitted proposal, {{ item.speaking_date | date: "%B %Y" }}, {{ item.speaking_event }}
  {% endif %}
{% endfor %}

{% unless any_proposed %}
No submitted proposals are currently tracked here.
{% endunless %}

## Rejected / Unsuccessful

{% for item in rejected_proposals %}
- [**{{ item.title | strip }}**]({{ item.permalink | default: item.url }})<br>Rejected proposal, {{ item.speaking_date | date: "%B %Y" }}, {{ item.speaking_event }}
{% endfor %}

- [**FOSDEM Project Atomic Table @ FOSDEM 2016**](/talks/fosdem/fosdem-2016-table-proposal-atomic)<br>Unsuccessful table proposal

For more FOSDEM CFP and DevRoom materials (including successful devroom submissions), see [FOSDEM materials](/talks/fosdem/).
