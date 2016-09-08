---
layout:   post
title:   "A Semantic Markup Proposal for AsciiDoc"
subtitle:  "And Fedora Docs"
date:    2016-09-08 15:25:00 +0000
author:   "Brian Exelbierd"
#header-img: ""
published: true
tags: "fedora"
---

This is a bit long, but I hope it is worth it.

TL;DR: We need semantic markup in the Fedora Docs and probably in other
projects. We can do it in AsciiDoc.  Here is how.

# Why AsciiDoc?

[AsciiDoc](http://www.methods.co.nz/asciidoc) is a light-weight markup
language that is being adopted at a fast-pace by projects.  The Fedora
Documentation Project, for example, has decided to migrate its books
to AsciiDoc.  AsciiDoc excels at being very easy to write with as it
doesn't have a lot of tagging or other extraneous keystrokes.  It, like
many light-weight markup languages, is known for having sensible defaults.

However, it only has a few semantic markup elements.

# Why Semantic Markup?

Semantic markup can provide you with the ability to do many things,
including:

1. Ensure consistent presentation of similar types of content.

1. Signal to translators and localizers how content is being used so it
   can be localized properly.

1. Allow automated testing of content.

Let's take these apart:

## Consistent Presentation

When you are writing, you want similar ideas to be presented to the
user in the same way.  From a presentation perspective this means that,
for example, you may want all application names or command names to
be presented in a mono-space font.  You may want titles to be presented
in italics.  These visual clues help your reader process and understand
your text.

With AsciiDoc and other lightweight markup languages you
typically do this by creating a Style Guide and asking all of your
writers/contributors to adhere to it.  For example, [OpenShift's Style
Guide](https://github.com/openshift/openshift-docs/blob/master/contributing_to_docs/doc_guidelines.adoc)
includes the following:

<table>
<tr><td><b>Content</b></td><td><b>Formatting</b></td></tr>
<tr><td>System or software configuration parameter or environment variable</td><td>`*ENVIRONMENT_VARIABLE*`</td></tr>
</table>

This guidance tells writers that whenever they mention this content they
must use a combination of mono-space and bold.

This kind of a directive will help ensure the document is consistent.
However, the document cannot be automatically checked for compliance
and the writer has the additional cognitive overhead of 1) recognizing
they are using this kind of content and 2) remembering or looking up
what they are supposed to do.

Semantic markup cannot eliminate the need for a writer to recognize they
are using particular kinds of content, but it can ensure that they never
have to remember how it is to be displayed.  Semantic markup also allows
for a change in this content's presentation to be made automatically
without having to edit every occurrence of the content.

## Signals for Localizers

Not everyone who does translation and localization knows the details of
every product they work on.  Additionally, many times, translations and
localizations are affected by how content is used and may be different
in different situations.  For examples, when talking about the `find`
RPM and the `find` command, they localization could vary.

Semantic markup passes along the data of how the content is being used
in context and can help smooth out translation and localization issues.

## Automated Content Testing

