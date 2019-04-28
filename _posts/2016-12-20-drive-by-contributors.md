---
title:   "When Do Drive-By Documentation Contributors Start to Matter?"
excerpt:  "a/k/a When do you build it?"
date:    2016-12-19 13:03:00 +0100
categories:
  - Technology
tags:
  - Fedora
  - Documentation
classes: wide
header:
  overlay_color: "#333"
redirect_from:
 - /technology/2016/12/19/drive-by-contributors/
---

# We should be using a Wiki

A common conversation in documentation circles involves tooling.
Within this genre, there is a special conversation around friction that
creates a barrier to contribution.  Inevitably, someone will argue their
preferred tooling (OK, wiki ... it is always wiki) is better because it
has the lowest friction for drive-by contributors.  These contributors,
the argument goes, are critical and represent the bulk of the edits
and contributions.  They then proceed to cite the hit list of fantastic
wiki projects, Wikipedia, Arch Linux, etc.  I've had this conversation
in the Fedora Docs Project and most recently in the ledger-cli project.

The counter arguments usually seem to boil down to only a few points:

* Wiki's suck or wiki's don't support the workflow I think is important.
* We don't have enough (potential[^0]) wiki gardeners to prevent spam,
   bad edits, etc.
* Our scale is no where near those projects so we can't expect the
   same results.
* Our users, should in general, be familiar with more tools so this
   isn't a problem.

Neither side in this conversation has actually proven their point,
they've just made arguments based on their beliefs.  I was wondering if
one could prove the need to lower contribution barriers to the "wiki"
level.

If you make compromises too early, you are suffering from the "think I
need vs I actually need" feature problem.  This is similar to designing a
new product for launch.  It is not uncommon for people to get sidetracked
on features, such as "How to change your payment method," that aren't
needed at launch[^1].  The "new common thinking" is launch a minimum
viable product (MVP) and build the features as user demand warrants them.

# It's raining cold hard (arbitrary) facts up in here.[^8]

I am making the following base line contextual decisions[^2]:

1. Your current documentation contributors are highly affiliated with
   the project and don't want to have more tools to use than necessary.
   i.e. They want their docs as close to their source as they can get it.
1. Your website/publishing/man pages/whatever are all built using a build
   script or CI/CD and you want to be able to test for docs in PRs, etc.
1. You want someone to review documentation changes for sanity,
   spamminess, accuracy, etc.
1. You're willing to compromise on the first 2 points in exchange for
   better and more complete documentation.
1. Wikis have a lower barrier to contribution than all other tooling
   options.  This is accepted to make this case.  This is a whole other
   debate in actuality.

This makes me want a number, a tipping point, a something, that indicates
when I should start compromising on the first 2 points in order to get
better documentation.  In other words, when do drive-by contributors
who are scared off by your current tooling become too important to
keep ignoring.

# Warning: Bad Data Analysis Follows

Warning: I am not a data analyst.  I even got turned down for my audition
to play one on TV.  Therefore, I suspect there are holes you can drive
several trucks through in what is written below.  Use the links at the
bottom to tell me about them and how to fix them.  Even better, write
your own post somewhere and I'll link to it.

