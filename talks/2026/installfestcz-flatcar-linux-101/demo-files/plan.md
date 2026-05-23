# Flatcar Talk Infrastructure Plan

This document captures all research and decisions needed to build the offline
demo infrastructure for the Installfest.cz Flatcar Linux 101 talk. It is
written so a fresh session on the demo laptop can execute without re-doing
any research.

## Hardware & Environment

- **Laptop**: Lenovo T460S, 20GB RAM, Fedora Workstation (or headless)
- **Presentation**: presenterm (terminal-based, text-only slides)
- **Internet**: Assume zero at the venue. All prep happens at home.

## Talk Structure (25 minutes)

Demos to show:
1. Boot Flatcar in a QEMU/KVM VM (shows Ignition provisioning)
2. Boot Flatcar in a QEMU/KVM VM with Podman + Tailscale sysexts
3. Trigger an OS update on both VMs via the automated update mechanism

## Architecture Overview

```
┌──────────────────────────────────────────────┐
│  Fedora Host (T460S)                         │
│                                              │
│  ┌────────────────────────────────────┐      │
│  │ Podman Pod: "flatcar-infra"        │      │
│  │  ┌──────────┐  ┌──────────────┐   │      │
│  │  │ Nebraska  │  │ PostgreSQL   │   │      │
│  │  │ :8000     │  │ :5432        │   │      │
│  │  └──────────┘  └──────────────┘   │      │
│  │  ┌──────────────────────────────┐ │      │
│  │  │ nginx (payload + sysext      │ │      │
│  │  │ static file server) :8080    │ │      │
│  │  └──────────────────────────────┘ │      │
│  └────────────────────────────────────┘      │
│                                              │
│  ┌──────────────┐  ┌──────────────────┐      │
│  │ QEMU/KVM VM  │  │ QEMU/KVM VM      │     │
│  │ Flatcar      │  │ Flatcar           │     │
│  │ (plain)      │  │ (Podman+Tailscale)│     │
│  │ old version  │  │ old version       │     │
│  └──────────────┘  └──────────────────┘      │
└──────────────────────────────────────────────┘
```

No nested virtualization. Infrastructure runs as containers on the host.
Demo VMs run via QEMU/KVM directly on the host.

## The Two Update Systems

Flatcar has two separate update mechanisms. Both must be served locally.

### OS Updates: update_engine + Nebraska (Omaha protocol)

- Flatcar's `update_engine` daemon speaks the **Omaha protocol** (XML-based,
  originally from Chrome OS). You cannot substitute a plain HTTP server.
- **Nebraska** (`ghcr.io/flatcar/nebraska`) is the only practical Omaha server
  for Flatcar. It is mandatory for the OS update demo.
- Nebraska is a Go binary with a React frontend. Needs PostgreSQL.
- Nebraska acts as the **coordinator**: it responds to Omaha requests with
  metadata including a `payload_url` — the URL where the actual update file
  lives.
- Nebraska does **not** serve update payloads by default. It returns URLs
  pointing to Flatcar's public CDN (`update.release.flatcar-linux.net`).
- For offline: we host payloads on our own HTTP server (nginx) and configure
  Nebraska to return our local URLs instead of the public CDN.
- Nebraska has a `--host-flatcar-packages` flag that may simplify this, but
  docs are thin. The reliable path is: Nebraska for Omaha + nginx for files.

**Update payload details:**
- File: `flatcar_production_update.gz` (full image) — ~500-800MB per release
- We need two versions: the "old" version (what the VM boots) and the "new"
  version (what the update installs).
- Download URL pattern:
  `https://stable.release.flatcar-linux.net/amd64-usr/{VERSION}/`

### sysext Updates: systemd-sysupdate + plain HTTP

- sysext images are `.raw` SquashFS files overlaid on `/usr` at runtime.
- `systemd-sysupdate` fetches them via plain HTTP — no special protocol.
- Normally served from `extensions.flatcar.org` (a Caddy proxy to GitHub
  Releases of the `flatcar/sysext-bakery` project).
