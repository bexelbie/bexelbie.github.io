---
marp: true
theme: flatcar
paginate: true
---

<!-- _class: cover -->
<!-- _paginate: false -->

# systemd-sysext in Production

## What We Learned Extending `/usr` Without a Package Manager

<div style="display:flex; gap:60px; margin-top:8px;">
<div><strong>Brian "bex" Exelbierd</strong> &nbsp;·&nbsp; bex@bexelbie.com<br>Principal Product Manager, Microsoft Azure<br>Upstream Linux</div>
<div><strong>Daniel Zaťovič</strong> &nbsp;·&nbsp; daniel.zatovic@gmail.com<br>Software Engineer, Microsoft Azure<br>Flatcar Engineering</div>
</div>

&nbsp;
DevConf.CZ &nbsp;·&nbsp; June 18, 2026 &nbsp;·&nbsp; Brno

<img src="assets/microsoft-logo.svg" alt="Microsoft" style="position: absolute; bottom: 50px; left: 70px; height: 120px;" />

<!--
-  intro
-->

---

<!-- _class: quote -->
<!-- _paginate: false -->

> I've got 99 problems
> and they're all packaging

- Jay-Z in his Linux Admin Days

<!-- bex
- I want to start with a frustration.
- Every distro, every immutable OS, every cloud-native platform — they all eventually trip over the same problem: "how do I get this binary onto that host in a way I can update and roll back without breaking everything else."
- This is the oldest problem in our industry and we keep inventing new answers to it.
- That's not a complaint. It's a setup.
-->

---

<!-- _class: lead -->
<!-- _paginate: false -->

# ... and now there are 15 standards

![h:400](assets/xkcd-927-standards.png)

<!-- bex
- Having lots of standards isn't actually bad.  Standards make some problems easier, often at the expense of making others harder.  You have to decide which problems matter to you.
- sysext is one of those standards. We are not going to pretend it makes the problem go away.
- What we ARE going to tell you is when it's the right one — and what we've learned shipping it in production for two and a half years.
-->

---

<!-- _class: agenda -->

# Agenda

- Why we needed sysext
- What sysext actually is
- How Flatcar ships it in production
- Live demo
- What broke, what we fixed
- What we ship
- When to reach for sysext
- Try it today

<!-- bex
This is what we're going to talk about today
-->

---

# We built an immutable OS — on purpose

Flatcar (and CoreOS before it) made a design decision: **the OS image is a signed and read-only.**

- `/usr` is immutable and dm-verity protected
- no package manager on the host
- every node in the fleet is **bit-identical**, reproducible and defined at *provisioning*
- avoids configuration drift
- updates are **atomic A/B** — whole-image, auto-rollback, no half-patched states
- single-purpose OS - provide just enough to run containers

You **can't** tweak the OS in place, it's a value proposition not a bug.

<!-- Daniel
- Start with the design.
- Treat the OS like firmware/adapter to run cintainers (flatcar carrying containers).
- Read-only /usr, verity, atomic updates, no rpm/dpkg on the host.
- This is great for security and for running a fleet — every machine is the same machine.
-->

---

# ... but we still needed to change some parts on the fly

The one part of the OS users most need to **control** is the container runtime.

- the most common exmple is contaner runtime
    - "Pin Docker to a specific version and hold it there while the OS keeps updating"
    - "Run one Docker version on these nodes, a different one on those"
    - "We don't want Docker at all — ship **containerd** only"
    - "We need **podman** / a newer **runc** / a different container runtime"
- ship GPU specific drivers and container runtimes for GPU workloads

A frozen `/usr` can't do any of that.

<!-- Daniel
- But it causes a problem: the thing people most want to change is sitting inside the part we froze.
- various requirements regarding container runtime
- All of that is userspace that lives in /usr — exactly where we don't allow changes.
- So we needed a way to make a few specific, OS-adjacent components swappable without giving up immutability everywhere else.
-->

---

# Our first answer: Torcx

**Torcx** — a boot-time addon manager (CoreOS heritage) that let you pick your Docker / containerd / runc.

