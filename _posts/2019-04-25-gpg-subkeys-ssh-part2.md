---
title:      "How to import your existing SSH keys into your GPG key"
excerpt:  "posted on opensource.com"
date:       2019-04-25 13:15:00 +0100
categories:
  - Technology
tags:
  - Encryption
  - Security
  - Fedora
header:
  overlay_color: "#333"
---

<p>In the <a href="https://opensource.com/article/19/4/using-gpg-subkeys-ssh-part-1">first article</a> in this series, I explained how to use your GPG key to authenticate your SSH connections. If you're like me, you already have one or more existing SSH keys. And, if you're like me, you also don't want to have to log into every server you use to update the <strong>authorized_keys</strong> file. A way around this is to import your existing SSH keys into your GPG key. This will eliminate the need for private key files. Doing this has allowed me to eliminate nine other key files, reducing my backup/privacy footprint a lot.</p>

<p>Read more over at the <a href="https://opensource.com/article/19/4/gpg-subkeys-ssh-multiples">opensource.com</a> where this was originally posted.</p>


<!--

<h2 id="import-an-existing-ssh-key">Import an existing SSH key</h2>

<p>To add the key, you need to convert the key format from the Privacy-Enhanced Mail (PEM)-encoded format that SSH uses to an OpenPGP-formatted certificate. <a href="https://monkeysphere.info/" target="_blank">The Monkeysphere Project</a> provides a utility, <strong>pem2openpgp</strong>, that does this for you.</p>

<p>Unfortunately, making this newly added key a subkey is not a one-step process. This longer process is required because there is no clean way to delete the GPG key in the keyring that is just the SSH key. The keys are identified and operated on by keygrip, and the keygrip for a key is the same whether it is a subkey or a standalone key. Thankfully, you only need to work with the private keys, as you can regenerate the public keys at the end.</p>

<p>Also, if you have a newer style OpenSSH key, you'll have a couple of extra steps to convert that into something <strong>pem2openpgp</strong> can read. Unfortunately, as of version 0.41, Monkeysphere cannot read newer style OpenSSH keys. (Your key is a newer style key if the first line of the private key file is: <strong>-----BEGIN OPENSSH PRIVATE KEY-----</strong>. If your key starts with: <strong>-----BEGIN RSA PRIVATE KEY-----</strong>, then you have the PEM-encoded format.)</p>

<p>To import newer keys, you need to convert them into old-style formats. This is done by using <strong>ssh-keygen</strong> and taking advantage of its ability to write in multiple key formats. You can trigger the conversion by changing the password on the key. You don't have to change the password in this situation, so feel free to reuse your existing one if you prefer.</p>

<p>The workflow below walks us through these steps.</p>

<ol>
	<li>If you have a newer style OpenSSH key, convert it using the <strong>ssh-keygen</strong> utility. You can use this utility to change the password (if you want) and force the key to be rewritten in the older format. The only difference between a typical use of <strong>ssh-keygen</strong> and this one is the addition of <strong>-m</strong> to change the format of the key.

	<pre><code class="language-text">$ ssh-keygen -p -m PEM -f &lt;private-key-file&gt;</code></pre>
	</li>
	<li>Back up your existing GPG key.
	<pre><code class="language-text">$ gpg2 -a --export-secret-keys 96F33EA7F4E0F7051D75FC208715AF32191DB135 &gt; my_gpg_key.asc</code></pre>
	</li>
	<li>In a new keyring, import your existing GPG key.
	<pre><code class="language-text">$ mkdir temp_gpg
$ chmod go-rwx temp_gpg/
$ gpg2 --homedir temp_gpg --import my_gpg_key.asc 
gpg: key 8715AF32191DB135: public key "Brian Exelbierd" imported
gpg: key 8715AF32191DB135: secret key imported

# Optionally, verify the import
$ gpg2 -K --homedir temp_gpg/
/home/bexelbie/temp_gpg/pubring.kbx
--------------------------------
sec   rsa2048 2019-03-21 [SC] [expires: 2021-03-20]
      96F33EA7F4E0F7051D75FC208715AF32191DB135
uid           [ unknown] Brian Exelbierd
ssb   rsa2048 2019-03-21 [E] [expires: 2021-03-20]
ssb   rsa2048 2019-03-21 [A]</code></pre>
	</li>
	<li>Import the SSH key as a new standalone GPG key.
	<pre><code class="language-text"># get the software
$ dnf install -y monkeysphere

# temporary_id is a temporary identifier required by GPG
$ pem2openpgp temporary_id &lt; .ssh/my_fancy_key  | gpg2 --import --homedir temp_gpg/
Enter PEM pass phrase:
gpg: key 66091F2C70AF02A9: public key "temporary_id" imported
gpg: key 66091F2C70AF02A9: secret key imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1