- For offline: download `.raw` files + SHA256SUMS, serve from nginx.
- sysupdate config lives in `/etc/sysupdate.d/` on the Flatcar VM.

**sysext image details:**
- Source: `https://github.com/flatcar/sysext-bakery/releases`
- Extensions needed: **Podman** and **Tailscale**
- Size: ~50-300MB each
- Must match the Flatcar version (images are version-tagged)

## Configuring Flatcar VMs

### Pointing at custom update server

Write `/etc/flatcar/update.conf` via Ignition (Butane format):

```yaml
variant: flatcar
version: 1.0.0
storage:
  files:
    - path: /etc/flatcar/update.conf
      overwrite: true
      mode: 0644
      contents:
        inline: |
          SERVER=http://{HOST_IP}:8000/v1/update/
          GROUP=stable
```

Replace `{HOST_IP}` with the host's IP visible to the VM (e.g., the
libvirt bridge IP, typically `192.168.122.1` for the default network).

### Pointing sysupdate at custom sysext server

Create sysupdate drop-in configs via Ignition that override the default
`extensions.flatcar.org` URLs with `http://{HOST_IP}:8080/sysext/`.

The config files live in `/etc/sysupdate.d/` and follow the
`systemd.sysupdate(5)` format. Each extension gets its own `.conf` file.

### Placing sysext images via Ignition (alternative)

For the initial boot with sysexts, we can skip sysupdate entirely and just
place the `.raw` files directly via Ignition:

```yaml
storage:
  files:
    - path: /etc/extensions/podman.raw
      mode: 0644
      contents:
        source: http://{HOST_IP}:8080/sysext/podman-{VERSION}-x86-64.raw
    - path: /etc/extensions/tailscale.raw
      mode: 0644
      contents:
        source: http://{HOST_IP}:8080/sysext/tailscale-{VERSION}-x86-64.raw
```

### Booting a Flatcar QEMU VM

1. Download the QEMU image:
   `https://stable.release.flatcar-linux.net/amd64-usr/{VERSION}/flatcar_production_qemu_image.img.bz2`

2. Decompress: `bunzip2 flatcar_production_qemu_image.img.bz2`

3. Boot with Ignition:
   ```
   ./flatcar_production_qemu.sh -i config.ign -- -nographic
   ```
   Or launch via libvirt with Ignition passed as fw_cfg.

4. SSH in: `ssh -l core -p 2222 localhost`

5. The helper script is bundled with the QEMU image download. Also get:
   `flatcar_production_qemu.sh` from the same release directory.

### Triggering an update manually

```bash
# Force an update check against our local Nebraska
sudo update_engine_client -check_for_update

# Or force a full update (check + download + install)
sudo update_engine_client -update

# Watch progress
sudo update_engine_client -status
journalctl -u update-engine -f

# After update installs, reboot into new version
sudo reboot
```

### Triggering a sysext update manually

```bash
# Check for sysext updates
sudo systemd-sysupdate update

# Verify loaded extensions
systemd-sysext status
```

## Resource Budget

### Disk

| Component | Size |
|-----------|------|
| Flatcar QEMU image (old version) | ~400MB |
| Flatcar update payload (new version) | ~600MB |
| Podman sysext .raw | ~100-200MB |
| Tailscale sysext .raw | ~50-100MB |
| Nebraska + PostgreSQL container images | ~500MB |
| nginx container image | ~50MB |
| Demo VM runtime disk (2x CoW images) | ~2GB |
| **Total** | **~4-5GB** |

### RAM

| Component | RAM |
|-----------|-----|
| Fedora host + desktop/presenterm | ~2-3GB |
| Podman pod (Nebraska + PG + nginx) | ~1GB |
| Flatcar VM 1 | ~2GB |
| Flatcar VM 2 | ~2GB |
| **Total** | **~7-8GB of 20GB** |

## Build Steps (execute on the demo laptop, with internet)

### Phase 1: Choose Flatcar versions