- At build time, the real binaries were replaced with **symlinks to nowhere**
- At boot, the Torcx image was fetched, unpacked, and the symlinks were rewired — *magic*
- Non-standard paths → **couldn't reuse upstream Gentoo ebuilds**; invasive build-time hooks
- Updating meant a **manifest change** → re-provision or in-place edits → config drift
- Images were **frozen after build** — you couldn't add or modify one

Bespoke, brittle, and worse **Flatcar-only**. We get to build it ... alone ... forever.

<!-- Daniel
- Torcx did the job for years, and it's our origin story for sysext.
- At build we baked symlinks-to-nowhere; at first boot Torcx downloaded an image, extracted it, and pointed the symlinks at the right place. That's the "magic" we wanted to kill.
- It was custom tooling end to end — special packaging, non-standard paths so we couldn't reuse upstream ebuilds, a manifest you had to edit, images you couldn't change after build.
- Hard to maintain, hard to version, hard to update, and nobody else in the industry shared the burden. That last part matters for the next slide.
- Removed almost 3 years ago (in Alpha 3794.0.0, November 2023).
-->

---

# So we adopted a standard: sysext

Instead of maintaining more bespoke tooling, we moved to a **systemd primitive** the whole ecosystem shares.

> "System extension images may — dynamically at runtime — extend the `/usr/` and `/opt/` directory hierarchies with additional files. This is particularly useful on immutable system images where a `/usr/` and/or `/opt/` hierarchy residing on a read-only file system shall be extended temporarily at runtime without making any persistent modifications."

— `systemd-sysext(8)` man page

If you have a modern systemd, **you already have this**. It is not a Flatcar only feature, Flatcar is just one of the distros that took the bet early.

<!-- Daniel
- as time progress, more distros with the immutable pattern started to show up and hitting the same problem
- UAPI standard and systemd-sysext were created
- rather than build Torcx 2.0, we adopted systemd-sysext — a cross-distro standard, not a Flatcar invention.
- The win over Torcx: it's a standard. The spec exists, the tooling exists, other distros support it — we stopped carrying the whole maintenance burden alone. Very few people have pushed it past "hello world." We have.
- similar concept exists for `/etc` called concept, we'll get to it later
-->

---

# The mechanics in 30 seconds

![w:960](assets/sysext-merge.svg)

A directory, FS image or DDI with `/usr/lib/extension-release.d/extension-release.<SYSEXT NAME>`:

```ini
ID=flatcar           # target OS — must match host's ID (or _any)
ARCHITECTURE=x86-64  # must match uname (or _any)

# pick ONE version-matching key:
VERSION_ID=4628.1.0  # pin to one OS release (can link host /usr)
SYSEXT_LEVEL=1.0     # instead of using specific OS version use sysext level
```

systemd merges only when these match the host. `systemd-sysext merge | unmerge | refresh`.

<!-- Daniel
- A sysext is a directory, FS image or DDI — typically an erofs or squashfs filesystem or DDI image with dm-verity.
- The image's `/usr` tree is overlaid onto the host /usr via overlayfs. The base is the lowerdir, the sysext is added on top.
- merge composes the layers. unmerge tears them down. refresh re-evaluates after you add or remove an image. No reboot.
- There is a contract that defines what sysexts the system will allow - there are two basic concepts
-->

---

# What sysext is **NOT**

> "System extension images should not be misunderstood as a generic software packaging framework, as no dependency scheme is available: system extensions should carry all files they need themselves, except for those already shipped in the underlying host system image."

— `systemd-sysext(8)` man page

- **No dependency resolution** — author owns the dep closure
- **No scriptlets / `%post` / triggers** — pure file overlay only
- **Hierarchy locked to `/usr` + `/opt`** — files elsewhere are silently ignored
- **Additive by spec** — collision detection is *not* enforced

If you need any of those, **sysext is the wrong tool**.

<!-- bex
- It is important to understand - this isn't another package manager
- it does almost nothing a package manager does except the "deliver bits" part.
- None of the things a package manager provides are provided here
- depdency resolution, scriplets, etc.
- if you need these things you don't need sysext
- or learn not to need those things
-->

---

# OS-dependent vs independent sysexts

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 50px;">
<div>

### `ID=flatcar` + `VERSION_ID`

*"I move when the OS moves."*

