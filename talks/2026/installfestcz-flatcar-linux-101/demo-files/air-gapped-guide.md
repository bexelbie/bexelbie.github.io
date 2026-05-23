# Running Flatcar Container Linux in Air-Gapped Environments

A practical guide for system administrators who need to deploy and
maintain Flatcar Container Linux on networks with no internet access.

---

## Why Air-Gap Flatcar?

Flatcar Container Linux is designed around automatic, over-the-air
updates. Out of the box, it contacts:

- **update.release.flatcar-linux.net** — to check for and download OS
  updates via the Omaha protocol
- **update.release.flatcar-linux.net** — to download version-matched
  system extension (sysext) images during first boot

This is great for cloud deployments, but many environments — factory
floors, classified networks, conference demos, edge deployments — have
no internet access by design. Running Flatcar in these environments
requires replacing the upstream services with local equivalents.

This guide covers the three things you need to solve:

1. **OS updates** — serving update payloads from a local Omaha server
2. **System extensions** — serving sysext images from a local file server
3. **Day-2 operations** — adding new versions and extensions through
   whatever mechanism brings material into the air gap

## Architecture Overview

An air-gapped Flatcar deployment needs three local services:

| Service | Purpose | Port |
|---------|---------|------|
| **Nebraska** | Omaha-compatible update server (tells machines what version is available and where to download it) | 8000 |
| **PostgreSQL** | Nebraska's database | 5432 |
| **nginx** (or any static file server) | Serves update payloads and sysext images | 8080 |

These can run on a dedicated management host, in containers, or on the
same hardware as the Flatcar nodes — whatever fits your topology. In our
reference setup, all three run in a single Podman pod on the host that
also serves as the network gateway.

```
┌─────────────────────────────────────────────────┐
│  Management Host (e.g., Fedora, RHEL)           │
│                                                 │
│  ┌─────────┐  ┌──────────┐  ┌───────┐          │
│  │ Nebraska │  │ PostgreSQL│  │ nginx │          │
│  │ :8000    │  │ :5432     │  │ :8080 │          │
│  └────┬─────┘  └──────────┘  └───┬───┘          │
│       │    Pod (shared network)   │              │
│       └───────────┬───────────────┘              │
│              192.168.122.1                       │
│                   │                              │
├───────────────────┼──────────────────────────────┤
│              virbr0 / physical switch            │
├───────┬───────────┼───────────┬──────────────────┤
│       │           │           │                  │
│  ┌────┴────┐ ┌────┴────┐ ┌───┴─────┐            │
│  │Flatcar 1│ │Flatcar 2│ │Flatcar N│            │
│  │  .101   │ │  .102   │ │  .10x   │            │
│  └─────────┘ └─────────┘ └─────────┘            │
```

## What You Need

### Artifacts to Stage (While Online)

Before going offline, download everything to a staging area:

**OS images and updates:**

```bash
# The base image your machines will boot from
wget https://<CHANNEL>.release.flatcar-linux.net/amd64-usr/<OLD_VER>/flatcar_production_qemu_image.img.bz2

# The update payload for the target version
wget https://update.release.flatcar-linux.net/amd64-usr/<NEW_VER>/flatcar_production_update.gz
```

**Version-matched sysext images** (for both old and new versions):

```bash
# Official sysexts (podman, zfs, python, etc.) — .gz format
for VER in <OLD_VER> <NEW_VER>; do
  wget https://update.release.flatcar-linux.net/amd64-usr/${VER}/flatcar-podman.gz
  wget https://update.release.flatcar-linux.net/amd64-usr/${VER}/oem-qemu.gz
done
```

**Community sysexts** (from the sysext-bakery):

```bash
wget https://github.com/flatcar/sysext-bakery/releases/download/latest/tailscale-1.70.0-x86-64.raw
```

**Container images** for the infrastructure services:

```bash
podman pull ghcr.io/flatcar/nebraska:latest
podman pull docker.io/library/postgres:17
podman pull docker.io/library/nginx:alpine
```

Transfer everything into the air-gapped network using whatever
mechanism your environment allows (USB drive, data diode, approved file
transfer, etc.).

### Channel and Version Requirements

