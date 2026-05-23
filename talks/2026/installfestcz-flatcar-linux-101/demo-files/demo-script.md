# Flatcar 101 Demo Script

This document is both the offline validation checklist (Phase 7) and the
nuts-and-bolts script for the live demonstration. Every command listed
here must work with zero internet connectivity.

---

## Pre-demo setup (do once, before going on stage)

These steps bring up the infrastructure and leave both VMs ready to
boot fresh. Run them from the project root.

```bash
# 1. Start the infrastructure pod (Nebraska + PostgreSQL + nginx)
./infra/start-infra.sh

# 2. Register the update package in Nebraska
./infra/setup-nebraska.sh

# 3. Verify services are up
curl -4 http://localhost:8000/health          # → OK
curl -4 http://localhost:8080/payload/        # → lists flatcar_production_update.gz
curl -4 http://localhost:8080/sysext/         # → lists tailscale .raw files
```

At this point the infrastructure is running. No VMs are booted yet.

---

## Demo 1 — Boot Flatcar with Ignition

**Goal:** Show that Flatcar boots from a declarative config. No manual
setup, no package installs, no shell scripts on first boot.

### Start VM1

In a terminal that the audience can see:

```bash
./infra/start-vm1.sh
```

> While the VM boots (~30s), talk through what Ignition is doing:
> reading the JSON config, writing /etc/hostname, writing
> /etc/flatcar/update.conf, injecting the SSH key.

### SSH in

In a second terminal:

```bash
ssh core@192.168.122.101
```

### Show what Ignition configured

```bash
# The hostname was set declaratively
hostname

# The update server points at our local Nebraska, not the internet
cat /etc/flatcar/update.conf

# The OS is immutable — there is no package manager
apt-get          # → command not found
dnf              # → command not found
rpm -qa          # → command not found

# The filesystem is read-only
touch /usr/test  # → Read-only file system

# But /etc and /var are writable (state lives here)
cat /etc/os-release | grep VERSION
```

### Show that containers work out of the box

```bash
# Docker is built in via a sysext (systemd system extension)
docker version --format '{{.Server.Version}}'

# The base OS is minimal — everything else runs in containers
```

> **Transition:** "This is a fully functional server, provisioned from a
> single JSON file. But it's running an old version — 4515.0.0. Let's
> see how Flatcar handles updates."

---

## Demo 2 — Automatic OS update via Nebraska

**Goal:** Show the A/B partition update mechanism. The update downloads
in the background, writes to the inactive partition, and the system
reboots into the new version. Zero downtime for the update itself.

### Show the current version

```bash
cat /etc/os-release | grep VERSION_ID
# → 4515.0.0
```

### Trigger the update

```bash
sudo update_engine_client -check_for_update
```

> "update_engine just contacted our local Nebraska server. Nebraska told
> it: there's version 4628.0.0 available, and here's where to download
> it."

### Watch the download and install

```bash
sudo update_engine_client -status
# → UPDATE_STATUS_UPDATE_AVAILABLE, NEW_VERSION=4628.0.0
```

```bash
sudo update_engine_client -update
```

> While it downloads (~10s from local nginx over bridge networking):
> "The update payload is downloading from our local server. It's writing
> to the inactive partition — the running system is completely untouched.
> If power fails right now, the system reboots into the current version,
> not a broken half-update."

### Monitor progress (optional, if time permits)

```bash
watch sudo update_engine_client -status
```

Wait for `UPDATE_STATUS_UPDATED_NEED_REBOOT`.

### Reboot into the new version

```bash
sudo reboot
```

> Wait ~30s for the VM to come back.

### Verify the update

```bash
ssh core@<VM1_IP>
cat /etc/os-release | grep VERSION_ID
# → 4628.0.0
```

> **Transition:** "That's the OS update. But what if you need software
> that isn't in the base image? That's where systemd-sysext comes in."

---

## Demo 3 — Extending Flatcar with systemd-sysext

**Goal:** Show that the immutable base can be extended without breaking
immutability. sysext images overlay additional files onto /usr at
runtime. You can swap out built-in components (Docker → Podman), add
new ones (Tailscale), and update them independently of the OS.

