# Kubernetes Sysext Demo — Flatcar + Fedora CoreOS

This experiment demonstrates a single claim:

> **Both Flatcar Container Linux and Fedora CoreOS can run Kubernetes sourced
> entirely from a systemd sysext — nothing needs to be compiled into either
> OS image.**

A standard Kubernetes cluster is formed across four nodes running two different
operating systems.  Every worker gets its `kubelet`, `kubeadm`, and `kubectl`
from a sysext dropped in at boot and managed by `systemd-sysupdate`.  The
control plane never touches the workers' OS packages.

---

## The cluster

| Node | OS | Kubernetes source | Starting version |
|---|---|---|---|
| `flatcar-cp` | Flatcar Container Linux | Flatcar bakery (built-in) | v1.33.2 |
| `worker-1` | Flatcar Container Linux | Flatcar bakery sysext | v1.33.2 |
| `worker-2` | Fedora CoreOS | Flatcar bakery sysext | v1.33.2 |
| `worker-3` | Fedora CoreOS | [fedora-sysexts/fedora][fedora-sysexts] sysext | v1.33.10 |

`worker-1` and `worker-2` demonstrate that sysexts are not Flatcar-specific
infrastructure — any OS that ships `systemd-sysext` and `systemd-sysupdate`
can participate.  FCoOS ships both in its base image but provides no Kubernetes
definitions; those are supplied here.

`worker-3` uses a second, independent sysext source to show that the
upgrade mechanism is not tied to Flatcar's bakery: the
[fedora-sysexts project][fedora-sysexts] publishes Fedora-packaged Kubernetes
extensions from `extensions.fcos.fr`.

[fedora-sysexts]: https://github.com/fedora-sysexts/fedora

---

## What is working

- Four-node mixed-OS cluster boots from scratch with a single `./setup.sh`
- Kubernetes binaries on all four nodes come from sysexts — zero manual package installs
- `systemd-sysupdate` drives upgrades on every node without rebooting
- Rolling upgrades (drain → update → uncordon) keep the cluster live throughout
- Flatcar workers upgrade natively via the built-in bakery sysupdate mechanism
- FCoOS workers upgrade via the same `systemd-sysupdate` tooling wired up by the Butane config
- Workloads schedule across both OSes transparently
- Headlamp dashboard deployed on the control plane for visual cluster inspection

---

## What is still open

- **Reboot safety on FCoOS workers**: after a node reboots, the `mount --bind /usr /usr`
  and `systemd-sysext merge` steps need to run again before kubelet can start.
  The current setup only does this on first boot.  A production deployment would
  need a persistent boot-time service or a systemd drop-in on `systemd-sysext.service`.

- **SELinux**: both FCoOS workers run with SELinux in Permissive mode after each
  sysext merge because merged overlayfs files get `unlabeled_t` context.
  Enforcing mode blocks kubelet exec.  The correct fix is `restorecon` on the
  merged tree or a targeted SELinux policy; `setenforce 0` is used here for
  simplicity.

- **Token expiry**: the Headlamp service-account token is generated with a 24-hour
  TTL at setup time.  Re-run `kubectl create token headlamp -n headlamp` on the
  control plane to refresh it.

---

## Initial setup

### System prerequisites

The following must be installed on the host before anything else:

| Tool | Purpose |
|---|---|
| `qemu-system-x86_64`, `qemu-img` | VM execution and disk image management |
| `butane` | Compiles Butane configs into Ignition JSON |
| `curl`, `python3` | Image downloads and local file server |
| `libvirt` with default network | NAT bridge (`virbr0`) and DHCP for the VMs |

The libvirt default network must be running before `./setup.sh`:

```bash
sudo virsh net-start default   # if not already active
sudo virsh net-autostart default
```

### SSH key

`setup.sh` injects `~/.ssh/id_ed25519.pub` into every VM and uses the
corresponding private key for all SSH connections.  If you use a different key,
set `SSH_KEY_PATH` in `common.env`.

```bash
# Generate a key if you don't have one
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

### Download the sysext cache (one-time, ~715 MB)

The VMs are air-gapped from the internet during the demo — all sysext files
are served from a local HTTP file server on `virbr0`.  Download them once
before the first run:

```bash
./cache-sysexts.sh
```

This fetches five files into `sysext-cache/` (excluded from git):

| File | Size | Used by |
|---|---|---|
| `flatcar/kubernetes-v1.33.2-x86-64.raw` | ~112 MB | worker-1, worker-2 (initial) |
| `flatcar/kubernetes-v1.33.10-x86-64.raw` | ~112 MB | worker-1, worker-2 (Step A upgrade) |
| `flatcar/kubernetes-v1.33.12-x86-64.raw` | ~113 MB | worker-1, worker-2 (Step B upgrade) |
| `fedora/kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw` | ~185 MB | worker-3 (initial) |
| `fedora/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw` | ~186 MB | worker-3 (Step B upgrade) |

The base VM images (Flatcar and Fedora CoreOS QEMU images) are downloaded
automatically by `./setup.sh` on first run and cached in `images/`.

---

## Running the demo

```bash
# First time only: download sysext files (~715 MB, takes a few minutes)
./cache-sysexts.sh

# Start the cluster — boots all four VMs and leaves them ready (~5–8 minutes)
./setup.sh

# SSH into any node by name
./go.sh flatcar-cp
./go.sh worker-1
./go.sh worker-2
./go.sh worker-3

# Print cluster status and the Headlamp URL
./status.sh

# Walk through the live upgrade demo
# See update-script.md for the full step-by-step

# Tear everything down
./stop.sh
```

`./setup.sh` prints the Headlamp URL and token when it finishes.
Headlamp is at **http://192.168.122.10:30080** — use it to view nodes and
pods, and to drain/uncordon nodes during the upgrade demo.

`./stop.sh` kills all VMs and removes TAP devices.  Disk overlays in `images/`
are preserved so you can inspect them, but they are always recreated fresh by
the next `./setup.sh` run.  The sysext cache in `sysext-cache/` is never
touched by stop or setup.