> **Important:** The `flatcar.release_file_server_url` kernel command
> line parameter — which redirects first-boot sysext downloads to a
> local server — was introduced in **Alpha 4487.0.1**. As of this
> writing, this feature has not yet reached the stable channel. If you
> need this feature and it's not yet in stable, use the alpha channel.
> Check the [Flatcar release notes](https://www.flatcar.org/releases)
> for current availability.
>
> Without this parameter, machines will attempt to download official
> sysext images (podman, oem-qemu, etc.) from the internet during first
> boot, even if you provide them via Ignition. The parameter is essential
> for fully air-gapped operation.

## Setting Up the Infrastructure

### 1. Directory Structure

Organize your artifacts so nginx can serve them with the URL structure
that Flatcar expects:

```
artifacts/
├── base-image/
│   └── flatcar_production_qemu_image.img     # Boot image
├── payload/                                   # Mounted as nginx /payload/
│   ├── flatcar_production_update.gz           # OS update payload
│   ├── oem-qemu.gz -> amd64-usr/<NEW>/...    # Symlink (see below)
│   └── amd64-usr/
│       ├── <OLD_VER>/
│       │   ├── flatcar-podman.gz              # Official sysexts for old version
│       │   └── oem-qemu.gz
│       └── <NEW_VER>/
│           ├── flatcar-podman.gz              # Official sysexts for new version
│           └── oem-qemu.gz
└── sysext/                                    # Mounted as nginx /sysext/
    ├── tailscale-1.70.0-x86-64.raw            # Community sysexts
    └── tailscale-1.76.6-x86-64.raw
```

**Why two URL paths?**

- `/payload/amd64-usr/<VERSION>/` — serves official sysext `.gz` files.
  The initrd downloads these during first boot, constructing the URL
  from the OS version number.
- `/sysext/` — serves community sysext `.raw` files. Ignition downloads
  these during provisioning, and `systemd-sysupdate` checks here for
  newer versions.

**The `oem-qemu.gz` symlink:** During OS updates, `update_engine`'s
postinstall step looks for `oem-qemu.gz` at the payload root URL
(i.e., `<codebase>/oem-qemu.gz`), not in a version subdirectory. Create
a symlink at the payload root pointing to the new version's file:

```bash
ln -sf amd64-usr/<NEW_VER>/oem-qemu.gz payload/oem-qemu.gz
```

### 2. nginx Configuration

A minimal static file server:

```nginx
server {
    listen 8080;
    root /data;
    autoindex on;

    location /payload/ {
        # OS update payloads and official sysext .gz files
    }

    location /sysext/ {
        # Community sysext .raw files
    }
}
```

### 3. Nebraska Setup

Nebraska is the open-source Omaha server maintained by the Flatcar
project. It needs a PostgreSQL database and a package registration that
tells machines what version is available and where to download it.

**Register an update package:**

```bash
APP_ID="e96281a6-d1af-4bde-9a0a-97b76e56dc57"   # Flatcar's Omaha app ID

curl -X POST "http://localhost:8000/api/apps/${APP_ID}/packages" \
  -H 'Content-Type: application/json' \
  -d '{
    "type": 1,
    "version": "<NEW_VER>",
    "url": "http://<INFRA_IP>:8080/payload/",
    "filename": "flatcar_production_update.gz",
    "size": "<FILE_SIZE_BYTES>",
    "hash": "<SHA1_BASE64>",
    "flatcar_action": {
      "event": "postinstall",
      "sha256": "<SHA256_BASE64>",
      "needs_admin": false,
      "is_delta": false,
      "disable_payload_backoff": true
    },
    "arch": 1,
    "application_id": "'${APP_ID}'"
  }'
```

**Computing the hashes:**

```bash
# SHA1, base64-encoded
python3 -c "
import hashlib, base64
h = hashlib.sha1()
with open('flatcar_production_update.gz', 'rb') as f:
    while chunk := f.read(8192*1024):
        h.update(chunk)
print(base64.b64encode(h.digest()).decode())
"

# SHA256, base64-encoded
python3 -c "
import hashlib, base64
h = hashlib.sha256()
with open('flatcar_production_update.gz', 'rb') as f:
    while chunk := f.read(8192*1024):
        h.update(chunk)
print(base64.b64encode(h.digest()).decode())
"
```

**Register the OEM package file** (required for postinstall):

```sql
-- Run against Nebraska's PostgreSQL database
INSERT INTO package_file (package_id, name, hash, size, hash256)
VALUES ('<PKG_ID>', 'oem-qemu.gz', '<SHA1_BASE64>', '<SIZE>', '<SHA256_HEX>');
```

**Assign the package to a channel:**

```bash
curl -X PUT "http://localhost:8000/api/apps/${APP_ID}/channels/<CHANNEL_ID>" \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "stable",
    "package_id": "<PKG_ID>",
    "arch": 1,
    "application_id": "'${APP_ID}'"
  }'
```

After registration, verify with a test Omaha request:

```bash
curl -X POST "http://localhost:8000/v1/update/" \
  -H 'Content-Type: application/xml' \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" version="Flatcar-<OLD_VER>" updaterversion="0.4.7.1"
         installsource="scheduler" ismachine="1">
  <os version="Chateau" platform="CoreOS" sp="<OLD_VER>_x86_64"></os>
  <app appid="{e96281a6-d1af-4bde-9a0a-97b76e56dc57}" version="<OLD_VER>"
       track="stable" bootid="{test}" machineid="test">
    <updatecheck></updatecheck>
  </app>
</request>'
```

The response should contain your local payload URL, not an upstream one.

## Configuring Flatcar Machines

Each Flatcar machine needs three things configured to operate
air-gapped:

### 1. Point update_engine at Your Nebraska

In your Butane/Ignition config:

```yaml
storage:
  files:
    - path: /etc/flatcar/update.conf
      overwrite: true
      mode: 0644
      contents:
        inline: |
          SERVER=http://<INFRA_IP>:8000/v1/update/
          GROUP=stable
          REBOOT_STRATEGY=off
```

This tells `update_engine` to check your local Nebraska instead of
`update.release.flatcar-linux.net`.

### 2. Redirect First-Boot Sysext Downloads

Flatcar's initrd downloads official sysext images (podman, oem-qemu,
etc.) during first boot. By default, it fetches them from
`https://update.release.flatcar-linux.net`. To redirect this to your
local server, set the `flatcar.release_file_server_url` kernel command
line parameter.

