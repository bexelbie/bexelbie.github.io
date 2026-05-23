# Flatcar 101 Demo — Fresh Laptop Setup

Instructions to build out the full demo environment on a fresh Fedora
Workstation install. Requires internet for all download/pull steps.

## Prerequisites

Fedora Workstation (tested on Fedora 43). Needs:

```bash
sudo dnf install -y qemu-system-x86-core podman bzip2 openssh-clients wget2-wget libvirt libguestfs-tools
```

Verify KVM is available:

```bash
ls -l /dev/kvm
```

### libvirt / bridge networking

VMs use TAP networking via libvirt's virbr0 bridge for near-native
speed (needed for the ~447 MB OS update download during the demo).

```bash
sudo systemctl enable --now libvirtd
# Verify virbr0 is up:
ip addr show virbr0   # should show 192.168.122.1/24
```

The QEMU bridge helper needs to be allowed to use virbr0:

```bash
echo 'allow virbr0' | sudo tee /etc/qemu/bridge.conf
```

Open Nebraska and nginx ports in the libvirt firewall zone so VMs can
reach host services:

```bash
sudo firewall-cmd --zone=libvirt --add-port=8000/tcp --permanent
sudo firewall-cmd --zone=libvirt --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

## 1. Generate SSH key (if needed)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "$(whoami)@flatcar-demo"
```

Update the SSH public key in `vm1-plain.bu` and `vm2-sysext.bu` if it
differs from the one already there, then retranspile (step 4).

## 2. Download Flatcar artifacts

Two alpha versions: "old" (4515.0.0) to boot from, "new" (4628.0.0) as
the update target.

```bash
cd installfest-flatcar101
mkdir -p artifacts/{old-4515,new-4628/amd64-usr/4515.0.0,new-4628/amd64-usr/4628.0.0,sysext}

# --- Old version (boot image) ---
OLD_VER="4515.0.0"
wget -P artifacts/old-4515/ \
  "https://alpha.release.flatcar-linux.net/amd64-usr/${OLD_VER}/flatcar_production_qemu_image.img.bz2"
bunzip2 -k artifacts/old-4515/flatcar_production_qemu_image.img.bz2

# --- New version (update payload — served by nginx) ---
NEW_VER="4628.0.0"
wget -P artifacts/new-4628/ \
  "https://update.release.flatcar-linux.net/amd64-usr/${NEW_VER}/flatcar_production_update.gz"

# --- Sysext .gz files for initrd downloads (version-matched, both versions) ---
# The initrd-setup-root-after-ignition service downloads these via
# flatcar.release_file_server_url at first boot. nginx serves them
# from /payload/amd64-usr/<VERSION>/.
for VER in "${OLD_VER}" "${NEW_VER}"; do
  wget -P "artifacts/new-4628/amd64-usr/${VER}/" \
    "https://update.release.flatcar-linux.net/amd64-usr/${VER}/flatcar-podman.gz" \
    "https://update.release.flatcar-linux.net/amd64-usr/${VER}/oem-qemu.gz"
done

# oem-qemu.gz symlink at payload root — update_engine's postinstall
# step looks for it at <codebase>/oem-qemu.gz (not in a version subdir)
ln -sf "amd64-usr/${NEW_VER}/oem-qemu.gz" artifacts/new-4628/oem-qemu.gz

# --- Tailscale sysext images (old + new for update demo) ---
wget -P artifacts/sysext/ \
  "https://github.com/flatcar/sysext-bakery/releases/download/latest/tailscale-1.70.0-x86-64.raw" \
  "https://github.com/flatcar/sysext-bakery/releases/download/latest/tailscale-1.76.6-x86-64.raw" \
  "https://github.com/flatcar/sysext-bakery/releases/download/latest/tailscale.conf" \
  "https://github.com/flatcar/sysext-bakery/releases/download/latest/SHA256SUMS"
```

## 3. Bake grub.cfg into the base image

The base image needs a custom OEM `grub.cfg` that sets
`flatcar.release_file_server_url` to point sysext downloads at our
local nginx instead of the internet. This must be baked into the image
because GRUB reads it before Ignition runs.

Requires `libguestfs-tools`:

```bash
sudo dnf install -y libguestfs-tools
```

```bash
guestfish -a artifacts/old-4515/flatcar_production_qemu_image.img -m /dev/sda6 \
  write /grub.cfg '# Flatcar GRUB settings\n\nset oem_id="qemu"\nset linux_append="$linux_append flatcar.autologin flatcar.release_file_server_url=http://192.168.122.1:8080/payload"\n'
```

Verify:

```bash
guestfish --ro -a artifacts/old-4515/flatcar_production_qemu_image.img -m /dev/sda6 cat /grub.cfg
```

## 4. Pull container images

All images must be cached locally for offline use.

```bash
podman pull quay.io/coreos/butane:release
podman pull ghcr.io/flatcar/nebraska:latest
podman pull docker.io/library/postgres:17
podman pull docker.io/library/nginx:alpine
```

## 5. Transpile Ignition configs