- Pinned to a specific Flatcar release
- Can dynamic-link against host `/usr`
- Won't load after an OS update — rebuilt each release
- **Use for**: OEM agents, drivers

</div>
<div>

### `ID=_any`

*"I run on any OS."*

- No version coupling — matches any host, any release
- Must bundle everything (static, or libs in `/usr/local/<name>/`)
- Updates on its own clock via `systemd-sysupdate`
- **Use for**: tools with separate life cycles, distro-agnostic tools

</div>
</div>

<!-- bex
- you wind up with 2 kinds of sysexts, OS Dependent and OS Independent
- Depdendent means it relies on specific components of the base OS being in specific places at specific versions
- Independent means it brings all of its dependencies with it
- The core question you have to ask is, should this lifecycle with the OS or should it be independent of the OS
-->

---

<!-- _class: section -->
<!-- _paginate: false -->

# Demo
## Kubernetes-as-a-sysext

<!-- Daniel
- 1. In Headlamp cordon and drain
- 2. On an existing Flatcar node, show kubelet version we have
- 2a - show loaded sysexts - see docker
- 2b - aside on docker then remove it 
- 3. Show the raw image for the sysext
- 4. Show the check for new command (network hit)
- 5. Copy in staged update and merge
- 6. Restart kubelet and show kubelet version
- 7. In Headlamp scale the workload and get a new pod on the system - show the update applied
-->

---

# Issue with self-contained sysexts

- **Nothing you can count on**
- **No dependency resolution** — no package manager, if you need a library you have to bring it
- **You vendor each dependency by hand** — walk the link tree and copy every missing library into the sysext:

```
ldd /usr/bin/<binary>
   libfoo.so.1 => not found      ← you must bring this
   libbar.so.2 => not found      ← and this
   libc.so.6   => /usr/lib/...    ← already in base /usr, OK
```

- **It's recursive** — dependencies have dependencies, so re-run `ldd` on everything you copy
- **Collisions are a secondary risk** — if two sysexts ship the same `libfoo.so.1`, first merge wins and overlayfs won't warn you.

