---
title: "Talks & Publications"
excerpt: "Talks, articles, and proposals"
classes: wide
redirect_from:
 - /cfp-submissions/
---

Talks I've given and articles I've written for other publications.

{% comment %}
  Collect all pages and posts with entry_type set.
  Exclude organizing and template entries.
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
  {% if item.entry_type == "article" %}- [**{{ item.title | strip }}**]({{ item.url }})<br>Article, {{ item.speaking_date | date: "%B %Y" }}, {{ item.speaking_event }}
  {% elsif item.entry_type == "proposal" %}- [**{{ item.title | strip }}**]({{ item.permalink | default: item.url }})<br>Submitted proposal, {{ item.speaking_date | date: "%B %Y" }}, {{ item.speaking_event }}
  {% else %}- [**{{ item.title | strip }}**]({% if item.speaking_links.details %}{{ item.speaking_links.details }}{% else %}{{ item.permalink | default: item.url }}{% endif %})<br>Talk, {{ item.speaking_date | date: "%B %Y" }}, {{ item.speaking_event }}
  {% endif %}
{% endfor %}
