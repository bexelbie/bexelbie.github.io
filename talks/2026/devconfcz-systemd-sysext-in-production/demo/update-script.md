# Demo Script: Kubernetes Sysexts on Flatcar and Fedora CoreOS

This document walks through the full demo: verifying that each node is running
Kubernetes from a systemd sysext, then performing a live rolling upgrade one
node at a time.  SSH is used only for on-node sysext commands.  Everything
else — viewing nodes and pods, draining, and uncordoning — is done through
Headlamp at **http://192.168.122.10:30080**.

The cluster has four nodes:

| Node | OS | Sysext source | Initial version |
|---|---|---|---|
| flatcar-cp | Flatcar Container Linux | Flatcar bakery (built-in) | v1.33.2 |
| worker-1 | Flatcar Container Linux | Flatcar bakery (built-in) | v1.33.2 |
| worker-2 | Fedora CoreOS | Flatcar bakery sysext | v1.33.2 |
| worker-3 | Fedora CoreOS | fedora-sysexts/fedora sysext | v1.33.10 |

The upgrade story:
- **Step A**: upgrade worker-1 and worker-2 from v1.33.2 → v1.33.10 (all three workers now match)
- **Step B**: upgrade worker-1, worker-2, and worker-3 from v1.33.10 → v1.33.12 (full convergence)

> **Note on version specifiers**: For the Flatcar bakery sysext format
> (`kubernetes-v1.33.@v-%a.raw`), `systemd-sysupdate` uses just the patch
> number as the version identifier — `10` means v1.33.10, `12` means v1.33.12.

---

## 0. Cluster overview