In the absence of any other readily available data, I went to one of the
leading lights of the wiki world, Wikipedia.  I found the [following
data](https://stats.wikimedia.org/EN/TablesWikipediaEN.htm) about
Wikipedians.  Wikipedians are what Wikipedia calls contributors.  Based on
this data, I put together a table ([ODS](/img/2016/wikipedia.data.ods),
[PDF](/img/2016/wikipedia.data.pdf) of contributor counts.  I've made
the following contextual decisions[^3]:

* A drive-by contributor is modeled by Wikipedians who make less than
   5 edits per month.
* Core contributors, those who are both prolific and theoretically
   willing to put up with some level of friction, are modeled by the
   Wikipedians who make more than 5 edits per month.
* The population make up of Wikipedia is comparable to your project
   (hah!).
* You will get no drive-by contributor until you move to a wiki.

## Question 1: Assuming all contributors have equal value to the project, when are we "losing" more than 50% of the potential contributors?

In January 2002 Wikipedia reported 344 total Wikipedians of which 152
made more than 5 edits.  This is the first month in which more than
50%[^4] of Wikipedians were drive-by contributors.

Therefore, assuming the rest of this holds any truth, once your project
hits 152 documentation contributors a month you should consider shifting
the balance of tools vs low friction towards the low friction side of
the equation.

Obviously a massive caveat here is that Wikipedia was so new in January
2002 that this number might be meaningless.  So maybe a different question
is in order.

## Question 2: Assuming all contributions have equal value to the project, when are we "losing" more than 50% of the potential contributions?

For this question, lets see when we are losing 50% of the contributions.
Because of lack of data detail, I made the following contextual
decisions[^5]:

* Drive-by Contributors made 3 edits per contributor.  That is halfway
   between 1 and 5 edits per month.
* Contributors with greater than 5 edits per month but less than 10 edits
   per month, made 8 edits per contributor.  That is halfway between 6
   and 10.
* Contributors who made greater than 10 edits per month made 11 edits.
   Let's balance against an upper maximum of infinity.

In February 2007 Wikipedia reported 192,338 total Wikipedians with 47,849
making more than 5 edits per month and 4,500 having made more than 10
edits per month.  This is the second month, and the beginning of the
solid trend, where more than 50%[^6] of the edits were made by drive-by
contributors.

Therefore, assuming the rest of this holds any truth, once your project
hits 47,849 documentation contributions a month you should consider
shifting the balance of tools vs low friction towards the low friction
side of the equation.

But maybe that is not how you think about things.  Perhaps you think
differently.

## Question 3: Assuming we don't want to risk losing too many potential contributors, what is a metric for figuring out this loss?

One way of thinking about this is by trying to determine when I've
turned away a drive-by contributor?  What if we could look at how many
page-views your project has to have before you get a drive-by contributor?

Wikipedia provides page-view traffic.  In May 2015 Wikipedia changed
their data reporting for page-views to eliminate bot traffic.  I also
didn't find any [data](http://reportcard.wmflabs.org/) for months after
August 2016.  Therefore, I restricted my analysis to just the months
between May 2015 and August 2016.  I calculated the number of pages-views
per drive-by contributor[^7].  I then averaged the value for those months.

Therefore, for every 7,529 page-views per month of your documentation,
you are losing a drive-by contributor.

# Final Thoughts

I am not sure yet how to put these ideas into practice.  I am not sure
which question I have the most identification with.  I'd also like to
see some data statistics on projects considering moving to wikis to see
if these numbers make any sense at all.  I sincerely doubt many projects
have over 100 documentation contributors.  Should this be considered over
the set of all contributors and not just documentation contributors?
How many projects get more than 75,000[^9] page-views a month for
documentation alone?

Additionally, I'd also like to see some UX studies done of a wiki
edit versus a web-based edit/PR in [GitHub](https://github.com/) or
[Pagure](https://pagure.io/).  While not directly related to this
analysis, this could resolve the question of whether this is even
a question[^10].

Finally, I suspect there are methodological flaws, data flaws,
contextual decision flaws and more in this simple analysis.  I am also
fairly certain, though, I didn't find it, that someone has to have done
a better analysis of these questions.

Please provide some feedback.  Is this meaningful? Is there better
data? Better methodology? Better conclusions?
Should I try for a follow up using [Arch Wiki's
Statistics](https://wiki.archlinux.org/index.php/ArchWiki:Statistics)?

Let me know.  You can contact me using the links below.

[^0]: Fedora already has a wiki that is suffering from a lack of gardening.  Ledger-cli has a wiki that is not being used for the documentation in question even though it could.  However it doesn't seem to have a high level of contributors (I also have not looked but am judging this based on the content quantity.)

[^1]: and probably not for a long time.  Go read some [Tyler Tringas](https://tylertringas.com/shipping-a-saas-minimum-viable-product/)!

[^2]: How's that for a fancy term for "assumptions I pulled out of the [MIASS](http://www.c4vct.com/kym/humor/miass.htm) database."

[^3]: You know what the problem with "contextual decisions" is .. it makes a condec out of you and me ... or something like that.

[^4]: Percentage of edits by contributors making less than 5 edits per month: =1-(D181/B181)

[^5]: It's my blog post so I get to make stuff up.  If you wanna play, get your own blog post.

[^6]: Percentage of edits by contributors making less than 5 edits per month: =((B120-D120)*3)/((B120-D120)*3+(D120-E120)*8+E120*11)

[^7]: Page-views per drive-by contributor: =J5/(B5-D5)

[^8]: [Sears Commercial](https://www.youtube.com/watch?v=aGmfgqObtLk) Yes, I do have an interesting sense of humor, thanks for asking.

[^9]: 75,000 page-views would mean the loss of about 10 drive-by contributors.

[^10]: We don't really have this conversation about code.  Perhaps we should.  I know that I have avoided contribution to a project in the past because it used a language I didn't feel like fighting with.