1. Pick two consecutive stable releases. Check:
   `https://www.flatcar.org/releases`
   or `curl -s https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt`

2. The "old" version is what we boot the demo VMs from.
   The "new" version is the update target.
   Pick versions that are close (e.g., one or two releases apart) so the
   update payload is a real update, not a massive jump.

3. Verify that sysext-bakery has Podman and Tailscale images for both versions.
   Check: `https://github.com/flatcar/sysext-bakery/releases`

### Phase 2: Download artifacts

All downloads happen with internet. Store in a local `artifacts/` directory.

```bash
mkdir -p artifacts/{old,new,sysext}

# Old version (boot image + helper script)
OLD_VER="XXXX.X.X"  # fill in
wget -P artifacts/old/ \
  https://stable.release.flatcar-linux.net/amd64-usr/${OLD_VER}/flatcar_production_qemu_image.img.bz2 \
  https://stable.release.flatcar-linux.net/amd64-usr/${OLD_VER}/flatcar_production_qemu.sh

# New version (update payload only)
NEW_VER="YYYY.Y.Y"  # fill in
wget -P artifacts/new/ \
  https://stable.release.flatcar-linux.net/amd64-usr/${NEW_VER}/flatcar_production_update.gz

# sysext images (for both old and new versions if they differ)
wget -P artifacts/sysext/ \
  https://github.com/flatcar/sysext-bakery/releases/download/latest/podman-{VERSION}-x86-64.raw \
  https://github.com/flatcar/sysext-bakery/releases/download/latest/tailscale-{VERSION}-x86-64.raw \
  https://github.com/flatcar/sysext-bakery/releases/download/latest/SHA256SUMS
```

Note: sysext-bakery release URLs may not follow this exact pattern. The
actual URL structure uses the bakery's release tags. Check the releases page
and `extensions.flatcar.org` URL rewriter to find exact download URLs.

### Phase 3: Pull container images

```bash
podman pull ghcr.io/flatcar/nebraska:latest
podman pull docker.io/library/postgres:17
podman pull docker.io/library/nginx:alpine
```

### Phase 4: Set up the infrastructure pod

Create a podman pod with shared networking. Write a script or
`podman-compose.yml` (or a shell script using `podman pod create` +
`podman run`).

Key Nebraska environment variables:
```
NEBRASKA_DB_URL=postgres://postgres:nebraska@localhost:5432/nebraska?sslmode=disable
NEBRASKA_AUTH_MODE=noop
```

The `noop` auth mode disables authentication (fine for local demo).

Nebraska has a `--host-flatcar-packages` flag and a syncer
(`NEBRASKA_ENABLE_SYNCER`). **Test both approaches:**

**Approach A (syncer + override):**
1. Start Nebraska with `NEBRASKA_ENABLE_SYNCER=true`
2. Nebraska auto-imports version metadata from upstream (needs internet once)
3. Through Nebraska's API, update the payload URLs to point at local nginx
4. Nebraska API endpoint: `POST /api/v1/apps/{app_id}/packages` (needs testing)

**Approach B (manual registration):**
1. Start Nebraska without syncer
2. Use Nebraska's API to manually create channels, groups, packages
3. Set payload URLs to local nginx from the start
4. This avoids any dependency on upstream metadata

Approach B is more work upfront but more predictable for offline.

**Nebraska API reference:**
- The API is documented in the source code at `backend/cmd/nebraska/`
- There's also a Swagger/OpenAPI spec — check the repo
- The web UI at `:8000` uses the same API (inspect network traffic to learn it)

### Phase 5: Set up nginx for static file serving

nginx config to serve payloads and sysexts:

```nginx
server {
    listen 8080;
    root /data;
    autoindex on;

    location /payload/ {
        # flatcar_production_update.gz lives here
    }

    location /sysext/ {
        # .raw files and SHA256SUMS live here
    }
}
```

Mount `artifacts/new/` → `/data/payload/` and `artifacts/sysext/` →
`/data/sysext/` in the nginx container.