<!-- Daniel
- The headline problem is NOT version collisions — those can happen but are rare. The real, everyday pain is that there's no dependency resolution at all.
- On an immutable OS there's no package manager on the host. If your binary needs libfoo and it's not in the base /usr, nothing will provide it. You have to vendor it into the sysext yourself.
- And it's recursive — you ldd the binary, copy the missing libraries, then ldd those libraries, because dependencies have dependencies. That hand-walking is the tedious part.
- The collision case (two sysexts shipping the same so, first merge wins, overlayfs won't detect it) is real but secondary — mention it, don't lead with it.
- There is no Requires:/Conflicts: in sysext. That's the deliberate trade for the simpler model — and it's exactly what the next slide's tooling (Flix/Flatwrap) automates.
-->

---

# Our answer to this

Two tools in `flatcar/sysext-bakery`, both making a sysext self-contained:

- **Flix** — rewrite ELF binaries with `patchelf` so each only looks in its own private dir
  - `patchelf --set-interpreter /usr/local/<NAME>/ld-linux --no-default-lib --set-rpath /usr/local/<NAME> /usr/bin/<binary>`
  - No host-library coupling — the binary can't pick up a colliding `libfoo.so`

- **Flatwrap** — ship the whole rootfs under `/usr/local/<NAME>/`, wrap the entry point in a mount namespace
  - `unshare -m` → `mount --bind /usr/local/<NAME>/usr …` → `chroot`
  - Each invocation runs in its own private view of `/usr`

Note: Today we have ship most of our sysexts either built directly against the distro during release or as independent **static binary** sysexts. This partly because the cloud-native world is Go and Rust, and partly because most of the non-static use cases have warranted including in our release pipeline. However, we do ship `tilde` (Flix) and `btop` (Flatwrap) using these tools, partly as proofs of concept.

<!-- Daniel
- Flix uses patchelf to rewrite RPATHs so binaries only look in their private directory. The bakery's tilde extension uses this.
- Flatwrap uses mount namespaces to give each binary its own view of /usr. The bakery's btop extension uses this.
- Both work. Both are elegant. Both are barely used.
- Why? Because cloud-native software is mostly Go and Rust. Kubernetes, containerd, runc, k3s, rke2, nerdctl — all statically linked. The dynamic-linking problem is mostly a non-problem if your target is the CNCF universe.
- The honest takeaway: we built two solutions, and we recommend the third option (static binaries). We have the tools when you need them. You usually don't.
-->

---

# Next problem we hit: confext/sysext was strictly read-only

Read-only is great, right up until it isn't.

Some use cases that needed a writable upper layer:
- We wanted to use confext for managing `/etc` and most things expect to be able to write `/etc`
- Using sysexts on a mutable system sets `/usr` to read-only

So we drove a fix **upstream** landing a spec change for mutable mode which shipped in **systemd v256** (June 2024).

<!-- Daniel
- Remind what confext is
- The mechanism: systemd-sysext --mutable= modes — disabled, auto, enabled, import, ephemeral, ephemeral-import
- This is the upstream-contribution arc the talk title promises.
- The clever trick: if /var/lib/extensions.mutable/usr is a symlink to /usr, the host /usr becomes the overlay upperdir — writes go straight back to the base. That's how confext works on a mutable /etc.
- The detailed paper trail, if anyone asks: Kai Lüke filed Flatcar issue #986 (Mar 2023); Thilo Fromm wrote UAPI Spec PR #78 (merged May 2024); Krzesimir Nowak wrote systemd PR #31000 (merged Feb 2024). All three are Flatcar maintainers — our colleagues, they deserve the credit.
-->
    
---

# What we ship today
    
In Stable-  Three categories of Flatcar sysexts

- **Opt-out** — shipped *in the base image*, on by default
  - `docker-flatcar` · `containerd-flatcar` · `oem-*`

- **Opt-in** — built by Flatcar CI, **downloaded at provisioning**, off by default
  - `nvidia-drivers-*` · `zfs` · `python` · `podman` · `incus`
  - Enable with one line: `echo nvidia-drivers >> /etc/flatcar/enabled-sysext.conf`

Opt-out and opt-in are **OS-dependent**: `ID=flatcar` + `VERSION_ID`, signed with the image's ephemeral build key.

- **Community** — from the sysext-bakery, community-built and *not* Flatcar-tested
  - `kubernetes` · `k3s` · `cilium` · `nerdctl` · `tailscale` · …28 recipes
  - `ID=_any`, self-contained; updates **independently** via `systemd-sysupdate`
  - To enforce signatures, **import the bakery key yourself** — it isn't in the image

<!-- bex
- Opt-out ships IN the image. Docker and containerd are not in /usr anymore
- Opt-in is built by our CI and downloaded at provisioning time, not baked into the image.
- You turn it on with one line in enabled-sysext.conf.
- Opt-out + opt-in are both OS-dependent, and both are signed during hte release cycle and the key is created there
- Community is the bakery
— community-built, not release-tested, self-contained. 28 recipes today.
-->



---

# What we ship also today
    
In Beta (now rolling into Stable):

- **Confext** — `/etc` is now a `systemd-confext` in a mutable-mode (replaced our custom overlayfs scripts)
- **Sysexts cryptographically signed** — dm-verity roothash signatures, ephemeral build key
- **Format change** — squashfs → **erofs DDI** (Discoverable Disk Image)

This is list is all just tooling around sysext for our users, not the implementation itself.

<!-- bex
- we have got cool stuff coming up through channels and that has already landed in our beta channel.
- I am particularly excited for confext as those of us with long-lived pet-like hosts can have an easier time working with our customizations and playbooks
-->

---

<style scoped>
section img { display: block; margin: 0 auto; }
</style>

# The two-axis test

![h:440](assets/two-axis-plane.svg)

**The sysext quadrant** — needs the host, but is too opinionated to ship with it.

<!-- bex
- As you think about using system extensions there are two models that are useful
- first, the two axis test
- vertical = "does this need to be on the real host or can it run in a container?"
- Horizontal = "does this ship in the base OS image or get added per deployment?"
- Top-left: SYSTEM AGENTS. Things you may bake into the OS image but could also containerize
- Top-right: APPLICATIONS. Stuff users add like workloads and similar infra apps
- Bottom-left: BASE OS. This is the core of the OS and reflects the distros core opinion
- Bottom-right: SYSEXT. Things you need on the host but which users will have feels about
-->

---

# Comparing rpm-ostree, bootc, and sysext

**rpm-ostree** - "I want to add a distribution component"
- Full distro dependency graph; rollback by deployment swap; cadence tied to the base
- rpm-ostree layers **at runtime/on-host, per host** then reboot

**bootc** - "I want to rebuild my entire system on changes"
- Full distro dependency graph; rollback by deployment swap; cadence tied to the base
- bootc bakes **at build time**, ships an OCI image then reboot

**systemd-sysext** - "I want a self-contained add-on with a separate lifecycle and no reboot"
- **No dependency resolution** — a `.raw` tree overlaid on `/usr`; you bundle deps
- `merge` / `unmerge`; cadence **independent** per extension no reboot

<!-- bex
- another model close to home is which tech to choose
- These are all great choices depending on your goals and desires
- What do you want made easy and what can be hard
- rpm-ostree gives you the full distro package set and dependency graph
- new stuff, existing image
- bootc bakes your customization into the image at build time
- new stuff new image
- sysext gives you a self-contained add-on with its own update clock.
- new stuff new image, but also new stuff same image - a mix of both
-->

---

<!-- _class: section -->
<!-- _paginate: false -->

# Demo
## ... but wait, there's more.

<!-- bex
- 1. In Headlamp point to worker 2 .. let's look at this one.  First cordon ...
- 2. Login and cat /etc/os-release - oh look Fedora CoreOS
- 3. Show that there is a sysext loaded
- 4. show kubelet version, then copy staged flatcar update and restart
- 5. same sysext same effect ... different OS
= 6. Headlamp add workload
- 7. Admit we cheated - we had to turn of selinux ... so that's sad.  We are thinking about it
- 8. But wait, what's worker-3 - Cordon
- 9. Also Fedora CoreOS
- 10. Using a Fedora CoreOS custom sysext for kubelet
- 11. Update and restart kubelet
- 12. add workload - show they are all on the same version
-->

---

# Try it today -  Thank you

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 50px;">
<div>

### Resources

- **flatcar.org** — website & docs
- **extensions.flatcar.org** — sysext bakery
- **Discord** — `discord.gg/PMYjFUsJyq`
- **Chat** — Matrix · CNCF Slack `#flatcar`
- **Office Hours** — every 2nd Tue, 15:30 UTC

</div>
<div>

### Try it locally

```sh
# clone flatcar/sysext-bakery, then:
./bakery.sh list
./bakery.sh boot kubernetes
# SSH into the VM:
systemctl status kubelet
```

</div>
</div>

**Lennart's vision**: [0pointer.net/blog/fitting-everything-together.html](https://0pointer.net/blog/fitting-everything-together.html)
**UAPI extension-image spec**: [uapi-group.org/specifications/specs/extension_image](https://uapi-group.org/specifications/specs/extension_image)
**FCOS sysexts**: [github.com/travier/fedora-sysexts](https://github.com/travier/fedora-sysexts)
<hr>
<div style="display:flex; gap:60px; margin-top:8px;">
<div><strong>Brian "bex" Exelbierd</strong> &nbsp;·&nbsp; bex@bexelbie.com<br>Principal Product Manager, Microsoft Azure<br>Upstream Linux</div>
<div><strong>Daniel Zaťovič</strong> &nbsp;·&nbsp; daniel.zatovic@gmail.com<br>Software Engineer, Microsoft Azure<br>Flatcar Engineering</div>
</div>

---

<!--
- bakery.sh boot is the easiest on-ramp. It spins up a local QEMU VM with a Caddy server in front, Ignition snippet auto-generated, sysext merged.
- Three URLs at the bottom are the canonical reading list — Lennart's vision post, the UAPI spec, and the FCOS community sysexts repo.
- We will hang out in the hallway and at the Flatcar booth.

-- Build Notes:

Build PPTX (with speaker notes, recommended for the actual talk):
  make pptx

Build standalone HTML (good for previewing / sharing online):
  make html

Build PDF:
  make pdf

Live preview while editing (auto-reloads on save):
  make serve
-->