```bash
podman run --rm -i quay.io/coreos/butane:release --strict < vm1-plain.bu > vm1-plain.ign
podman run --rm -i quay.io/coreos/butane:release --strict < vm2-sysext.bu > vm2-sysext.ign
```

## 6. Start the infrastructure pod

```bash
./infra/start-infra.sh
```

The pod uses `--network=host` so containers bind directly to host ports,
accessible from both localhost and the virbr0 bridge (192.168.122.1):

- **Nebraska** on port 8000 (Omaha API + web UI)
- **nginx** on port 8080 (update payloads + sysext images)

Verify:

```bash
curl -4 http://localhost:8000/health     # should print OK
curl -4 http://localhost:8080/           # should list payload/ and sysext/
```

## 7. Register update package in Nebraska

```bash
./infra/setup-nebraska.sh
```

This registers Flatcar 4628.0.0 as the stable update target and points
the payload URL at the local nginx (`http://192.168.122.1:8080/payload/`).

## 8. Boot and test VMs

VMs use static IPs on 192.168.122.0/24 via systemd-networkd:
- **VM1:** 192.168.122.101
- **VM2:** 192.168.122.102

**VM 1 — plain Flatcar (OS update demo):**

```bash
./infra/start-vm1.sh          # SSH: ssh core@192.168.122.101
# Inside VM:
sudo update_engine_client -update     # downloads from local nginx
sudo update_engine_client -status     # watch progress
sudo reboot                           # boots into 4628.0.0
```

**VM 2 — Flatcar + Podman + Tailscale sysext:**

```bash
./infra/start-vm2.sh          # SSH: ssh core@<VM2_IP>
# Inside VM:
docker version                                    # → not found (nulled out)
podman --version                                  # → podman version 5.3.0
/usr/local/bin/tailscale version                  # shows 1.70.0
sudo systemctl start sysupdate-tailscale.service  # downloads 1.76.6 + refreshes
/usr/local/bin/tailscale version                  # shows 1.76.6
```

A timer (`sysupdate-tailscale.timer`) also checks for updates automatically
every hour (first check 5 min after boot).

## 9. Teardown / Reset

```bash
./infra/teardown.sh       # stops the infra pod
./infra/reset-demo.sh     # removes VM images, restarts infra, re-run setup-nebraska.sh
./infra/e2e-test.sh       # full automated end-to-end test (29 checks)
```

---

## Scripts reference

| Script | Purpose |
|--------|---------|
| `infra/start-infra.sh` | Create pod with PostgreSQL + Nebraska + nginx |
| `infra/setup-nebraska.sh` | Register 4628.0.0 package, assign to stable channel |
| `infra/start-vm1.sh` | Boot VM1 (plain, bridge/TAP on virbr0) |
| `infra/start-vm2.sh` | Boot VM2 (Podman + Tailscale sysext, bridge/TAP) |
| `infra/teardown.sh` | Stop and remove the infra pod |
| `infra/reset-demo.sh` | Full reset: remove VM images, restart infra |
| `infra/e2e-test.sh` | Automated end-to-end test (29 checks) |

## Version inventory

| Artifact | Version | Status |
|----------|---------|--------|
| Flatcar (old/boot) | 4515.0.0 | ✅ Downloaded |
| Flatcar (new/update payload) | 4628.0.0 | ✅ Downloaded |
| Podman sysext (.gz, both versions) | 4515.0.0 + 4628.0.0 | ✅ Downloaded |
| OEM QEMU sysext (.gz, both versions) | 4515.0.0 + 4628.0.0 | ✅ Downloaded |
| Tailscale sysext (old) | 1.70.0 | ✅ Downloaded |
| Tailscale sysext (new) | 1.76.6 | ✅ Downloaded |
| Nebraska | latest | ✅ Pulled |
| PostgreSQL | 17 | ✅ Pulled |
| nginx | alpine | ✅ Pulled |
| Butane | release | ✅ Pulled |

## Notes

- **Networking:** VMs use TAP/bridge networking via libvirt's virbr0 for
  near-native throughput. The pod uses `--network=host` so containers
  are reachable from VMs at 192.168.122.1 (the bridge IP).
- **Firewall:** Ports 8000/tcp and 8080/tcp must be open in the `libvirt`
  firewalld zone for VMs to reach Nebraska and nginx.
- **IPv6 quirk:** `curl` defaults to IPv6 on localhost. Use `curl -4` when
  testing services locally.
- **Nebraska API:** Lives at `/api/apps` (not `/api/v1/apps`). The Omaha
  endpoint for VMs is `http://192.168.122.1:8000/v1/update/`.
- **`systemd-sysupdate`** is at `/usr/lib/systemd/systemd-sysupdate` (not
  in PATH by default on Flatcar).
- **Tailscale binary** lands at `/usr/local/bin/tailscale` via the sysext.
- **VM IPs** are statically assigned via systemd-networkd in the Butane configs:
  VM1 = `192.168.122.101`, VM2 = `192.168.122.102`.
