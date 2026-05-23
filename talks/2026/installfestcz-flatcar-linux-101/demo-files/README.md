---
title: "Recreating the Flatcar 101 Demos"
permalink: /talks/2026/installfestcz-flatcar-linux-101/demo/
layout: single
author_profile: true
classes: wide
---

This guide walks you through building both demos from scratch on a Linux
workstation. You need internet access during setup; the finished demos can run
offline.

Both demos use **Flatcar Container Linux stable 4459.2.4** running in QEMU.
They share a single base image and each get their own work copy.


## Prerequisites

Install these packages (Fedora names; adjust for your distro):

```
sudo dnf install qemu-system-x86 butane libvirt tmux
```

Enable libvirtd so the `virbr0` bridge is available:

```
sudo systemctl enable --now libvirtd
sudo virsh net-start default 2>/dev/null || true
```

You also need an SSH key pair. The Butane configs reference
`~/.ssh/id_ed25519`. If your key is different, edit the
`ssh_authorized_keys` line in each `.bu` file before transpiling.


## Directory layout

After setup you will have:

```
demo1/
  demo1.bu              ← Butane config (human-readable)
  demo1.ign             ← Ignition config (transpiled JSON)
  resources/
    index.html          ← Web page for the nginx container
    my-website.service  ← systemd unit for the container
  assets/
    flatcar_production_qemu_image.img   ← base image (downloaded)
    demo1-work.qcow2                    ← work copy (created by start.sh)
  start.sh  stop.sh  go.sh  status.sh  script.md

demo2/
  demo2.bu
  demo2.ign
  resources/
    policy.json         ← Podman container policy
    registries.conf     ← Podman registry search config
  assets/
    flatcar_production_qemu_image.img   ← symlink to demo1's copy
    demo2-work.qcow2                    ← work copy (created by start.sh)
  start.sh  stop.sh  go.sh  status.sh  script.md
```


## Step 1 — Download the Flatcar QEMU image

```
mkdir -p demo1/assets

curl -L -o demo1/assets/flatcar_production_qemu_image.img.bz2 \
  https://stable.release.flatcar-linux.net/amd64-usr/4459.2.4/flatcar_production_qemu_image.img.bz2

bunzip2 -k demo1/assets/flatcar_production_qemu_image.img.bz2
```

Create a symlink so demo2 shares the same base image:

```
mkdir -p demo2/assets
ln -s ../../demo1/assets/flatcar_production_qemu_image.img \
  demo2/assets/flatcar_production_qemu_image.img
```


## Step 2 — Set up Demo 1 (Provisioning)

Demo 1 shows: Butane/Ignition provisioning, a Docker container serving a web
page, and immutability (dm-verity, read-only /usr, A/B partitions).

### 2a. Create resource files

Create `demo1/resources/index.html`:

```html
<!DOCTYPE html>
<html>
<head><title>Hello from Flatcar!</title></head>
<body>
<h1>Hello from Flatcar Container Linux!</h1>
<p>This page is served by a Docker container,
configured at first boot via Ignition.</p>
</body>
</html>
```

Create `demo1/resources/my-website.service`:

```ini
[Unit]
Description=My Website
After=docker.service
Requires=docker.service
[Service]
ExecStartPre=-/usr/bin/docker rm -f my-website
ExecStart=/usr/bin/docker run --name my-website \
  -p 8000:80 \
  -v /var/www/index.html:/usr/share/nginx/html/index.html:ro \
  docker.io/library/nginx:alpine
ExecStop=/usr/bin/docker stop my-website
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
```

### 2b. Create the Butane config

Create `demo1/demo1.bu` — edit the SSH key to match yours:

```yaml
variant: flatcar
version: 1.1.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - YOUR_SSH_PUBLIC_KEY_HERE
storage:
  files:
    - path: /etc/hostname
      overwrite: true
      mode: 0644
      contents:
        inline: flatcar-demo1
    - path: /etc/systemd/network/00-static.network
      overwrite: true
      mode: 0644
      contents:
        inline: |
          [Match]
          Name=eth0 en*

          [Network]
          Address=192.168.122.103/24
          Gateway=192.168.122.1
          DNS=192.168.122.1
    - path: /var/www/index.html
      overwrite: true
      mode: 0644
      contents:
        local: resources/index.html
systemd:
  units:
    - name: my-website.service
      enabled: true
      contents_local: resources/my-website.service
    - name: update-engine.service
      mask: true
```

### 2c. Transpile

```
cd demo1
butane --strict --files-dir . demo1.bu > demo1.ign
cd ..
```

### 2d. Pre-stage the work image

The first boot pulls `nginx:alpine` from Docker Hub, which takes a while.
Pre-stage so the demo runs fast:

```
cd demo1
./start.sh
```

Wait for it to boot (about 30 seconds on first boot), then SSH in:

```
./go.sh
```

Inside the VM, confirm the container is running:

```
docker ps          # should show my-website / nginx:alpine
curl localhost:8000 # should show the HTML page
exit
```

Shut down cleanly to preserve the cached container image:

```
./stop.sh
```

The file `demo1/assets/demo1-work.qcow2` now contains the pre-staged state.
Subsequent boots reuse this image and start in about 7 seconds.


## Step 3 — Set up Demo 2 (System Extensions)

Demo 2 shows: disabling default extensions (Docker, containerd), live-loading
a Podman sysext at runtime, and removing it — all without rebooting.

### 3a. Create resource files

Create `demo2/resources/policy.json`:

```json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}
```

Create `demo2/resources/registries.conf`:

```
# Default registries to search for unqualified image names
unqualified-search-registries = ['registry.fedoraproject.org', 'docker.io', 'quay.io']
```