### Phase 6: Write Ignition configs

Two Butane configs, transpiled to Ignition JSON:

**VM 1 (plain Flatcar):**
- Custom update server pointing at local Nebraska
- SSH key for access
- Reboot strategy: `off` (so we control when it reboots during the demo)

**VM 2 (Flatcar + sysexts):**
- Everything from VM 1
- Plus: Podman and Tailscale sysext images fetched from local nginx at boot
- Plus: sysupdate config pointing at local nginx for sysext updates

Transpile with: `podman run --rm -i quay.io/coreos/butane:release < config.bu > config.ign`

### Phase 7: End-to-end test (with internet, then without)

1. Start the infra pod
2. Boot VM 1 with old Flatcar + Ignition → verify it registers with Nebraska
3. Boot VM 2 with old Flatcar + sysexts + Ignition → verify sysexts load
4. On VM 1: `update_engine_client -update` → verify it downloads from local
   nginx and installs
5. On VM 2: same, plus `systemd-sysupdate update` for sysexts
6. **Disconnect internet**, restart everything, re-test the full flow
7. If anything breaks offline, debug and fix

### Phase 8: Automation scripts

Write shell scripts for the talk:
- `start-infra.sh` — brings up the podman pod
- `start-vm1.sh` — boots plain Flatcar VM
- `start-vm2.sh` — boots sysext Flatcar VM
- `teardown.sh` — stops everything
- Possibly: `reset-demo.sh` — restores VMs to pre-update state for re-running

## Known Unknowns (test during build)

1. **Nebraska payload URL override**: The exact mechanism for telling Nebraska
   "when a client asks for version X, give them this local URL for the payload"
   needs hands-on testing. Options: API, UI, or database direct edit. The
   syncer probably sets `payload_url` in the `flatcar_updates` table — we
   may be able to just update that row.

2. **Nebraska `--host-flatcar-packages`**: This flag allegedly lets Nebraska
   serve payloads directly. If it works, it eliminates the need for nginx for
   payloads (but we still need it for sysexts). Test this early.

3. **sysupdate config format**: The exact `.conf` file syntax for pointing
   systemd-sysupdate at a custom URL (not extensions.flatcar.org) needs to
   be worked out. Reference: `man systemd.sysupdate(5)` and the config files
   that ship with Flatcar in `/usr/lib/sysupdate.d/`.

4. **QEMU networking**: The VMs need to reach the host. The default
   `flatcar_production_qemu.sh` uses QEMU user-mode networking (SLIRP).
   The host is reachable at `10.0.2.2` from the guest in SLIRP mode. Confirm
   this works for reaching Nebraska (:8000) and nginx (:8080). Alternatively
   use libvirt's bridge (`192.168.122.1`).

5. **sysext version compatibility**: sysext images are tagged for specific
   Flatcar versions. Verify that the Podman and Tailscale images from
   sysext-bakery exist for both our old and new Flatcar versions.

6. **Update timing**: How long does `update_engine_client -update` take from
   trigger to "ready to reboot" when downloading from localhost? This affects
   talk pacing. Expect: seconds for download, 30-60s for partition write.

## Key URLs & References

- Nebraska repo: https://github.com/flatcar/nebraska
- Nebraska container: `ghcr.io/flatcar/nebraska:latest`
- sysext-bakery: https://github.com/flatcar/sysext-bakery
- Flatcar releases: https://www.flatcar.org/releases
- Stable release files: https://stable.release.flatcar-linux.net/amd64-usr/
- Flatcar docs on updates: https://www.flatcar.org/docs/latest/nebraska/managing-updates/
- Flatcar docs on sysext: https://www.flatcar.org/docs/latest/provisioning/sysext/
- Omaha protocol spec: https://github.com/google/omaha/blob/main/doc/ServerProtocolV2.md
- Butane config transpiler: `quay.io/coreos/butane:release`
- update.conf reference: SERVER, GROUP, REBOOT_STRATEGY fields
- presenterm (slides): https://github.com/mfontanini/presenterm
