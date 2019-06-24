
# 

Matthew Broberg wrote a great article about [storing your dotfiles in version control](https://opensource.com/article/19/3/move-your-dotfiles-version-control). In it her points out that there some dotfiles that contain items you shouldn't share, such as anything that is a security risk, such as your SSH private keys, or files that may contain API tokens or hostnames that are non-public meta-data items (i.e. part of an alias in your .bashrc).  In a previous post, I showed you how to [eliminate your SSH private keys](XXXXXXXXXXXXXLINK), however that only gets rid of some of the information you shouldn't share.  Today, we are going to learn how to encrypt the other information so we can push it to our sharing repository so we can get full value from that repository.  Before you get started, you should make sure your have followed Matthew's advice and have a working dotfile repository.

In order to add this new data, we are going to follow these general steps:

1. Setup an encrypted filestore in the dotfile repository.
2. Move the dotfiles that need to be secured into the filestore.
3. Setup our repository to only store the encrypted copy of the dotfiles.
4. Unlock the dotfiles when we login.

There are, of course, a few caveats you should be aware of.  First, think carefully about what you put in the encrypted filestore.  The dotfile will not be available until your graphical login has completed.  This shouldn't be an issue for most files, but your mileage may vary.  Second, also make sure you don't create a "chicken and egg" problem for yourself.  If you put your password manager's files in the encrypted filestore that means you have to know the filestore password in order to get to your other passwords.  Don't create a lock that guards the key!  Third, there is a school of thought that says you should never store a secret, even an encrypted one in a public repository.  I personally do not believe that rule applies here because the encryption requires both a passphrase and a key.  At some point you have to trust your encryption.  However, I am not a security expert and am definitely not your security expert.  Lastly, I am doing all of this on Fedora Workstation (specifically the current release, Fedora 29) and using git as my version control system.  All of this should work on any Linux system and most likely MacOS as well.

## Setup an encrypted filestore

For our encrypted filestore we are going to use [gocryptfs](https://nuetzlich.net/gocryptfs/).  gocryptfs is the successor to encfs and advances the concept.  Importantly, it has both [had a security audit](https://nuetzlich.net/gocryptfs/threat_model/#gocryptfs-audit) and fixes a design flaw of encfs.  You should review the [threat model](https://nuetzlich.net/gocryptfs/threat_model/) to ensure it meets your use case.

gocryptfs leverages [Linux FUSE (Filesystem in Userspace)](https://github.com/libfuse/libfuse) to create a mount of the encrypted files in plain form.  Once this mount is made, you can operate on the files just like they weren't encrypted and the changes will be transparently made in real time on the encrypted copy.



2. Move the dotfiles that need to be secured into the filestore.
3. Setup our repository to only store the encrypted copy of the dotfiles.
4. Unlock the dotfiles when we login.




why doesn't systemd have a "graphical user login session started" target?

https://naftuli.wtf/2017/12/28/systemd-user-environment/ - hint
 - autostart
 - target
 - gocryptfs mounter
/home/bexelbie/bin/gocryptfs -extpass "zenity --password --title 'goCr  yptFS pass'" /home/bexelbie/cipher /home/bexelbie/plain