**In Headlamp** (http://192.168.122.10:30080):
- Go to **Cluster → Nodes** — verify all four nodes show `Ready`
- The OS column shows two Flatcar nodes and two Fedora CoreOS nodes
- Go to **Workloads → Pods** — verify three `demo-nginx` pods are `Running`, one on each worker

---

## 1. Verify sysext is installed — Flatcar nodes

Flatcar ships `systemd-sysupdate` and sysext support out of the box.
The Kubernetes sysext is placed and activated automatically during first boot.

### Control plane

```bash
ssh core@192.168.122.10

systemd-sysext status
# Expected: kubernetes extension is listed as "merged"

kubectl version --short
# Client and server should both show v1.33.2

exit
```

### worker-1 (Flatcar)

```bash
ssh core@192.168.122.11

systemd-sysext status
# Expected: kubernetes extension is listed as "merged"

kubelet --version
# Expected: Kubernetes v1.33.2

# Show the sysupdate transfer configuration that makes upgrades possible
cat /etc/sysupdate.kubernetes.d/kubernetes-v1.33.transfer

exit
```

---

## 2. Verify sysext is installed — Fedora CoreOS nodes

FCoOS ships `systemd-sysext` and `systemd-sysupdate` binaries but provides
**no Kubernetes extensions and no sysupdate definitions** in its base image.
Everything below was installed by our Butane config on first boot.

> **Caveat — composefs / `/usr` bind-mount**: FCoOS 44+ uses composefs for the
> root filesystem.  `/usr` is part of the root overlay and is not a separate
> mount point.  `systemd-sysext merge` requires `/usr` to be a mountable
> overlayfs target, so a self-referential bind-mount (`mount --bind /usr /usr`)
> is performed before the first merge.  This persists until the node reboots.

> **Caveat — SELinux**: After `systemd-sysext merge`, the overlayfs files
> inherit `unlabeled_t` context.  In Enforcing mode, systemd cannot exec those
> binaries (it returns status=203/EXEC).  SELinux is set to Permissive after
> every merge.  A production deployment would use `restorecon` or a custom
> SELinux policy instead.

### worker-2 (FCoOS, Flatcar bakery sysext)

```bash
ssh core@192.168.122.12

systemd-sysext status
# Expected: kubernetes extension is listed as "merged"
# The sysext came from the Flatcar bakery

kubelet --version
# Expected: Kubernetes v1.33.2

# Show where the versioned file lives and the symlink sysext follows
ls -la /opt/extensions/kubernetes/
ls -la /var/lib/extensions/kubernetes.raw

# Show the sysupdate transfer configuration
cat /etc/sysupdate.d/kubernetes.transfer

# Confirm SELinux is permissive (set after merge during first boot)
getenforce
# Expected: Permissive

exit
```

### worker-3 (FCoOS, fedora-sysexts sysext)

```bash
ssh core@192.168.122.13

systemd-sysext status
# Expected: kubernetes-1.33 extension is listed as "merged"
# The sysext came from extensions.fcos.fr — Fedora-packaged Kubernetes

kubelet --version
# Expected: Kubernetes v1.33.10

# Show where the versioned file lives and the symlink sysext follows
ls -la /var/lib/extensions.d/
ls -la /var/lib/extensions/kubernetes-1.33.raw

# Show the sysupdate transfer configuration
cat /etc/sysupdate.kubernetes-1.33.d/kubernetes-1.33.transfer

# Confirm SELinux is permissive (set after merge during first boot)
getenforce
# Expected: Permissive

exit
```

---

## 3. Step A — Upgrade worker-1 and worker-2 to v1.33.10

After this step all three workers share the same version, sourced from three
different sysext providers.

### worker-1 (Flatcar, v1.33.2 → v1.33.10)

**In Headlamp** — drain worker-1 (this cordons and evicts in one action):
- Go to **Cluster → Nodes**, click **worker-1**
- Click **Drain** — confirm when prompted
- The node status changes to `SchedulingDisabled`; watch the `demo-nginx` pod reschedule in **Workloads → Pods**

```bash
ssh core@192.168.122.11

# Fetch v1.33.10.  Flatcar uses -C to select the sysupdate component.
# The binary is not in $PATH; use the full path.
# Version specifier is the patch number only: 10 = v1.33.10
sudo /usr/lib/systemd/systemd-sysupdate -C kubernetes update 10
# Expected: downloads kubernetes-v1.33.10-x86-64.raw, updates the CurrentSymlink

# Hot-swap the extension without rebooting
sudo systemd-sysext unmerge
sudo systemd-sysext merge

# Restart kubelet so it picks up the new binary
sudo systemctl restart kubelet

kubelet --version
# Expected: Kubernetes v1.33.10

exit
```

**In Headlamp** — uncordon worker-1:
- Go to **Cluster → Nodes**, click **worker-1**
- Click **Uncordon**
- The node returns to `Ready`; the version shown updates to `v1.33.10`

### worker-2 (FCoOS, Flatcar bakery sysext, v1.33.2 → v1.33.10)

**In Headlamp** — drain worker-2:
- Go to **Cluster → Nodes**, click **worker-2**
- Click **Drain** — confirm when prompted

```bash
ssh core@192.168.122.12

# Unmerge first so the raw file is not in use while sysupdate replaces it
sudo systemd-sysext unmerge

# Fetch v1.33.10.  The sysupdate conf is in /etc/sysupdate.d/ — no -C needed.
sudo /usr/lib/systemd/systemd-sysupdate update 10
# Expected: downloads kubernetes-v1.33.10-x86-64.raw, updates the CurrentSymlink

# The composefs bind-mount on /usr persists from boot, so merge works directly.
# If this node has been rebooted since first boot, re-apply it first:
#   sudo mount --bind /usr /usr
sudo systemd-sysext merge

# SELinux must be set permissive again after every merge
sudo setenforce 0

sudo systemctl restart kubelet

kubelet --version
# Expected: Kubernetes v1.33.10

# Confirm SELinux is still permissive
getenforce
# Expected: Permissive

exit
```

**In Headlamp** — uncordon worker-2:
- Go to **Cluster → Nodes**, click **worker-2**
- Click **Uncordon**

At this point all three workers — running on two different operating systems
and sourcing their sysext from two different providers — show the same version
in Headlamp's Nodes view.

---

## 4. Step B — Upgrade all three workers to v1.33.12

### worker-1 (Flatcar, v1.33.10 → v1.33.12)

**In Headlamp** — drain worker-1:
- **Cluster → Nodes** → **worker-1** → **Drain**

```bash
ssh core@192.168.122.11

sudo /usr/lib/systemd/systemd-sysupdate -C kubernetes update 12
# Expected: downloads kubernetes-v1.33.12-x86-64.raw, updates the CurrentSymlink

sudo systemd-sysext unmerge
sudo systemd-sysext merge
sudo systemctl restart kubelet

kubelet --version
# Expected: Kubernetes v1.33.12

exit
```

**In Headlamp** — **Cluster → Nodes** → **worker-1** → **Uncordon**

### worker-2 (FCoOS, Flatcar bakery sysext, v1.33.10 → v1.33.12)

**In Headlamp** — drain worker-2:
- **Cluster → Nodes** → **worker-2** → **Drain**

```bash
ssh core@192.168.122.12

sudo systemd-sysext unmerge
sudo /usr/lib/systemd/systemd-sysupdate update 12
# Expected: downloads kubernetes-v1.33.12-x86-64.raw, updates the CurrentSymlink

# sudo mount --bind /usr /usr   # only if rebooted since first boot
sudo systemd-sysext merge
sudo setenforce 0
sudo systemctl restart kubelet

kubelet --version
# Expected: Kubernetes v1.33.12

getenforce
# Expected: Permissive

exit
```

**In Headlamp** — **Cluster → Nodes** → **worker-2** → **Uncordon**

### worker-3 (FCoOS, fedora-sysexts, v1.33.10 → v1.33.12)

**In Headlamp** — drain worker-3:
- **Cluster → Nodes** → **worker-3** → **Drain**

```bash
ssh core@192.168.122.13

# Unmerge first so the raw file is not in use while sysupdate replaces it
sudo systemd-sysext unmerge

# Fetch the latest version using the kubernetes-1.33 component.
# This reads /etc/sysupdate.kubernetes-1.33.d/ and downloads from the file
# server, then updates /var/lib/extensions/kubernetes-1.33.raw.
sudo /usr/lib/systemd/systemd-sysupdate --component kubernetes-1.33 update
# Expected: downloads kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw

# Verify the symlink was updated
ls -la /var/lib/extensions/kubernetes-1.33.raw
# Expected: points to the 1.33.12 file

# sudo mount --bind /usr /usr   # only if rebooted since first boot
sudo systemd-sysext merge
sudo setenforce 0
sudo systemctl restart kubelet

kubelet --version
# Expected: Kubernetes v1.33.12

getenforce
# Expected: Permissive

exit
```

**In Headlamp** — **Cluster → Nodes** → **worker-3** → **Uncordon**

---

## 5. Final cluster state

**In Headlamp** — go to **Cluster → Nodes**:

| Node | Status | Version | OS |
|---|---|---|---|
| flatcar-cp | Ready | v1.33.2 | Flatcar Container Linux |
| worker-1 | Ready | v1.33.12 | Flatcar Container Linux |
| worker-2 | Ready | v1.33.12 | Fedora CoreOS |
| worker-3 | Ready | v1.33.12 | Fedora CoreOS |

Go to **Workloads → Pods** — all three `demo-nginx` pods are `Running`,
rescheduled back across the workers.

The control plane remains at v1.33.2 (CP↔worker skew of one minor version is
supported by Kubernetes).  All three workers are running the same Kubernetes
version — sourced from sysexts, nothing compiled into either OS image.

---

## Key caveats summary

| Caveat | Affects | Why |
|---|---|---|
| `mount --bind /usr /usr` required before first merge | FCoOS nodes only | FCoOS 44+ composefs: `/usr` is not a separate mount point; sysext overlayfs needs a mountable target |
| `mount --bind /usr /usr` must be re-applied after a reboot | FCoOS nodes only | The bind-mount is a transient kernel mount; it does not survive reboot |
| `setenforce 0` required after every merge | FCoOS nodes only | Merged overlayfs files get `unlabeled_t` SELinux context; Enforcing mode blocks exec (status=203) |
| Flatcar sysupdate uses `-C kubernetes` flag | worker-1 only | Flatcar ships multiple sysupdate components; `-C` selects the right one |
| fedora-sysexts uses `--component kubernetes-1.33` | worker-3 only | Component name includes the minor version; the conf dir is `sysupdate.kubernetes-1.33.d/` |
| Version specifier is the patch number only | worker-1, worker-2 | `@v` in `kubernetes-v1.33.@v-%a.raw` captures `10`, `12`, etc. — not the full semver |
| `systemd-sysupdate` is not in `$PATH` | All nodes | Full path: `/usr/lib/systemd/systemd-sysupdate` |
