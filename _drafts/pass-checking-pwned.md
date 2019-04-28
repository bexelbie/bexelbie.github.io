---
title:      "I secured my passwords and you can too"
date:       2019-03-28 17:11:00 +0100
excerpt: ""
categories:
  - Technology
tags:
  - Encryption
  - Security
classes: wide
header:
  overlay_color: "#333"
---

Password security is set of practices, not all of which are appropriate or possible for you to adopt.  You should take the steps that are most likely to be effective for you within the context of your threat model.  If you don't already have a threat model, you should consider who you are protecting against and then model your security to focus primarily on those activities which are effective against these specific threats.  The EFF has a [great series on threat modeling](https://ssd.eff.org/en/module/your-security-plan) I highly encourage you to read.

In my threat model, I am concerned about the security of my passwords from, amongst other things, dictionary attacks.  [Dictionary attacks](https://en.wikipedia.org/wiki/Dictionary_attack) are when an attacker uses a list of likely or known passwords in an attempt to break-in.  This is typically stopped by having your service provider rate-limit or deny attempts after a certain number of failures.  It is also stopped by using passwords that are unlikely to be in the "known password set."


# How to Safely Check a Password - The Theory

[Troy Hunt](https://www.troyhunt.com/) created [haveibeenpwned.com](https://haveibeenpwned.com/) to notify people when their information has been found in leaked data dumps and breaches.  If you haven't already registered, you should.  The mere act of registering exposes nothing.  As a part of managing this data, a collection of over 550 million real-world passwords has been built.  These are passwords that real people used and that were exposed by data that was accidentally made public or that was stolen.  The site **does not** publish the plaintext password list, but they don't have to either.  By definition this data is already out there.  If you've ever reused a password or used one that is "common" then you are at risk because someone is building a dictionary of these passwords to try right now.

The National Institutes of Standards and Technology (NIST) [recommends that you check passwords against those that are known to be compromised](https://pages.nist.gov/800-63-FAQ/#q-b5) and change them if they are found.  Haveibeenpwned.com supports this via a password checking feature.   This feature is exposed via an API so it is easy to use.

Now, it would be a bad idea to just send the website a full list of your passwords.  While I trust this site, it is always possible it will be compromised.  Instead, it uses a process called [k-Anonymity](https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/) to allow the passwords to be checked without exposing them.  This is a three step process:



1. Create a hash value of your password.  A hash value is just a way of turning arbitrary data, your password, into a fixed data representation, the hash value.  A cryptographic hash function is collision resistant meaning it creates a unique hash value for every input.  This makes it hard to know what the input value was if you only have the hash value. For example, using the SHA-1 algorithm used by haveibeenpwned.com, the password "hunter2" becomes "F3BBBD66A63D4BF1747940578EC3D0103530E21D".
2. Send the first 5 characters, "f3bbb" in our example, to the site.  The site will send back a list of all the hash values that start with those 5 characters.  This way the site doesn't know which of those hash values you were actually interested in.  The k-Anonymity process is focused on ensuring there is so much statistical noise that it is hard for a compromised site to determine which password you inquired about.  In our example, we get back a list of 527 potential matches from haveibeenpwned.com.
3. Search through the list of results to see if your hash is there.  If it is, then like "hunter2" your password has been compromised.  If it isn't there, the password isn't in a publicly known data breach.  A bonus in the data returned by haveibeenpwned.com is a count of how many times the password has been seen in data breaches.  In the case of "hunter2" it has been seen an amazing 17,043 times!


# How to Safely Check a Password - The Practice

I use [`pass`](https://www.passwordstore.org/), a gpg-based password manager.  Many extensions have been written for it and you can find a [list on the pass website](https://www.passwordstore.org/#extensions) and as a separately maintained [awesome-style list](https://github.com/tijn/awesome-password-store).  One of these extensions is [pass-pwned](https://github.com/alzeih/pass-pwned) which will check your passwords with haveibeenpwned.com.

Below I will walk you through a quick setup of `pass` followed by checking a stored password.  Opensource.com has [great article on getting started with pass](https://opensource.com/life/14/7/managing-passwords-open-source-way) which you should read if you're new to it.  This example assumes you already have a GPG key.


```
# Setup a pass password store
$ pass init <GPG key email>

# Add the password, "hunter2" to the store
$ pass insert awesome-site.com

# Install the pass-pwned extension
# Download the bash script from the upstream and then review it
$ mkdir ~/.password-store/.extensions
$ wget https://raw.githubusercontent.com/alzeih/pass-pwned/master/pwned.bash -O ~/.password-store/.extensions/pwned.bash
$ vim ~/.password-store/.extensions/pwned.bash

# If everything is OK, set it executable and enable pass extensions
$ chmod u+x ~/.password-store/.extensions/pwned.bash
$ echo 'export PASSWORD_STORE_ENABLE_EXTENSIONS="true"' >> ~/.bash_profile
$ source ~/.bash_profile

# Check the password
$ pass pwned awesome-site.com
Password found in haveibeenpwned 17043 times

# Change this password to something randomly generated and verify it
$ pass generate -i awesoem-site.com
The generated password for awesome-site.com is:
<REDACTED>
$ pass pwned awesome-site.com
Password not found in haveibeenpwned
```

Congratulations, your password is now more secure than it was before.  You may wish to install the [shell completion functions](https://github.com/alzeih/pass-pwned/tree/master/completion) for your preferred shell or to look at ideas for [checking more than one password](https://github.com/alzeih/pass-pwned/issues/3) at a time.

Periodically checking for password compromise is great step in helping you ward off most attackers that appear in most threat models.  If your password management system doesn't make this easy to do, you may want to upgrade your system to something like `pass`.