Semantic markup can signal a testing program how a particular piece
of content is being used.  As an example, an automated testing tool
could spell-check a document and know not to spell-check commands.
Additionally, platforms like [emender](https://github.com/emender) are
working on tests to do advanced testing and verification.  For example,
to verify that the commands referenced in a document are still available
in the project.  Think about how many instances of `yum` had to be
changed to `dnf` which Fedora made the switch.

Automated content testing also creates the opportunity to build better
CI/CD pipelines and to eliminate manual testing steps in the documentation
process.

# How Could it Work?

I believe it is possible to add back arbitrary semantic markup
vocabularies to AsciiDoc in a way that is:

1. Toolchain safe: It should not break any AsciiDoc processing tool

1. Able to control for consistent presentation: All commands in
   `mono-space`

1. Able to be found with automated testing tools: It has to be easily
   parsed, no regex disasters

1. Easily typed: The absolute minimum of extra characters typed and
   minimally distracting while reading the source

1. Able to be ignored when not wanted: Semantic markup should be able
   to affect only presentation or testing, for example.

To see how this would work, let's use
this DocBook example from the [Fedora Installation
Guide](https://pagure.io/install-guide/blob/master/f/en-US/After_Installation.xml):

```
                    <para>
                        Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using <application>RPM</application> and <application>DNF</application>, see the <citetitle>&PRODUCT; System Administrator's Guide</citetitle>, available at <ulink url="http://docs.fedoraproject.org/" />.
                    </para>
```
Note: &amp;PRODUCT; is an entity reference.

First let's just translate it to AsciiDoc:

```
Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using RPM and DNF, see the {PRODUCT} System Administrator's Guide, available at http://docs.fedoraproject.org.
```

This yields the following HTML:

```
<p>Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using RPM and DNF, see the Fedora 24 System Administrator&#8217;s Guide, available at <a href="http://docs.fedoraproject.org" class="bare">http://docs.fedoraproject.org</a>.</p>
```

Note: I have substituted in "Fedora 24" for the PRODUCT entity.

This is very usable but doesn't contain anything highlighting the applications[^0] and book title in our original DocBook example.

So, let's define some styling and add that:

<table>
<tr><td><b>Content</b></td><td><b>Formatting</b></td></tr>
<tr><td>Application Names</td><td>`Application Name`</td></tr>
<tr><td>Book Titles</td><td>_Book Title_</td></tr>
</table>

And modify our AsciiDoc as follows:

```
Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using `RPM` and `DNF`, see the _{PRODUCT} System Administrator's Guide_, available at http://docs.fedoraproject.org. 
```

This yields the following HTML:

```
<p>Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using <code>RPM</code> and <code>DNF</code>, see the <em>Fedora 24 System Administrator&#8217;s Guide</em>, available at <a href="http://docs.fedoraproject.org" class="bare">http://docs.fedoraproject.org</a>.</p>
```

We have more perfectly acceptable HTML and we have presentation that
meets our style guide.  However, we don't have the three benefits of
semantic markup mentioned above.

So let's create that.  We will use the [custom styling with
attributes](http://asciidoctor.org/docs/user-manual/#custom-styling-with-attributes)
markup of AsciiDoc.  This means that we will wrap the content in an
attribute block, for example:

`[Name]#Content goes here#`[^1]

<table>
<tr><td><b>Content</b></td><td><b>Style Name</b></td></tr>
<tr><td>Application Names</td><td>App</td></tr>
<tr><td>Book Titles</td><td>Title</td></tr>
</table>

And, again, modify our AsciiDoc as follows:

```
Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using [App]#RPM# and [App]#DNF#, see the [Title]#{PRODUCT} System Administrator's Guide#, available at http://docs.fedoraproject.org. 
```

This yields the following HTML:

```
<p>Devices necessary to complete the installation can have driver updates provided before the installation begins. If a device is missing a driver, but it is not essential during the installation, it is recommended to wait until after the installation completes, and install additional drivers afterwards. For instructions on installing and enabling additional drivers on the installed system using <span class="App">RPM</span> and <span class="App">DNF</span>, see the <span class="Title">Fedora 24 System Administrator&#8217;s Guide</span>, available at <a href="http://docs.fedoraproject.org" class="bare">http://docs.fedoraproject.org</a>.</p>
```

This meets our requirements:

1. Toolchain safe: It standard AsciiDoc and requires no tools
   modifications

1. Able to control for consistent presentation: It generates a span that
   can be decorated with CSS

1. Able to be found with automated testing tools: This can be parsed
   for easily

1. Easily typed: It adds 4 characters plus the name

1. Able to be ignored when not wanted: Spans are ignored in presentation
   unless decorated with CSS

A similar method can be used with blocks.

# Conclusion

This AsciiDoc feature can and should be used by us to add back semantic
markup when it makes sense.  I believe that the three driving factors
above, presentation, localization, and testing present a compelling
reason to do this.

I further propose, without having necessarily considered all of the
outcomes, that we should test our AsciiDoc to flag manual bolding,
underlining, etc. for review.  These manual presentation controls are
often indicators that we have a content type that needs presentation
consistence, localization signaling and automated testing.

I'd be interested to hear what others have to say.
[Tweet](https://twitter.com/bexelbie) to me or send me email (see below).

# Bonus for Fedora Docs Contributors

I have started a thread on
[docs@lists.fedoraproject.org](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/)
to discuss [which tags should be retained as we move to
AsciiDoc](https://lists.fedoraproject.org/archives/list/docs@lists.fedoraproject.org/thread/Q3IOC3RZYPWOY3CXL7EQTEQPF4WHSVXD/).

I hope you will comment there.

[^0]: I know that RPM is not an application.
[^1]: Want to use a number sign inside of your content? Just use &amp;num;
