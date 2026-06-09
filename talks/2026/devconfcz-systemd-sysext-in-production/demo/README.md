# DevConf Sysext Demo

A Kubernetes demo cluster on Azure showing that both Flatcar Container Linux and
Fedora CoreOS can run Kubernetes entirely from systemd sysexts — nothing compiled
into either OS image. The demo uses three worker nodes across two operating systems
and two sysext sources to prove the point.

## What you need before you start

There are three things you must supply. Everything else is automated.

### 1. Azure CLI, authenticated

```bash
az login
```

The scripts assume you are logged in and your default subscription is the one
where you want to run the demo. Confirm with `az account show`.

### 2. Tailscale auth key

All VM access goes through Tailscale — there are no public IP addresses on any
VM. The control plane joins your tailnet and advertises the VNet subnet so you
can reach all worker nodes through it.

Create an auth key at **https://login.tailscale.com/admin/settings/keys**.
Use these settings:
- **Reusable**: yes (so you can tear down and re-run without generating a new key)
- **Ephemeral**: yes (the CP node auto-expires when the VM is deleted)
- **Tags**: optional, but useful for filtering in the admin console

Copy `tailscale.env.example` to `tailscale.env` and fill in your key:

```bash
cp tailscale.env.example tailscale.env
# Edit tailscale.env and set TS_KEY="tskey-auth-..."
```

`tailscale.env` is in `.gitignore` and must never be committed.

### 3. SSH keypair

The scripts use `~/.ssh/id_ed25519` by default. If yours is elsewhere:

```bash
export SSH_KEY_PATH=~/.ssh/your_key
```

Or set it permanently in `common.env`. All VMs are provisioned with the
corresponding public key via Ignition.

---

## One-time configuration

Edit `common.env` — the storage account name is already set to `bexdevconfsysext`.
If you need to change it (e.g. name is already taken), it must be 3–24 lowercase
alphanumeric characters and globally unique across all of Azure.

---

## Architecture

### Cluster nodes

| VM | OS | Sysext source | Role |
|---|---|---|---|
| `flatcar-cp` | Flatcar Container Linux | Flatcar bakery (blob) | Control plane + Tailscale gateway |
| `worker-1` | Flatcar Container Linux | Flatcar bakery (blob) | Worker — demo Act 1 |
| `worker-2` | Fedora CoreOS | Flatcar bakery (blob) | Worker — demo Act 2a |
| `worker-3` | Fedora CoreOS | fedora-sysexts (blob) | Worker — demo Act 2b |

### SELinux posture

The three workers deliberately differ in SELinux mode, and that contrast is the
payoff of Act 2:

| Node | OS | SELinux | Why |
|---|---|---|---|
| `worker-1` | Flatcar | n/a | Flatcar's sysext is labeled for Flatcar's own policy |
| `worker-2` | Fedora CoreOS | **Permissive** | The foreign Flatcar sysext lands as `unlabeled_t`; Fedora's enforcing policy won't exec it, so `worker-2.bu` runs `setenforce 0` at boot |
| `worker-3` | Fedora CoreOS | **Enforcing** | The Fedora-built sysext ships correct labels (`kubelet_exec_t`), so it runs enforcing from boot through the upgrade — no `setenforce` anywhere |

worker-2 is the honest "we had to cheat" admission; worker-3 is the resolution.
Only `worker-2.bu` contains a `setenforce 0`.

### Two resource groups

**`devconf-sysext-infra`** (persistent) — survives `stop.sh`:
- Azure Storage account with all sysext `.raw` files
- FCoOS managed image (built from VHD upload, ~30 min one-time cost)

**`devconf-sysext-vms`** (ephemeral) — deleted by `stop.sh`:
- VNet, NSG, all 4 VMs, OS disks

This split means you can tear down and recreate the entire cluster in ~15 minutes
without re-uploading sysexts or the FCoOS image each time.

### Connectivity

No VM has a public IP address. The NSG has no inbound rules. All access is:

- **Control plane**: directly via its Tailscale IP
- **Workers**: via Tailscale subnet routing through the control plane

After `setup.sh` completes, you must approve the subnet route in the Tailscale
admin console once. The CP advertises `10.0.0.0/24` and masquerades traffic to
it. After approval, `go.sh worker-1` (and 2, 3) work transparently.

### Sysexts in blob storage

Fedora CoreOS is not published in the Azure Marketplace or any community gallery.
The only option is to download the VHD, upload it to blob storage, and create a
managed image — which `prep-infra.sh` handles automatically.

All sysext `.raw` files are also stored in blob storage so VMs never need to
reach external package servers at demo time. The blob container is publicly
readable (the files are public packages anyway), but no one on the internet can
reach the VMs themselves.