# verify the key loaded and get the keygrip of the new GPG key and the hash of your GPG key
$ gpg2 -K --with-keygrip  --homedir temp_gpg/
/home/bexelbie/temp_gpg/pubring.kbx
--------------------------------
sec   rsa2048 2019-03-21 [SC] [expires: 2021-03-20]
      96F33EA7F4E0F7051D75FC208715AF32191DB135
      Keygrip = 90E08830BC1AAD225E657AD4FBE638B3D8E50C9E
uid           [ unknown] Brian Exelbierd
ssb   rsa2048 2019-03-21 [E] [expires: 2021-03-20]
      Keygrip = 5FA04ABEBFBC5089E50EDEB43198B4895BCA2136
ssb   rsa2048 2019-03-21 [A]
      Keygrip = 7710BA0643CC022B92544181FF2EAC2A290CDC0E

sec   rsa2048 2019-03-23 [C]
      D4F6B35B52B96A092FB8F418A41A06197749FBA4
      Keygrip = 1F824257B107D9E3371B9A4957751D78FC8BB190
uid           [ unknown] temporary_id

# We can remove monkeysphere unless you need it for other reasons
$ dnf remove -y monkeysphere</code></pre>
	</li>
	<li>Add the SSH key as a subkey of your GPG key.
	<pre><code class="language-text">$ gpg2 --homedir temp_gpg  --expert --edit-key 96F33EA7F4E0F7051D75FC208715AF32191DB135 
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
Your selection? 13
Enter the keygrip: 1F824257B107D9E3371B9A4957751D78FC8BB190

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
Please specify how long the key should be valid.
Key is valid for? (0) 
Key does not expire at all
Is this correct? (y/N) y
Really create? (y/N) y

sec  rsa2048/8715AF32191DB135
     created: 2019-03-21  expires: 2021-03-20  usage: SC  
     trust: unknown       validity: unknown
ssb  rsa2048/150F16909B9AA603
     created: 2019-03-21  expires: 2021-03-20  usage: E   
ssb  rsa2048/17E7403F18CB1123
     created: 2019-03-21  expires: never       usage: A   
ssb  rsa2048/4A9EE7790817C411
     created: 2019-03-23  expires: never       usage: A   
[ unknown] (1). Brian Exelbierd

gpg&gt; quit
Save changes? (y/N) y</code></pre>
	Notice there are now two authentication subkeys.</li>
	<li>Export your existing GPG key with the new subkey.
	<pre><code class="language-text">$ gpg2 --homedir temp_gpg -a --export-secret-keys 96F33EA7F4E0F7051D75FC208715AF32191DB135 &gt; my_new_gpg_key.asc</code></pre>
	</li>
	<li>Import your existing GPG key with the new subkey into your customary keyring (only the subkey will import).
	<pre><code class="language-text">$ gpg2 --import my_new_gpg_key.asc 
gpg: key 8715AF32191DB135: "Brian Exelbierd" 1 new signature
gpg: key 8715AF32191DB135: "Brian Exelbierd" 1 new subkey
gpg: key 8715AF32191DB135: secret key imported
gpg: Total number processed: 1
gpg:            new subkeys: 1
gpg:         new signatures: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
gpg:  secret keys unchanged: 1

# verify the input and get the keygrip (it should be the same)
$ gpg2 -K --with-keygrip 
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
ssb   rsa2048 2019-03-23 [A]
      Keygrip = 1F824257B107D9E3371B9A4957751D78FC8BB190</code></pre>
	</li>
	<li>Optionally, you may want to pre-specify that this key is to be used for SSH. This means you will not have to use <strong>ssh-add</strong> to load the key. To do this, specify the keys in the <strong>~/.gnupg/sshcontrol</strong> file. The entries in this file are keygrips.
	<pre><code class="language-text">~/.gnupg/sshcontrol file.  The entries in this file are key grips

# Add the new keygrip to your sshcontrol file
$ echo 1F824257B107D9E3371B9A4957751D78FC8BB190 &gt;&gt; ~/.gnupg/sshcontrol</code></pre>
	</li>
</ol>

<h2 id="success">Success!</h2>

<p>You can now delete the old SSH private key file. When you attempt to SSH into the appropriate servers, you will be prompted to unlock your GPG key (it better have a password!), then <strong>gpg-agent</strong> will provide the authentication in place of <strong>ssh-agent</strong>. You have fewer files to keep securely backed up and your key management is a bit easier. If you ever need a new key, you can follow the directions in the <a href="https://opensource.com/article/19/4/using-gpg-subkeys-ssh-part-1">previous article</a> to create more authentication subkeys. If the project you're working on ends, you can always delete any extra subkeys you wind up with.</p>

<p>In the third and final article, I will share some tips for managing multiple authentication subkeys/SSH keys. Once you have more than two or three, it gets a bit more complicated.</p>


-->
