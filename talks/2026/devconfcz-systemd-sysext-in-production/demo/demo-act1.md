# Demo Act 1 — Flatcar worker-1: Kubernetes from a sysext

SETUP: Headlamp open in browser. Terminal ready. Cluster is up, all nodes Ready.
       worker-1 upgrade sysext is pre-staged at ~/kubernetes-v1.33.12-x86-64.raw.

---

- STEP 1: [Headlamp] Show the cluster

  - Go to **Cluster → Nodes**
  - Four nodes, all Ready. Two Flatcar, two Fedora CoreOS.
  - Go to **Workloads → Pods** — three demo-nginx pods Running, one per worker.
  - "Before we do anything, let's look at what we have."

---

- STEP 2: [Headlamp] Drain worker-1

  - Go to **Cluster → Nodes** → click **worker-1** → click **Drain** → confirm
  - Watch the demo-nginx pod on worker-1 reschedule in Pods view.
  - "Standard Kubernetes drain and cordon in one action. Pod moves to another node.
    Worker-1 is now out of the scheduling rotation."

---

- STEP 3: [SSH worker-1] Connect and check kubelet version

  ```bash
  ./go.sh worker-1

  kubelet --version
  # → Kubernetes v1.33.10
  ```

  - "v1.33.10. Let's see where that came from."

---

- STEP 4: [SSH worker-1] Show loaded sysexts — and the docker aside

  ```bash
  systemd-sysext status
  # → HIERARCHY EXTENSIONS         SINCE
  # → /opt      none               -
  # → /usr      containerd-flatcar  <boot time>
  # →           docker-flatcar
  # →           kubernetes
  # →           oem-azure
  ```

  - "Everything under /usr is a composable image overlaid at boot:
    containerd, Kubernetes — and notice docker-flatcar is here too."

  ```bash
  ls -la /etc/extensions/
  # → containerd-flatcar.raw -> /usr/share/flatcar/sysext/containerd-flatcar.raw
  #   docker-flatcar.raw     -> /usr/share/flatcar/sysext/docker-flatcar.raw
  #   kubernetes.raw         -> /opt/extensions/kubernetes/kubernetes-v1.33.10-x86-64.raw
  #   oem-azure.raw          -> /oem/sysext/oem-azure-4593.2.0.raw
  ```

  - "Notice the split: the Flatcar-shipped sysexts live under
    /usr/share/flatcar/sysext. Our custom Kubernetes sysext is the only one under
    /opt/extensions — that's the one we own and upgrade."

  - "Docker ships by default and is opt-out, not opt-in. Watch — no package
    manager required. Mask its symlink to /dev/null and refresh:"

  ```bash
  sudo ln -sf /dev/null /etc/extensions/docker-flatcar.raw
  sudo systemd-sysext refresh
  systemd-sysext status
  # → docker-flatcar is GONE; containerd-flatcar, kubernetes, oem-azure remain merged
  ```

  - "Docker's out of the overlay — no rpm, no dnf, no reboot. (containerd is the
    Kubernetes runtime; docker was never in the critical path.) Put it back just as
    easily:"

  ```bash
  sudo ln -sf /usr/share/flatcar/sysext/docker-flatcar.raw /etc/extensions/docker-flatcar.raw
  sudo systemd-sysext refresh
  ```

---

- STEP 5: [SSH worker-1] Show the sysext file itself

  ```bash
  ls /opt/extensions/kubernetes/
  # → kubernetes-v1.33.10-x86-64.raw

  ls -la /etc/extensions/kubernetes.raw
  # → /etc/extensions/kubernetes.raw -> /opt/extensions/kubernetes/kubernetes-v1.33.10-x86-64.raw
  ```

  - "One file. That's the entire Kubernetes toolchain — kubelet, kubeadm, kubectl.
    This symlink is what systemd-sysext tracks."

---

- STEP 6: [SSH worker-1] Show the sysupdate configuration

  ```bash
  cat /etc/sysupdate.kubernetes.d/kubernetes-v1.33.transfer
  ```

  - "This is what tells systemd-sysupdate where to look for updates.
    A URL, a filename pattern, a target directory, and a symlink to keep current.
    That's the whole upgrade contract."

---

- STEP 7: [SSH worker-1] Check what versions are available

  ```bash
  sudo /usr/lib/systemd/systemd-sysupdate -C kubernetes list
  # → lists available versions: 10 (current/installed), 12 (available), 2 (older)
  #   Version 10 = v1.33.10, version 12 = v1.33.12
  ```

  - "sysupdate just hit our blob storage and found what's available.
    Version 12 is out there — that's v1.33.12. Let's take it."

---

- STEP 8: [SSH worker-1] Copy in the staged update

  ```bash
  sudo cp ~/kubernetes-v1.33.12-x86-64.raw /opt/extensions/kubernetes/
  sudo ln -sf /opt/extensions/kubernetes/kubernetes-v1.33.12-x86-64.raw \
              /etc/extensions/kubernetes.raw
  ```

  - "I pre-staged this file before the talk — same as sysupdate would download.
    Point the symlink at the new version."

---

- STEP 9: [SSH worker-1] Refresh and restart

  ```bash
  sudo systemd-sysext refresh
  sudo systemctl restart kubelet

  kubelet --version
  # → Kubernetes v1.33.12
  ```

  - "Refresh swaps the overlay. Restart picks up the new binary.
    v1.33.12. No package manager. No OS reinstall. No reboot."

  ```bash
  exit
  ```

---

- STEP 10: [Headlamp] Uncordon and verify

  - **Cluster → Nodes** → **worker-1** → **Uncordon**
  - Node goes Ready. Kubelet version in the node details updates to v1.33.12.
  - Go to **Workloads → Deployments** → **demo-nginx** → scale up by a few replicas
  - worker-1 is freshly empty, so soft topology spread favors it — a new pod lands
    there running v1.33.12 (scheduling is best-effort, not pinned).
  - "The kubelet rejoined with its existing certs. Scheduler rebalances.
    The upgrade was invisible to the workload."
