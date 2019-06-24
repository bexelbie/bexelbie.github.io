---
title:      "Check your password security with Have I Been Pwned? and pass"
excerpt:    "posted on opensource.com"
date:       2019-06-24 09:30:00 +0100
categories:
  - Technology
tags:
  - Encryption
  - Security
  - Fedora
classes: wide
header:
  overlay_color: "#333"
---

<p>Periodically checking for password compromise is an excellent way to help ward off most attackers in most threat models.</p>

<p>Password security involves a broad set of practices, and not all of them are appropriate or possible for everyone. Therefore, the best strategy is to develop a threat model by thinking through your most significant risks—who and what you are protecting against—then model your security approach on the activities that are most effective against those specific threats. The Electronic Frontier Foundation (EFF) has a <a href="https://ssd.eff.org/en/module/your-security-plan" target="_blank">great series on threat modeling</a> that I encourage everyone to read.</p>

<p>In my threat model, I am very concerned about the security of my passwords against (among other things) <a href="https://en.wikipedia.org/wiki/Dictionary_attack" target="_blank">dictionary attacks</a>, in which an attacker uses a list of likely or known passwords to try to break into a system. One way to stop dictionary attacks is to have your service provider rate-limit or deny login attempts after a certain number of failures. Another way is not to use passwords in the "known passwords" dataset.</p>

<p>Read more over at <a href="https://opensource.com/article/19/6/check-passwords">opensource.com</a> where this was originally posted.</p>

<!--

<h2 id="check-password-security-with-hibp">Check password security with HIBP</h2>

<p><a href="https://www.troyhunt.com/" target="_blank">Troy Hunt</a> created <a href="https://haveibeenpwned.com/" target="_blank">Have I Been Pwned?</a> (HIBP) to notify people when their information is found in leaked data dumps and breaches. If you haven't already registered, you should, as the mere act of registering exposes nothing. Troy has built a collection of over 550 million real-world passwords from this data. These are passwords that real people used and were exposed by data that was stolen or accidentally made public.</p>

<p>The site <em>does not</em> publish the plaintext password list, but it doesn't have to. By definition, this data is already out there. If you've ever reused a password or used a "common" password, then you are at risk because someone is building a dictionary of these passwords to try right now.</p>

<p>Recently, Firefox and HIBP announced they are <a href="https://www.troyhunt.com/were-baking-have-i-been-pwned-into-firefox-and-1password/" target="_blank">teaming up</a> to make breach searches easier. And the National Institutes of Standards and Technology (NIST) recommends that you <a href="https://pages.nist.gov/800-63-FAQ/#q-b5" target="_blank">check passwords</a> against those known to be compromised and change them if they are found. HIBP supports this via a password-checking feature that is exposed via an API, so it is easy to use.</p>

<p>Now, it would be a bad idea to send the website a full list of your passwords. While I trust <a href="https://haveibeenpwned.com/" target="_blank">HaveIBeenPwned.com</a>, it could be compromised one day. Instead, the site uses a process called <a href="https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/" target="_blank">k-Anonymity</a> that allows you to check your passwords without exposing them. This is a three-step proces<span style="color:null;">s.&nbsp;First, let's review the steps, and then we can use the <strong>pass-pwned</strong> plugin to do it for us:</span></p>

<ol>
	<li>Create a hash value of your password.&nbsp;A hash value is just a way of turning arbitrary data—your password—into a fixed data representation—the hash value. A cryptographic hash function is collision-resistant, meaning it creates a unique hash value for every input. The algorithm used for the hash is a one-way transformation, which makes it hard to know the input value if you only have the hash value. For example, using the SHA-1 algorithm that HIBP uses, the password <strong>hunter2</strong> becomes <strong>F3BBBD66A63D4BF1747940578EC3D0103530E21D</strong>.</li>
	<li>Send the first five characters (<strong>F3BBB</strong>&nbsp;in our example) to the site, and the site will send back a list of all the hash values that start with those five characters. This way, the site can't know which hash values you are interested in. The k-Anonymity process ensures there is so much statistical noise that it is hard for a compromised site to determine which password you inquired about. For example, our query returns a list of 527 potential matches from HIBP.</li>
	<li>Search through the list of results to see if your hash is there. If it is, your password has been compromised. If it isn't, the password isn't in a publicly known data breach. HIBP returns a bonus in its data: a count of how many times the password has been seen in data breaches. Astoundingly, <strong>hunter2</strong> has been seen 17,043 times!</li>
</ol>

<h2 id="check-password-security-with-pass">Check password security with pass</h2>

<p>I use <a href="https://www.passwordstore.org/" target="_blank"><strong>pass</strong></a>, a <a href="https://gnupg.org/" target="_blank">GNU Privacy Guard</a>-based password manager. It has many extensions, which are available on the <a href="https://www.passwordstore.org/#extensions" target="_blank"><strong>pass</strong> website</a> and as a separately maintained <a href="https://github.com/tijn/awesome-password-store" target="_blank">awesome-style list</a>. One of these extensions is <a href="https://github.com/alzeih/pass-pwned" target="_blank"><strong>pass-pwned</strong></a>, which will check your passwords with HIBP. Both <strong>pass</strong> and <strong>pass-pwned</strong> are packaged for Fedora 29, 30, and Rawhide. You can insta<span style="color:null;">ll the extension </span>with:</p>

<pre><code class="language-bash">sudo dnf install pass pass-pwned</code></pre>

<p>or you can follow the manual instructions on their respective websites.</p>

<p>If you're just getting started with <strong>pass</strong>, read <a href="https://opensource.com/life/14/7/managing-passwords-open-source-way">Managing passwords the open source way</a> for a great overview.</p>

<p>The following will quickly set up <strong>pass</strong> and check a stored password. This example assumes you already have a GPG key.</p>

<pre><code class="language-bash"># Setup a pass password store
$ pass init &lt;GPG key email&gt;

# Add the password, "hunter2" to the store
$ pass insert awesome-site.com

# Install the pass-pwned extension
# Download the bash script from the upstream and then review it
$ mkdir ~/.password-store/.extensions
$ wget https://raw.githubusercontent.com/alzeih/pass-pwned/master/pwned.bash -O ~/.password-store/.extensions/pwned.bash
$ vim ~/.password-store/.extensions/pwned.bash

# If everything is OK, set it executable and enable pass extensions
$ chmod u+x ~/.password-store/.extensions/pwned.bash
$ echo 'export PASSWORD_STORE_ENABLE_EXTENSIONS="true"' &gt;&gt; ~/.bash_profile
$ source ~/.bash_profile

# Check the password
$ pass pwned awesome-site.com
Password found in haveibeenpwned 17043 times

# Change this password to something randomly generated and verify it
$ pass generate -i awesoem-site.com
The generated password for awesome-site.com is:
&lt;REDACTED&gt;
$ pass pwned awesome-site.com
Password not found in haveibeenpwned</code></pre>

<p>Congratulations, your password is now more secure than it was before! You can also <a href="https://github.com/alzeih/pass-pwned/issues/3" target="_blank">use wildcards to check multiple passwords</a> at once.</p>

<p>Periodically checking for password compromise is an excellent way to help ward off most attackers in most threat models. If your password management system doesn't make it this easy, you may want to upgrade to something like <strong>pass</strong>.</p>
-->
