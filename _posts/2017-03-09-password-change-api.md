---
title:   "We Need a Password Change API"
excerpt:  "because I got pwned"
date:    2017-03-09 12:10:00 +0100
categories:
  - Ramblings
tags:
  - Security
classes: wide
header:
  overlay_color: "#333"
redirect_from:
 - /ramblings/2017/03/09/password-change-api/
---

This morning I got an email from [haveibeenpwned.com](https://haveibeenpwned.com/) informing me that one of my email addresses showed up in a data dump.  I've been using [`pass`](https://www.passwordstore.org/) to manage my passwords for a while (and [1Password](https://1password.com/) before that) so most of my passwords are unique, not easily guessable, and not directly known by me.  Additionally, I have set up 2FA in most places where it is available.

However, like most folks, I get lazy.  If I visit a site just to look around and their silly design requires an account before I can test anything, I may not actually create a good password.  If I am on a phone or other device that doesn't have my password database I may put in a "temporary password" to be changed later.  That password never gets changed.  Lastly, like a lot of people, in my pre-password manager days I had a lot of duplicate or mostly duplicate (algorithms a 3 year old would giggle at) passwords.  A lot of these are on what used to be "low-stakes" accounts, but now with cheap and easy big data are just as important as everything else.

Now I need to find some time to both change the pwned account's password and determine if anything else in the database is likely to be compromised as a result.  And, frankly, I should spend some time doing some housekeeping on both accounts and other duplicated or poor quality passwords.  This is a time-sink of a task that is as fun as it sounds.

Therefore, I think we should develop a password change API.  The idea being that I could tell my password manager, "Change the password for this site" and it could just do it.  There would be a known service on a known port that could be used for the change.  If 2FA (or some pretend *sekrit* phrase) is in use, my password manager can prompt me for the proper response.  With this, my passwords might actually get changed quickly when I get pwned.

Additionally, this opens up the opportunity for computers to actually be helpful.  My password manager could now actually help me remove duplicate passwords instead of just nagging me about them.  If my password manager could take a data feed from one of the "hacked" sites lists (or use a vendor-provided database like 1Password's [Watchtower](https://1password.com/features/)) it could prompt before a third-party notices and emails me.  Heck, if I trust my password manager enough it could just change the password and tell me it did it.

A better solution, of course, would be to replace passwords with something better.  So far I have seen keys/certificates and password hashing.  Keys and certificates work brilliantly, except for the whole "never expose the key and never lose the key" thing.  This means it is hard for normal users who have sketchy backup processes to begin with and lose stuff constantly.  I am not sure I even really trust myself with a key/certificate solution.  But, in my defense, I haven't lost the private key for my GPG Key yet.

Password hashing sounds cool. It is an interim step that solves some of the problems, like forcing users to use unique passwords.  However, according to a recent [LWN](https://lwn.net/) article, [password hashers](https://lwn.net/Articles/715090/) have some usability problems and it sounds like, in practice, hashing may be cryptographically questionable because of how likely it is that someone could get two encrypted and mostly known phrases.  Therefore I don't think that either of these is going to be the successor technology.

Passwords are just about the worst security mechanism we have, except all the others.  Therefore, they aren't going away any time soon.  They are also unlikely to get replaced until someone comes up with something that is more secure, easy to use by 90% or more of the population, and somewhat idiot-proof for when people lose things or write stuff down on sticky notes.  Until then, a Password Change API would make the world a bit more usable.
