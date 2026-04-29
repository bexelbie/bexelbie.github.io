---
title:      "How to manage multiple SSH keys"
excerpt:  "posted on opensource.com"
date:       2019-04-26 16:35:00 +0200
categories:
  - Technology
tags:
  - Encryption
  - Security
  - Fedora
entry_type: article
status: delivered
speaking_event: "opensource.com"
speaking_date: 2019-04-26
speaking_links:
  external: "https://opensource.com/article/19/4/gpg-subkeys-ssh-manage"
header:
  overlay_color: "#333"
---

<p>In the first two articles in this series, I shared how you can <a href="https://opensource.com/article/19/4/using-gpg-subkeys-ssh-part-1">use your GPG key</a> to authenticate your SSH connections and <a href="https://opensource.com/article/19/4/using-gpg-subkeys-ssh-part-2">import existing SSH keys</a>. Once you're using more than two or three SSH keys, managing them can become more complicated. In this final article, I'll explain how to manage multiple SSH keys using the control file and how to make changes to manage them as GPG authentication subkeys. I'll also show how to identify your GPG authentication keys in case they've built up over time and you haven't kept notes.</p>

<p>Read more over at the <a href="https://opensource.com/article/19/4/gpg-subkeys-ssh-manage">opensource.com</a> where this was originally posted.</p>

<!--

<h2 id="why-have-more-than-one-ssh-key">Why have more than one SSH key?</h2>

<p>If you think about SSH keys like you would physical keys, you'll start to see reasons to have more than one key. You wouldn't want to have your car and your house on the same key. If your key gets stolen, the thief has access to everything. Much like your car and house, you may want to have separate keys for each project, use case, or aspect of your life.</p>

<p>Having multiple keys can also be useful when you are doing work for clients. Some clients may give you a specific key to use and others may require you to hand over all accounts, passwords, and keys at the end of the project.</p>

<h2 id="how-does-ssh-manage-multiple-keys">How does SSH manage multiple keys?</h2>

<p>Once you have more than a couple of SSH keys, you discover that you need to add <strong>IdentifyFile</strong> lines to your <strong>~/.ssh/config</strong> to get SSH to offer the right key to the right server. This is because&nbsp;most servers will disconnect after only a few SSH key attempts. I have seven keys, so I definitely need this.</p>

<p>For example, this entry specifies that when I use machines in the Fedora Project, my user name is "bex" and I want my Fedora SSH key to be used. The referenced file is the private key file.</p>

<pre><code class="language-text">Host *.fedoraproject.org
    User bex
    IdentityFile ~/.ssh/fedora_id_rsa</code></pre>

<p>Without the <strong>IdentifyFile</strong> keyword, SSH would just try each key serially.</p>

<h2 id="teach-ssh-to-manage-multiple-gpg-authentication-keys">Teach SSH to manage multiple GPG authentication keys</h2>

<p>When you use GPG to authenticate SSH, you no longer have private key files. Therefore, the configuration above won't work anymore. In order to get this working, you have to do something different to identify the key that should be used. Thankfully, SSH provides a workaround: You can reference the public key on the <strong>IdentifyFile</strong> line instead.</p>

<p>Just modify your <strong>~/.ssh/config</strong> to reference the proper public key. Typically, this is as easy as adding <strong>pub</strong> to the end of each <strong>IdentifyFile</strong> line. Don't forget to make sure that the public key file is set as user readable only.</p>

<p>This means you will need to have public key files available for your authentication keys. If you didn't save them (or have them before), you can get the fingerprints from the <strong>ssh-add -L</strong> command.</p>

<h2 id="identify-specific-authentication-subkeys">Identify specific authentication subkeys</h2>

<p>Once you have created more than a few authentication subkeys, you'll want to be able to identify them so that you can give the right public keys to the right servers and make the proper <strong>IdentifyFile</strong> entries. Unfortunately, GPG doesn't support comments or names for subkeys. Therefore, you can only get a list of key hashes and grips from the <strong>gpg2</strong> command and an unmatched set of private and public fingerprints from <strong>ssh-add</strong>.</p>

<p>There are two ways to identify your keys. You can start from the SSH public key fingerprint and find the GPG keygrip, or you can start from the GPG subkey hash and find the SSH public key fingerprint.</p>

<h3 id="ssh-public-key-fingerprint-to-gpg-keygrip">SSH public key fingerprint to GPG keygrip</h3>

<p>Start by finding the public key fingerprint you want to identify. You can do this by running <strong>ssh-add -L</strong>. This example works with the first fingerprint. Save the public key fingerprint to a file, as the next step requires this.</p>

<pre><code class="language-text">$ ssh-add -L | head -1 &gt; key</code></pre>

<p>Now you need the MD5 format of the SSH fingerprint, which you can get from <strong>ssh-keygen</strong>.</p>

<pre><code class="language-text">$ ssh-keygen -l -E md5 -f key
2048 MD5:9e:98:82:87:5d:a4:fe:e3:8a:9c:db:aa:59:5b:30:ac (none) (RSA)</code></pre>

<p>Match the MD5 SSH fingerprint with the keys, as displayed by the <strong>keyinfo</strong> command of the <strong>gpg-agent</strong>.</p>

<pre><code class="language-text">$ gpg-connect-agent 'KEYINFO --list --ssh-fpr' /bye | fgrep
9e:98:82:87:5d:a4:fe:e3:8a:9c:db:aa:59:5b:30:ac
S KEYINFO 9EEA76057C168686EAE8B807845326D7F60FB1C4 D - - - P
MD5:9e:98:82:87:5d:a4:fe:e3:8a:9c:db:aa:59:5b:30:ac - -</code></pre>

<p>This returns multiple fields of data. The important one is the third element, which is the GPG keygrip. From here, it is easy to identify your specific authentication subkey using <strong>gpg2 -K --with-keygrip</strong>.</p>

<h3 id="gpg-subkey-hash-to-ssh-public-key-fingerprint">GPG subkey hash to SSH public key fingerprint</h3>

<p>Start by finding the subkey hash for the key you want to identify. You can do this by running <strong>gpg2 -K --with-subkey-fingerprint</strong>.</p>

<pre><code class="language-text">$ gpg2 -K --with-subkey-fingerprint
...
ssb   rsa2048 2019-03-16 [A]
      941BE28372F6759AB7073766E0A70B46BA68E808</code></pre>

<p>Converting this into a public key fingerprint is really easy; just use <strong>gpg2</strong> again.</p>

<pre><code class="language-text">$ gpg2 --export-ssh-key 941BE28372F6759AB7073766E0A70B46BA68E808
ssh-rsa AAAAB3NzaC1yc...MQJ3FK3 openpgp:0xBA68E808</code></pre>

<p>You'll notice that there is a comment, <strong>openpgp:0xBA68E808</strong>, in this output. This is not guaranteed in all cases, as it depends on exactly how you are using GPG. If your output includes it, it's an easy way to identify the GPG key and SSH fingerprint relationship; however you shouldn't rely on it always being available.</p>

<p>I encourage you to consider documenting the relationships in your <strong>.gnupg/sshcontrol</strong> file or as comments in your public key files.</p>

<h2 id="wrapping-up">Wrapping up</h2>

<p>Now you're ready to get access to every server in the world using a GPG-authenticated SSH session. You can manage multiple keys and, when needed, identify them. You've reduced your secure backup needs to a single key file, which you can use to unlock or decrypt everything else.</p>

-->
