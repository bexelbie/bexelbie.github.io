---
title: "Building a tiny ephemeral draft sharing system on Hedgedoc"
date: 2026-02-12 13:00:00 +0100
excerpt: "How I'm using Hedgedoc on a tiny VM to share markdown drafts for feedback without heavyweight doc tools."
---

> This yak is now shaved!
>
> <cite>me</cite>

I've been working on two submissions I want to put into the CFP for [installfest.cz](https://installfest.cz) and had them at a "man it'd be nice to have someone else read and comment on this" level of done.  Normally when this happens I have to psych myself up for it, both because receiving feedback can be hard and because I have to do a format conversion.  I tend to write in markdown in "all the places" and sharing a document for edits has typically meant pasting it into something like Google Docs or Office 365, where even if it still looks like markdown ... it isn't.

And that's when the yak walked into the room. Instead of just pasting my drafts into Google Docs and getting on with the reviews, I decided I needed to delay getting feedback and build the markdown collaborative editing system of my dreams. Classic yak shaving - solving a problem you don't actually need to solve in order to eventually do the thing you originally set out to do. [What is Yak Shaving](https://www.youtube.com/watch?v=0E5ae4MD5qo) - a video by Matthew Miller if you're unfamiliar.

When I am done, I then have to take this text back to where it was originally going, often in good clean markdown (this blog post is in markdown!).  This rigmarole is tiring.  I also dislike that the go to tools for this for me had turned into an exercise in ensuring guests could access a document or collecting someone's login ids to yet another system.

I knew there had to be a better way.  Then it hit me.  When markdown started to take off we had a slew of markdown collaborative editing sites take off.  They were often modeled on the older etherpad.  Well, several are still around.  I looked at online options as I tend to prefer using a service when I can so I don't get more sysadmin work to do.  

I hit three snags in picking one:

1. I don't like being on a free tier when I don't understand how it is supported.  While I don't know that anyone in this space is nefarious, the world is trending in a specific direction.  I don't mind paying, but this was also not going to generate enough value to warrant serious payments.
2. The project that first came to mind for markdown collaboration went open core back in 2019.  Open source business models are hard, and doing open core well is even harder.  As you'll see below I had specific needs and I had a feeling I might run into the open core wall.
3. One of the CFPs would actually benefit from implementing this as my example ... bonus!

After examining a bunch of options, I settled on building something out of [Hedgedoc](https://hedgedoc.org). This was not an easy choice and the likelihood of entering analysis paralysis was super high.  So I decided to try to force this to fit on a free tier Google GCP instance I have been running for years.  It is the tiny e2-micro burstable instance, a literal thimble of compute.

This ran off a lot of options.  Privacy first options need more compute just to do encryption work.  A bunch of options want a server database (Postgres and friends) and a single person instance should be fine on SQLite, in my opinion.  All roads now ran to Hedgedoc.  It was the only option that could run on SQLite, tolerate my tiny VM, still give me collaborative markdown, and seemed to have every feature required if I could make it work.

It wasn't all sunshine and happiness though.  Hedgedoc is in the middle of writing version 2.0, which means 1.0 is frozen for anything except critical fixes and all efforts are focused on the future.  Therefore, the documentation being a bit rough in places was something I was going to have to live with.  

My core requirements were:
1. Only I am allowed to create new notes
2. Anyone with the "unguessable" url can edit and should not require an account to do so
3. This should require next to zero system administration work and be easy to start and stop
4. When I need more features, I should be able to extend this with a plugin for tools like [Obsidian](https://obsidian.md) or Visual Studio Code.

And while it took longer than I'd hoped, it works.  Here's how:

1. Write yourself a configuration file for Hedgedoc

config.json:
```
{
  "production": {
    "sourceURL": "https://github.com/bexelbie/hedgedoc",
    "domain": "<url>",
    "host": "localhost",
    "protocolUseSSL": true,
    "loglevel": "info",
    "db": {
      "dialect": "sqlite",
      "storage": "/data/db/hedgedoc.sqlite"
    },
    "email": true,
    "allowEmailRegister": false,
    "allowAnonymous": false,
    "allowAnonymousEdits": true,
    "requireFreeURLAuthentication": true,
    "disableNoteCreation": false,
    "allowFreeURL": false,
    "enableStatsApi": false,
    "defaultPermission": "limited",
    "imageUploadType": "filesystem",
    "hsts": {
      "enable": true,
      "maxAgeSeconds": 31536000,
      "includeSubdomains": true,
      "preload": true
    }
  }
}
```

This sets a custom source URL for the fork I have made (more below), enables SSL, disables new account registration, and allows edits via unguessable URLs without requiring logins.

2. Decide how you want to launch the container, I am using a quadlet, and provide some environment variables:

```
CMD_SESSION_SECRET="<secret>"
CMD_CONFIG_FILE=/hedgedoc/config.json
NODE_ENV=production
```

These just put it in Production mode, point it at the config and provide the only secret required.

3. You're basically done.  I happen to have put mine behind a Cloudflare tunnel and updated the main page of the site, but those are pretty straight forward.

## More Yak Shaving

Naturally I planned to launch it, create my user id via the cli, and share my CFP submissions with the folks I wanted reviews from.
Narrator: Naturally, that's not what happened.

I decided to push YAGNI[^1] out of the way and NEED IT!  Specifically I forked the v1 code into [a repository](https://github.com/bexelbie/hedgedoc/) to add some features.  The upstream is unlikely to want any of these so I will have to carry these patches.  What I did:

1. Hedgedoc will do color highlighting and gutter indicators so you can see which author added what text.  Unfortunately it wasn't seeming to be working.  I was getting weak indicators (underlines instead of highlighting) and often nothing.  So I fixed that.
2. The colors for authorship are chosen randomly.  I am a bit past my prime in the seeing department and it was hard to see the colors against the dark editor background, so I restricted color choices to those that are contrasting.  It isn't perfect, but it is better.
3. My particular set up involves a lot of guest editors.  Normally I share to just a few folks, but sometimes to many.  They'll all be anonymous.  Hedgedoc doesn't track authorship colors for guests, so I patched in a system to generate color markings for anonymous editors.
4. A feature I always loved in Etherpad was that you could temporarily hide the authorship colors when you just wanted to "read the document."  So I added a button for that.  While I was doing that I discovered that there is a separate toggle to switch the editor into light mode, but I couldn't see it because the status bar was black and it was set to .2 opacity!! I fixed that too.  Also, now the status bar switches when the editor switches.
5. Comments, it turns out are needed.  So I coded in rudimentary support for critic markup comments.

I have other ideas, but instead I am going to stop and let YAGNI win for a while.  Besides, hopefully 2.0 will ship soon and render all of this unneeded.

So there you go, now if you want to offer your assistance to help me write something, I'll send you a link and you can go to town on our shared work.  If you want to see more about this, well, let's see if Installfest.cz thinks you should or not :D — and whether this yak decides to grow its hair back.

[^1]: YAGNI: You Ain't Gonna Need It - a philosophy that reminds us that features we dream up aren't needed until an actual use comes along (or a paying customer).  This also applies to engineering for future ideas when those ideas aren't committed too yet.