**This must be set in the OEM GRUB configuration, and it must be
present before the first boot** — there is a chicken-and-egg problem
here. Ignition writes files during the initrd phase, but GRUB reads
`grub.cfg` before Ignition runs. If you write `grub.cfg` via Ignition,
it only takes effect on the *next* boot.

**Solution: pre-bake grub.cfg into the base image.**

Use `guestfish` (from `libguestfs-tools`) to write the OEM partition
before deploying the image:

```bash
guestfish -a flatcar_production_qemu_image.img -m /dev/sda6 \
  write /grub.cfg '# Flatcar GRUB settings

set oem_id="qemu"
set linux_append="$linux_append flatcar.autologin flatcar.release_file_server_url=http://<INFRA_IP>:8080/payload"
'
```

> **Note:** `/dev/sda6` is the OEM partition in standard Flatcar QEMU
> images. For bare-metal or other image formats, the partition number
> may differ. Use `guestfish -a <image> : run : list-filesystems` to
> find it.

With this in place, the initrd constructs download URLs like:

```
http://<INFRA_IP>:8080/payload/amd64-usr/<VERSION>/flatcar-podman.gz
```

...instead of reaching out to the internet.

It's good practice to also include the `grub.cfg` in your Ignition
config as a belt-and-suspenders measure. This ensures the setting
persists across image re-provisioning:

```yaml
    - path: /oem/grub.cfg
      overwrite: true
      mode: 0644
      contents:
        inline: |
          set oem_id="qemu"
          set linux_append="$linux_append flatcar.autologin flatcar.release_file_server_url=http://<INFRA_IP>:8080/payload"
```

### 3. Static Networking

Air-gapped environments typically don't have DHCP, or need predictable
IPs. Configure systemd-networkd via Ignition:

```yaml
    - path: /etc/systemd/network/00-static.network
      overwrite: true
      mode: 0644
      contents:
        inline: |
          [Match]
          Name=eth0 en*

          [Network]
          Address=192.168.122.101/24
          Gateway=192.168.122.1
          DNS=192.168.122.1
```

