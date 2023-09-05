---
date: 2023-09-05 10:41:00 +0200
title: "rsync+iCloud: A proposal"
excerpt: This is all Apple's fault but we can make it work
categories:
  - Technology
tags:
  - Coding
---

Despite Apple not always having the best track record on service availability (it has gotten WAY better over the years), I remain impressed by iCloud Drive[^1].  If you're not familiar with it, it is a selectively caching cloud file system.  I am sure there is a fancy term for this that I don't know, if you do email me.

The gist of it is this.  When you put a file in your iCloud Folder, it gets copied to an Apple storage server somewhere.  Over time, based on use or available disk on your system it may get evicted (removed) from your system.  In it's place is a "bookmark" file that the system understands as a representation of your file.  That bookmark allows you to still have access to metadata about your file, all without having to have the file itself taking up space on your drive.  If you need the file, attempting to open it will cause it to be downloaded.  This is file synchronization on steroids.

Where this whole concept falls apart is backups.  Nobody's backup programs, including Apple's own Time Machine, can backup evicted files.  This means that when you back up your system you aren't really backing up all of your files.

![[/img/2023/adam-rsync.png]]

As my friend Adam points out, synchronization is not the same as backup.  I want both.  Therefore I wrote a song:

> 🎶I'd like to teach rsync to sync with iCloud Drive seamlessly
> I'd like to have a complete backup of my Mac you see[^2]🎶

Rsync is "a fast, versatile, remote (and local) file-copying tool." It ships on most Linuxes and on MacOS by default.  "Rsync finds files that need to be transferred using a 'quick check' algorithm (by default) that looks for files that have changed in size or in last-modified time" For more, [read the man page](https://download.samba.org/pub/rsync/rsync.1).

iCloud Drive preserves access to the required metadata.  Here is an abbreviated output from `mdls` of an evicted file[^3] :

```
 % mdls .1998-tax-return.pdf.icloud
kMDItemContentCreationDate         = 2018-08-28 18:32:24 +0000
kMDItemContentCreationDate_Ranking = 2021-11-05 00:00:00 +0000
kMDItemContentModificationDate     = 2018-08-28 18:32:24 +0000
kMDItemDateAdded                   = 2021-11-05 15:42:15 +0000
kMDItemDisplayName                 = "1998-tax-return.pdf"
kMDItemFSContentChangeDate         = 2018-08-28 18:32:24 +0000
kMDItemFSCreationDate              = 2018-08-28 18:32:24 +0000
kMDItemFSSize                      = 1929932
kMDItemInterestingDate_Ranking     = 2018-08-28 00:00:00 +0000
kMDItemLogicalSize                 = 1929932
kMDItemPhysicalSize                = 1929932
```

This metadata, I think, is enough to pass the rsync quick check described above.  Most of the values are [documented on the Apple Developer site](https://developer.apple.com/documentation/coreservices/kmditemfscontentchangedate).

I suspect what needs to happen, from a code perspective, is that rsync needs to be modified to do the following when it finds an evicted file.  All evicted files are named consistently, `.<filename>.icloud` so they are easy to spot.

1. Perform the system call equivalent of the `mdls` above to obtain the appropriate dates and sizes.
2. If the file cannot be skipped because it either has changed or a checksum is required, perform the system call equivalent of `brctl download <filename>` to get the file downloaded.
3. Send the file
4. If the file was downloaded, perform the system call equivalent of `brctl evict <filename>` to remove the file to leave the system in the same state.

This simplistic algorithm would leave some open issues/caveats:
- It is likely that the rsync can only be run one-way from iCloud Drive to non-iCloud Drive data storage.  While it is possible it could be run two-way research is needed on whether you'd have to download the old file before you replace it.
- Timeouts may happen.  iCloud Drive still gets stuck sometimes and there will be non-zero time during downloads that don't get stuck.
- There is no guarantee there is ever enough room on disk to hold a specific file from iCloud Drive.  This is likely resolved by MacOS directly, however, this may take excessive time.
- If you thought running with checksums was slow before, strap in, because those downloads are going to add up.

All that said, I feel like this algorithm gets me to a better situation overall.  I am not in a position where I expect it to be common for files to be modified without having their size changed or their various dates updated.

I haven't written C code since college, but I can't help but wonder how hard this would be.  

[^1]: Dropbox can do this too.  Likely others can as well.  iCloud Drive's real win is in how it is fully integrated into the OS.
[^2]: With apologies to Coke and many many others
[^3]: Choosing a tax return is so on brand for me, it hurts.