---
title:      "How to enable SSH access using a GPG key for authentication"
excerpt:  "posted on opensource.com"
date:       2019-04-24 16:45:00 +0100
categories:
  - Technology
tags:
  - Encryption
  - Security
  - Fedora
header:
  overlay_color: "#333"
---

<p>Many of us are familiar with Secure Shell (SSH), which allows us to connect to other systems using a key instead of a password. This guide will explain how to eliminate SSH keys and use a GNU Privacy Guard (GPG) subkey instead.</p>

<p>Using GPG does not make your SSH connections more secure. SSH is a secure protocol, and SSH keys are secure. Instead, it makes certain forms of key distribution and backup management easier. It also will not change your workflow for using SSH. All commands will continue to work as you expect, except that you will no longer have SSH private keys and you will unlock your GPG key instead.</p>

<p>Read more over at the <a href="https://opensource.com/article/19/4/gpg-subkeys-ssh">opensource.com</a> where this was originally posted.</p>

<!--

<p>By having SSH authenticated by your GPG key, you will reduce the number of key files you need to secure and back up. This means that your key management hygiene still has to be good, which means choosing good passphrases and using appropriate key preservation strategies. Remember, you shouldn't back your private key up to the cloud!</p>

<p>Additionally, today SSH keys are distributed by hand and oftentimes directly. If you want to grant me access to a machine, you have to ask me for my SSH key. You may get lucky and find one posted on my website. However, you still have to decide if you trust my website. If I use a GPG key for SSH, you can select a known, good key for me using the GPG web of trust from a public keyserver. This is what <a href="https://monkeysphere.info/" target="_blank">The Monkeysphere Project</a> is working on. Otherwise, nothing you do here affects the web of trust used for GPG encryption and signing.</p>

<h2 id="what-is-a-gpg-subkey">What is a GPG subkey?</h2>

<p>A GPG key is actually a collection of keys. There is one primary key, which is typically used only for signing and certification. The suggested usage of GPG is to create a subkey for encryption. This subkey is a separate key that, for all intents and purposes, is signed by your primary key and transmitted at the same time. This practice allows you to revoke the encryption subkey on its own, such as if it becomes compromised, while keeping your primary key valid.</p>

<p>The important thing to realize is that a GPG key contains multiple keys. For backup and storage purposes, you can operate them as though they are one key, but when it is time to use a key, you can use them independently.</p>

<p>This exercise will use a subkey that has been created for authentication to complete SSH connections. This authentication subkey will completely replace the keypair you may have generated in the past with <strong>ssh key-gen</strong>. You can create as many of these as you want if you need multiple SSH keys.</p>

<h2 id="create-an-authentication-subkey">Create an authentication subkey</h2>

<p>You should already have a GPG key. If you don't, read one of the many <a href="https://docs.fedoraproject.org/en-US/quick-docs/create-gpg-keys/" target="_blank">fine tutorials</a> available on this topic. You will create the subkey by editing your existing key. You need to edit your key in expert mode to get access to the appropriate options.</p>

<p>The workflow adds a new key where you can choose its capabilities—specifically, you want to toggle its capabilities to just have authentication. SSH typically uses a 2048-bit RSA key that does not expire (type 8 in the options below).</p>

<p>Below is an edited version of the workflow. This and all other commands were tested on Fedora 29.</p>

<pre><code class="language-text">$ gpg2 --expert --edit-key &lt;KEY ID&gt;
gpg&gt; addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
Your selection? 8

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: Sign Encrypt 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? s
Your selection? e
Your selection? a

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: Authenticate 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 
Requested keysize is 2048 bits
Please specify how long the key should be valid.
         0 = key does not expire
      &lt;n&gt;  = key expires in n days
      &lt;n&gt;w = key expires in n weeks
      &lt;n&gt;m = key expires in n months
      &lt;n&gt;y = key expires in n years
Key is valid for? (0) 
Key does not expire at all
Is this correct? (y/N) y
Really create? (y/N) y