> **Note on boot networking:** During the initrd phase, Flatcar uses
> DHCP to get a temporary IP for Ignition and sysext downloads. After
> pivoting to the real root, systemd-networkd reads your static config.
> Your infrastructure server must be reachable from whatever IP the
> machine gets during DHCP, *and* from the final static IP. If you're on
> the same L2 segment, this just works.

## Working with System Extensions (sysexts)

Flatcar uses two categories of sysexts, and they're handled differently
in air-gapped environments:

### Official Sysexts

These are built in Flatcar's CI and distributed from the release
servers: **Docker, containerd, Podman, ZFS, Python, Incus**, etc.

They're enabled via `/etc/flatcar/enabled-sysext.conf`:

```yaml
    - path: /etc/flatcar/enabled-sysext.conf
      overwrite: true
      mode: 0644
      contents:
        inline: |
          podman
```

During first boot, the initrd reads this file, checks whether the
matching `.raw` file exists locally, and if not, downloads the `.gz`
from `${RELEASE_FILE_SERVER_URL}/amd64-usr/${VERSION}/`. With
`flatcar.release_file_server_url` set, this points at your local nginx.

**You must serve the `.gz` files for every OS version you support**,
because the download URL includes the version number. When you stage a
new OS version, also stage its sysext `.gz` files.

### Community Sysexts