### Start VM2

In a new terminal (leave VM1 running or stop it — your choice):

```bash
./infra/start-vm2.sh
```

### SSH in

```bash
ssh core@192.168.122.102
```

### Part A — Docker is gone, Podman is here

```bash
# VM1 had Docker. On this VM we nulled it out via Ignition:
docker version 2>&1 || echo "docker: not found"
# → docker: not found

# Instead, Podman is active — enabled via /etc/flatcar/enabled-sysext.conf
podman --version
# → podman version 5.3.0

# How? The Docker sysext is symlinked to /dev/null:
ls -la /etc/extensions/docker-flatcar.raw
# → /dev/null

# And Podman was enabled declaratively:
cat /etc/flatcar/enabled-sysext.conf
# → podman
```

> "Same base image as VM1, but we swapped the container runtime
> declaratively. No packages, no compilation — just Ignition config."

### Part B — Tailscale loaded as a third-party sysext

```bash
# Tailscale was added as a sysext overlay at boot
systemd-sysext status
# → shows flatcar-podman, oem-qemu, tailscale

/usr/local/bin/tailscale version
# → 1.70.0

# It's a raw disk image overlaid on /usr
ls -la /etc/extensions/tailscale.raw
# → symlink to /opt/extensions/tailscale/tailscale-1.70.0-x86-64.raw
```

> "This is version 1.70.0. There's a newer version on our local server.
> Let's update it — without touching the OS, without rebooting."

### Part C — Live sysext update via systemd timer

```bash
# Check what's available
sudo /usr/lib/systemd/systemd-sysupdate --component=tailscale list
# → shows 1.76.6 as candidate, 1.70.0 as current

# Trigger the update (same as the timer does automatically)
sudo systemctl start sysupdate-tailscale.service
# → downloads 1.76.6 from local nginx, refreshes sysext overlay

# Verify — no reboot needed
/usr/local/bin/tailscale version
# → 1.76.6
```

> "We upgraded Tailscale from 1.70.0 to 1.76.6 without a reboot,
> without a package manager, and without breaking immutability. A systemd
> timer checks for updates automatically in the background — just like
> the OS update, but for individual extensions."

---

## Teardown

After the demo (or to reset for another run):

```bash
# Stop VMs: Ctrl-A X in each QEMU terminal, or kill the processes

# Full reset (removes VM images, restarts infra, re-registers Nebraska)
./infra/reset-demo.sh
./infra/setup-nebraska.sh
```

---

## Phase 7 offline validation checklist

Run through this entire document with **no internet**. Verify each
expected output matches. Specific things to watch for:

- [ ] `start-infra.sh` succeeds (all container images are cached)
- [ ] `setup-nebraska.sh` succeeds (Nebraska API responds)
- [ ] `curl -4 http://localhost:8080/payload/` lists the update payload
- [ ] `curl -4 http://localhost:8080/sysext/` lists the Tailscale .raw files
- [ ] VM1 boots and SSH works at 192.168.122.101
- [ ] VM1 shows version 4515.0.0
- [ ] `update_engine_client -update` downloads from local nginx (not internet)
- [ ] VM1 reboots into 4628.0.0
- [ ] VM2 boots with Podman and Tailscale sysexts loaded
- [ ] `docker version` fails (Docker nulled out)
- [ ] `podman --version` shows 5.3.0
- [ ] `/usr/local/bin/tailscale version` shows 1.70.0
- [ ] `sysupdate-tailscale.timer` is active
- [ ] `sudo systemctl start sysupdate-tailscale.service` downloads 1.76.6 and refreshes
- [ ] `/usr/local/bin/tailscale version` shows 1.76.6
- [ ] `reset-demo.sh` + `setup-nebraska.sh` returns everything to initial state
- [ ] Full flow repeatable a second time after reset

### How to go offline

```bash
# Disconnect Wi-Fi
nmcli radio wifi off
# Or disconnect Ethernet
nmcli device disconnect <device>
# Verify
ping -c1 8.8.8.8   # → should fail
```
