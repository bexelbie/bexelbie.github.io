---
layout:     post
title:      "No Docs, No Commit"
subtitle:   "Playing with travis-ci.org"
date:       2016-01-26 14:00:00
author:     "Brian Exelbierd"
header-img: "img/2016/crack-team.png"
published:  false
---

My fantastic colleagues who work for [Red Hat's Customer Content
Services](https://access.redhat.com/documentation/en/) in Brno have
been developing a play about "No Docs, No Commit."  I hope to see
it for the first time during [DevConf.cz](http://devconf.cz/) in
February.

For those not familiar with this idea, it is about not allowing
code in a changes in a project without also having updates to the
documentation made.  Code changes generally have a visible effect
to either users or other developers.  Documentation for those groups
needs to be updated.

This idea, when combined with a relatively recent
[conversation](https://github.com/projectatomic/adb-atomic-developer-bundle/issues/175)
about automatically spell checking documentation in source repositories
led me to start to think about how to do it.  There are pluses and
minuses to spell checking, however checking for docs in general
could be fun.

To do either of these, you should use continuous integration testing
ala [travis-ci.org](https://travis-ci.org).  Therefore, I took the
opportunity to learn how to use it.

That resulted in me writing this:

~~~
language: python
python:
  - "2.7"
env:
  - DOC_DIR=docs/
# Check to see if any documentation files (.md, .rst) in the doc
# directory were added/changed
script:
- |
    if git diff --name-only $TRAVIS_COMMIT_RANGE $DOC_DIR | grep -qE '(\.md$)|(\.rst$)'
    then
      echo "There appear to be docs in this commit.  Thank you."
      exit
    else
      echo "There commit doesn't seem to have any docs."
      exit 1
    fi
~~~

Stick this bit of silliness in your `.travis.yml` and it will
complain if you don't have docs in your commit.  It is crude and
needs some improvement, however it served the real purpose of forcing
me to play with travis-ci.org.

So remember, if you propose a PR/Commit with no docs, my "CI team"
will be standing by to tell you, "No."

![IRC log](/img/2016/crack-team.png)
IRC log courtesy of #taskwarrior.