sec  rsa2048/8715AF32191DB135
     created: 2019-03-21  expires: 2021-03-20  usage: SC  
     trust: ultimate      validity: ultimate
ssb  rsa2048/150F16909B9AA603
     created: 2019-03-21  expires: 2021-03-20  usage: E   
ssb  rsa2048/17E7403F18CB1123
     created: 2019-03-21  expires: never       usage: A   
[ultimate] (1). Brian Exelbierd

gpg&gt; quit
Save changes? (y/N) y</code></pre>

<h2 id="enable-the-gpg-subkey">Enable the GPG subkey</h2>

<p>When you use SSH, a program called <strong>ssh-agent</strong> is used to manage the keys. To use a GPG key, you'll use a similar program, <strong>gpg-agent</strong>, that manages GPG keys. To get <strong>gpg-agent</strong> to handle requests from SSH, you need to enable support by adding the line <strong>enable-ssh-support</strong> to the <strong>~/.gnupg/gpg-agent.conf</strong>.</p>

<pre><code class="language-text">$ cat .gnupg/gpg-agent.conf 
enable-ssh-support</code></pre>

<p>Optionally, you may want to pre-specify the keys to be used for SSH so you won't have to use <strong>ssh-add</strong> to load the keys. To do this, specify the keys in the <strong>~/.gnupg/sshcontrol</strong> file. The entries in this file are <em>keygrips</em>—internal identifiers <strong>gpg-agent</strong> uses to refer to keys. Unlike a key hash, a keygrip refers to both the public and private key. To find the keygrip, use <strong>gpg2 -K --with-keygrip</strong>, as shown below. Then add that line to the <strong>sshcontrol</strong> file.</p>

<pre><code class="language-text">$ gpg2 -K --with-keygrip 
/home/bexelbie/.gnupg/pubring.kbx
------------------------------
sec   rsa2048 2019-03-21 [SC] [expires: 2021-03-20]
      96F33EA7F4E0F7051D75FC208715AF32191DB135
      Keygrip = 90E08830BC1AAD225E657AD4FBE638B3D8E50C9E
uid           [ultimate] Brian Exelbierd
ssb   rsa2048 2019-03-21 [E] [expires: 2021-03-20]
      Keygrip = 5FA04ABEBFBC5089E50EDEB43198B4895BCA2136
ssb   rsa2048 2019-03-21 [A]
      Keygrip = 7710BA0643CC022B92544181FF2EAC2A290CDC0E

$ echo 7710BA0643CC022B92544181FF2EAC2A290CDC0E &gt;&gt; ~/.gnupg/sshcontrol</code></pre>

<p>Last, you need to tell SSH how to access the <strong>gpg-agent</strong>. This is done by changing the value of the <strong>SSH_AUTH_SOCK</strong> environment variable. The following two lines, when added to your <strong>~/.bashrc</strong>, will ensure the variable is set correctly and that the agent is launched and ready for use.</p>

<pre><code class="language-text">$ cat ~/.bashrc
...
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
...</code></pre>

<p>To continue, execute those commands in your current session.</p>

<h2 id="share-your-ssh-key">Share your SSH key</h2>

<p>In order to use SSH, you need to share your public key with the remote host. You have two options. First, you can run <strong>ssh-add -L</strong> to list your public keys and copy it manually to the remote host. You can also use <strong>ssh-copy-id</strong>. From this perspective, nothing has changed.</p>

<h2 id="congratulations">Congratulations!</h2>

<p>You have now enabled SSH access using a GPG key for authentication! SSH will continue to work as expected, and the machines you are connecting to won't need any configuration changes. You've reduced the number of key files you need to manage and securely back up while simultaneously enabling the opportunity to take part in different forms of key distribution. Stay safe and practice good key hygiene!</p>

<p>In the next article, I will share some tips on how to import your existing SSH keys so you can continue to use them, but with GPG authentication.</p>

-->
