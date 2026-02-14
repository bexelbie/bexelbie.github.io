---
title: "Speaking & Writing"
excerpt: "Talks, articles, and proposals"
header:
  overlay_image: "/img/bex-speaking.jpg"
  og_image: "/img/bex-speaking.jpg"
  teaser: "/img/bex-speaking.jpg"
  caption: "Photo credit: Unknown - Likely Write the Docs Prague"
  overlay_filter: 0.5
classes: wide
redirect_from:
 - /cfp-submissions/
---

An archive of talks, proposals, and externally published articles in reverse chronological order. For demo scripts, slides, or code, I host a comprehensive [archive on GitHub](https://github.com/bexelbie/bexelbie-talks-demos), linked as appropriate.

Items appear here automatically when their front matter includes `entry_type` and `speaking_date`.

{% comment %}
  Collect all pages and posts with entry_type set.
  Exclude organizing and template entries from the main timeline.
{% endcomment %}

{% assign speaking_pages = "" | split: "" %}
{% for page in site.pages %}
  {% if page.entry_type and page.entry_type != "organizing" and page.status != "template" and page.speaking_date %}
    {% assign speaking_pages = speaking_pages | push: page %}
  {% endif %}
{% endfor %}

{% for post in site.posts %}
  {% if post.entry_type and post.entry_type != "organizing" and post.status != "template" and post.speaking_date %}
    {% assign speaking_pages = speaking_pages | push: post %}
  {% endif %}
{% endfor %}

{% comment %} Sort by speaking_date descending {% endcomment %}
{% assign speaking_pages = speaking_pages | sort: "speaking_date" | reverse %}

{% comment %} Group by year {% endcomment %}
{% assign current_year = "" %}
{% for item in speaking_pages %}
  {% assign item_year = item.speaking_date | date: "%Y" %}
  {% if item_year != current_year %}
    {% assign current_year = item_year %}

## {{ current_year }}

  {% endif %}
- **{{ item.title | strip }}**
  {{ item.speaking_event }}{% if item.entry_type == "article" %}, {{ item.speaking_date | date: "%B %Y" }}{% else %}, {{ item.speaking_date | date: "%B %d, %Y" }}{% endif %} · {{ item.entry_type }} · {{ item.status }}{% if item.speaking_links.details %} · [details]({{ item.speaking_links.details }}){% endif %}{% if item.speaking_links.external %} · [read]({{ item.speaking_links.external }}){% endif %}{% if item.speaking_links.external_en %} · [English]({{ item.speaking_links.external_en }}){% endif %}{% if item.speaking_links.external_fr %} · [French]({{ item.speaking_links.external_fr }}){% endif %}{% if item.speaking_links.slides %} · [slides]({{ item.speaking_links.slides }}){% endif %}{% if item.speaking_links.recording %} · [recording]({{ item.speaking_links.recording }}){% endif %}{% if item.entry_type == "article" and item.url %} · [blog post]({{ item.url }}){% endif %}
{% endfor %}

---

## Organizational & template material

Items below are not personal speaking or writing -- they are community organizing artifacts, booth/table proposals, and reusable templates.

{% assign org_pages = "" | split: "" %}
{% for page in site.pages %}
  {% if page.entry_type == "organizing" or page.status == "template" %}
    {% if page.speaking_date %}
      {% assign org_pages = org_pages | push: page %}
    {% endif %}
  {% endif %}
{% endfor %}

{% assign org_pages = org_pages | sort: "speaking_date" | reverse %}

{% for item in org_pages %}
- [{{ item.title }}]({{ item.permalink | default: item.url }}) -- {{ item.speaking_event }}{% if item.status == "template" %} (template){% endif %}
{% endfor %}