These come from the
[sysext-bakery](https://github.com/flatcar/sysext-bakery) or are
built in-house: **Tailscale, wasmCloud, k3s**, etc.

They're distributed as `.raw` files and are *not* version-matched to
the OS. You download them via Ignition's `source:` directive and manage
updates via `systemd-sysupdate`:

```yaml
    # Download the sysext at first boot from local server
    - path: /opt/extensions/tailscale/tailscale-1.70.0-x86-64.raw
      mode: 0644
      contents:
        source: http://<INFRA_IP>:8080/sysext/tailscale-1.70.0-x86-64.raw

    # Configure sysupdate to check local server for newer versions
    - path: /etc/sysupdate.tailscale.d/tailscale.conf
      overwrite: true
      mode: 0644
      contents:
        inline: |
          [Transfer]
          Verify=false
          [Source]
          Type=url-file
          Path=http://<INFRA_IP>:8080/sysext/
          MatchPattern=tailscale-@v-%a.raw
          [Target]
          InstancesMax=3
          Type=regular-file
          Path=/opt/extensions/tailscale
          MatchPattern=tailscale-@v-%a.raw
          CurrentSymlink=/etc/extensions/tailscale.raw
```

> **About `Verify=false`:** In air-gapped environments, you typically
> can't reach a keyserver for GPG verification.  The integrity of the
> images is ensured by your transfer-into-the-gap process instead. If
> your air gap has a local GPG keyserver, you can configure verification.

### Swapping Built-in Sysexts

To replace Docker with Podman (or remove any built-in sysext), symlink
it to `/dev/null` via Ignition:

```yaml
  links:
    - path: /etc/extensions/docker-flatcar.raw
      target: /dev/null
      overwrite: true
    - path: /etc/extensions/containerd-flatcar.raw
      target: /dev/null
      overwrite: true
```

## Day-2 Operations: Adding New Versions

When a new Flatcar version or sysext becomes available, here's the
process to bring it into the air gap:

### Adding a New OS Version

1. **Download artifacts** (on an internet-connected machine):

   ```bash
   NEW_VER="<version>"
   wget https://update.release.flatcar-linux.net/amd64-usr/${NEW_VER}/flatcar_production_update.gz
   wget https://update.release.flatcar-linux.net/amd64-usr/${NEW_VER}/flatcar-podman.gz
   wget https://update.release.flatcar-linux.net/amd64-usr/${NEW_VER}/oem-qemu.gz
   # Download .gz for every official sysext you use
   ```

2. **Transfer into the air gap** via your approved mechanism.

3. **Stage the files** on the management host:

   ```bash
   # Place the update payload
   cp flatcar_production_update.gz /path/to/payload/

   # Place version-matched sysexts
   mkdir -p /path/to/payload/amd64-usr/${NEW_VER}/
   cp flatcar-podman.gz oem-qemu.gz /path/to/payload/amd64-usr/${NEW_VER}/

   # Update the oem-qemu.gz symlink at the payload root
   ln -sf amd64-usr/${NEW_VER}/oem-qemu.gz /path/to/payload/oem-qemu.gz
   ```

4. **Compute hashes** for the update payload:

   ```bash
   python3 -c "
   import hashlib, base64
   for algo in ('sha1', 'sha256'):
       h = hashlib.new(algo)
       with open('flatcar_production_update.gz', 'rb') as f:
           while chunk := f.read(8192*1024):
               h.update(chunk)
       print(f'{algo}: {base64.b64encode(h.digest()).decode()}')
   "
   ```

5. **Register in Nebraska:**
   - Create a new package via the API with the new version, size, and
     hashes
   - Insert the `oem-qemu.gz` package file record
   - Update the channel assignment to point at the new package

6. **Verify** with a test Omaha request. Machines will pick up the
   update on their next check cycle (or when manually triggered with
   `update_engine_client -update`).

### Adding a New Community Sysext

1. **Download the `.raw` file** on an internet-connected machine.

2. **Transfer into the air gap.**

3. **Place it in the sysext directory** on the management host:

   ```bash
   cp tailscale-1.80.0-x86-64.raw /path/to/sysext/
   ```

   That's it. If `systemd-sysupdate` is configured with a
   `MatchPattern` that matches the filename, machines will pick it up
   on their next timer cycle. The `InstancesMax` setting in the
   sysupdate config controls how many old versions are retained.

### Updating the Base Boot Image

If you need to provision new machines with a newer base version:

1. Download the new QEMU image (or ISO, PXE artifacts, etc.)
2. Pre-bake `grub.cfg` with `guestfish` (see above)
3. Update your provisioning workflow to use the new image

Existing machines don't need a new base image — they update in place
via the A/B partition mechanism.

## Verification

Test your air-gapped setup by disconnecting from the internet and
running through the full lifecycle:

1. **Boot a fresh machine** — it should get its IP (DHCP or static),
   download Ignition-specified files from local nginx, and come up with
   all sysexts loaded.

2. **Trigger an OS update** — `sudo update_engine_client -update` should
   download from your local Nebraska/nginx, not the internet.

3. **Reboot** — the machine should come up on the new version.

4. **Trigger a sysext update** — `sudo systemctl start
   sysupdate-<name>.service` should download the new `.raw` from local
   nginx.

Use `tcpdump` on the management host to verify zero traffic leaves the
local network during these operations:

```bash
# Watch for any non-local traffic during a VM boot
sudo tcpdump -i <bridge_interface> 'dst net not 192.168.122.0/24' -c 10
```

If you see connections to `update.release.flatcar-linux.net` or
`flatcar.cdn.cncf.io`, something isn't configured correctly.

## Reference Implementation

The [installfest-flatcar101](https://github.com/bexelbie/installfest-flatcar101)
repository contains a complete working example of this architecture,
built for a conference demo. It includes:

- Butane configs for two VMs (OS update demo + sysext demo)
- Infrastructure scripts (start, teardown, reset, Nebraska registration)
- An automated 29-check end-to-end test that validates the full
  lifecycle
- A `SETUP.md` with step-by-step instructions to reproduce the
  environment from scratch

## Troubleshooting

**update_engine fails with "postinstall command failed"**
— The postinstall step downloads `oem-qemu.gz` from the payload URL.
Make sure the symlink exists at the payload root (not just in the
version subdirectory).

**First boot hangs or takes very long**
— The initrd is probably trying to download sysexts from the internet.
Verify that `flatcar.release_file_server_url` is set in the kernel
command line (`cat /proc/cmdline` on a booted machine). If it's missing,
the `grub.cfg` wasn't baked into the image properly.

**`systemd-sysupdate` finds no updates**
— Check that the `.raw` filenames match the `MatchPattern` in your
sysupdate config. The pattern uses `@v` for version and `%a` for
architecture. Enable debug logging with
`SYSTEMD_LOG_LEVEL=debug systemd-sysupdate --component=<name> list`.

**Machines get DHCP during initrd but not the static IP afterward**
— Verify your `00-static.network` file has the correct `[Match]`
section. Use `Name=eth0 en*` to match both predictable and
unpredictable interface names.

**Nebraska returns "noupdate" to Omaha requests**
— Check that the package is assigned to the correct channel and
architecture. The Omaha request's `version` field must be *older* than
the registered package for Nebraska to offer an update.