### 3b. Create the Butane config

Create `demo2/demo2.bu` — edit the SSH key to match yours:

```yaml
variant: flatcar
version: 1.1.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - YOUR_SSH_PUBLIC_KEY_HERE
storage:
  files:
    - path: /etc/hostname
      overwrite: true
      mode: 0644
      contents:
        inline: flatcar-demo2
    - path: /etc/systemd/network/00-static.network
      overwrite: true
      mode: 0644
      contents:
        inline: |
          [Match]
          Name=eth0 en*

          [Network]
          Address=192.168.122.104/24
          Gateway=192.168.122.1
          DNS=192.168.122.1
    - path: /etc/containers/policy.json
      overwrite: true
      mode: 0644
      contents:
        local: resources/policy.json
    - path: /etc/containers/registries.conf
      overwrite: true
      mode: 0644
      contents:
        local: resources/registries.conf
  links:
    - path: /etc/extensions/docker-flatcar.raw
      target: /dev/null
      overwrite: true
    - path: /etc/extensions/containerd-flatcar.raw
      target: /dev/null
      overwrite: true
systemd:
  units:
    - name: update-engine.service
      mask: true
```

### 3c. Transpile

```
cd demo2
butane --strict --files-dir . demo2.bu > demo2.ign
cd ..
```

### 3d. Pre-stage the work image

Boot the VM, then download the Podman sysext and stash it:

```
cd demo2
./start.sh
./go.sh
```

Inside the VM:

```
# Download the Podman sysext for this Flatcar version
sudo mkdir -p /opt/sysexts /var/tmp/sysext-dl
sudo download_sysext \
  -u "https://update.release.flatcar-linux.net/amd64-usr/4459.2.4/flatcar-podman.gz" \
  -p /usr/share/update_engine/update-payload-key.pub.pem \
  -o /var/tmp/sysext-dl \
  -n flatcar-podman.raw

sudo mv /var/tmp/sysext-dl/flatcar-podman.raw /opt/sysexts/
sudo rm -rf /var/tmp/sysext-dl
```

Verify the demo flow works:

```
# Confirm no container runtimes
docker --version     # command not found
podman --version     # command not found

# Load Podman
sudo mkdir -p /var/lib/extensions
sudo cp /opt/sysexts/flatcar-podman.raw /var/lib/extensions/
sudo systemd-sysext refresh
podman --version     # podman version 5.5.2

# Remove Podman
sudo rm /var/lib/extensions/flatcar-podman.raw
sudo systemd-sysext refresh
podman --version     # No such file or directory

exit
```

Shut down:

```
./stop.sh
```

The file `demo2/assets/demo2-work.qcow2` now contains the pre-staged state.


## Step 4 — Copy the helper scripts

Each demo directory needs four scripts. They are identical in structure
between demos — only the IP address, MAC address, image paths, and tmux
session name differ.

| Script     | Demo 1              | Demo 2              |
|------------|----------------------|----------------------|
| IP address | 192.168.122.103      | 192.168.122.104      |
| MAC        | 52:54:00:fc:03:01    | 52:54:00:fc:04:01    |
| Image      | demo1-work.qcow2     | demo2-work.qcow2     |
| tmux       | demo1                | demo2                |

The scripts are included in this repository under `demo1/` and `demo2/`.
Make them executable:

```
chmod +x demo1/*.sh demo2/*.sh
```

What each script does:

- **start.sh** — Boots the VM in the background, creates a tmux session for
  dual-screen presentation. Prints the `tmux attach` command.
- **stop.sh** — SSH shutdown with kill fallback. Destroys the tmux session.
- **go.sh** — Waits for the VM to accept SSH, then connects.
- **status.sh** — Shows whether the VM is running and basic guest info.


## Network assumptions

Both VMs use static IPs on the `virbr0` bridge (192.168.122.0/24), which
libvirt creates by default. If your libvirt network uses a different subnet,
edit the `Address=` and `Gateway=` lines in each `.bu` file and retranspile.

The static IPs avoid DHCP race conditions and make SSH predictable. The MACs
are chosen to not collide with anything.


## SSH tips

If your SSH agent has many keys loaded, Flatcar's sshd may reject you with
"Too many authentication failures" before trying the right key. All the
helper scripts use `-o IdentitiesOnly=yes -i ~/.ssh/id_ed25519` to avoid
this. If you SSH manually, use the same flags:

```
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519 core@192.168.122.103
```


## Resetting a demo

To start fresh, delete the work image and the start script will recreate it
from the base image:

```
rm demo1/assets/demo1-work.qcow2
# or
rm demo2/assets/demo2-work.qcow2
```

Then re-run the pre-staging steps (2d or 3d above).


## What the demos show

### Demo 1 — Provisioning a Server

1. Walk through the Butane YAML (human-readable config)
2. Show the transpiled Ignition JSON (what the machine reads)
3. curl the web page from the host → container is running
4. `docker ps` → nginx container
5. `sudo touch /usr/test` → "Read-only file system" (immutability)
6. `sudo mount -o remount,rw /usr` → fails (dm-verity)
7. `sudo dmsetup table | grep verity` → shows verity with sha256
8. `sudo cgpt show /dev/vda | grep -A3 USR` → A/B partition layout

### Demo 2 — System Extensions

1. `docker --version` / `podman --version` → both missing
2. Walk through the Butane YAML showing null-links
3. `systemd-sysext status` → only oem-qemu loaded
4. Copy sysext → `systemd-sysext refresh` → `podman --version` works
5. Remove sysext → `systemd-sysext refresh` → podman gone
6. Discussion: official vs community sysexts, the sysext-bakery