`systemd-sysupdate` discovers available versions by fetching a `SHA256SUMS`
manifest from the same blob path as the sysexts (the transfer files use
`Type=url-file`). Azure blob storage does not auto-generate directory listings, so
`prep-infra.sh` generates and uploads a `SHA256SUMS` alongside each set of sysexts.

### Pre-staged upgrade sysexts

During `setup.sh`, after each worker joins the cluster, the upgrade sysext is
downloaded from blob storage to `~/` on each worker. This means the demo "copy in
staged update" step is instant — no network activity on stage. The upgrade files
are just sitting there, ready to be copied into the extensions directory.

---

## Running the demo

### Step 1: Prep infrastructure (once per Azure subscription)

```bash
./prep-infra.sh
```

This takes 20–30 minutes, dominated by the FCoOS VHD upload (~1.1 GB). It is
idempotent — re-running it skips anything already done. You only need to run
this once; it survives cluster teardowns.

What it creates:
- `devconf-sysext-infra` resource group
- Storage account with public blob container
- Flatcar sysexts uploaded: `kubernetes-v1.33.2`, `kubernetes-v1.33.10`, and `kubernetes-v1.33.12`
- Fedora sysexts uploaded: `kubernetes-1.33` at v1.33.10 and v1.33.12
- `SHA256SUMS` manifest generated for each sysext set (drives version discovery)
- FCoOS `44.20260523.3.1` managed image created from uploaded VHD

### Step 2: Start the cluster

```bash
./setup.sh
```

This takes 10–15 minutes. It:
1. Creates the `devconf-sysext-vms` resource group, VNet, and NSG
2. Creates and boots the Flatcar control plane with Tailscale
3. Waits for Tailscale, then for kubeadm init
4. Installs Calico CNI and deploys Headlamp
5. Creates all three worker VMs in parallel (Flatcar, FCoOS×2)
6. Waits for all nodes to join
7. Deploys the nginx demo workload
8. Downloads upgrade sysexts to each worker in the background
9. Prints the Headlamp URL and token

### Step 3: Approve Tailscale subnet route

When `setup.sh` finishes printing the cluster summary, it will ring the terminal
bell and prompt you to approve the subnet route, then wait up to 5 minutes
polling for connectivity. Go to **https://login.tailscale.com/admin/machines**,
find `flatcar-cp`, and approve the `10.0.0.0/24` route. Once approved, `setup.sh`
will confirm workers are reachable and declare the cluster ready.

### Step 4: Run the demo

See `demo-act1.md` and `demo-act2.md` for the step-by-step runbook.

Quick SSH access:
```bash
./go.sh flatcar-cp
./go.sh worker-1
./go.sh worker-2
./go.sh worker-3
```

Headlamp dashboard: `http://<CP-Tailscale-IP>:30080`
Token is printed by `setup.sh` and saved to `headlamp-token`.

Cluster status at any time:
```bash
./status.sh
```

### Step 5: Tear down (between runs)

```bash
./stop.sh
```

Deletes `devconf-sysext-vms` and its contents. Preserves `devconf-sysext-infra`
(storage + FCoOS image). Next `./setup.sh` will have a cluster running in ~15
minutes with no prep required.

Also remove `flatcar-cp` from the Tailscale admin console, or let it auto-expire
(ephemeral nodes expire after ~30 minutes of being offline).

### Full teardown (when you're done with the demo entirely)

```bash
./nuke.sh
```

Asks for confirmation, then deletes both resource groups. Everything is gone —
VMs, storage, sysexts, FCoOS image. You will need to run `prep-infra.sh` again
before the next use.

---

## Troubleshooting

**`prep-infra.sh` fails on storage account name**
The name `devconfsysext` in `common.env` is a placeholder. Edit it to something
unique before running.

**`setup.sh` fails: "Stale Tailscale entry 'flatcar-cp' found"**
Remove `flatcar-cp` from https://login.tailscale.com/admin/machines and retry.

**Workers don't join after 8 minutes**
The FCoOS workers (2 and 3) take longer because they download sysexts on first
boot. On worker-2 run `journalctl -fu load-flatcar-k8s-sysext`; on worker-3 run
`journalctl -fu load-fedora-k8s-sysext`. worker-2 must run SELinux permissive for
the foreign Flatcar sysext, so an exec failure (status=203) there means its
`setenforce 0` didn't run. worker-3 runs SELinux enforcing by design (its Fedora
sysext is correctly labeled `kubelet_exec_t`), so a status=203 there points to a
labeling problem, not a missing setenforce.

**`go.sh worker-N` can't connect**
Tailscale subnet route may not be approved yet. Check the admin console. Also
verify `tailscale status` shows `flatcar-cp` as online.

**Headlamp token expired**
Tokens are valid for 24 hours. Generate a new one:
```bash
./go.sh flatcar-cp
kubectl create token headlamp -n headlamp --duration=24h
```
