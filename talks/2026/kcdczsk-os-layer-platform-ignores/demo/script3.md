DEMO 3 — Kubelet sysext upgrade
  - Click drain on flatcar-worker-1 node
  - kubelet --version
  - ls -l /etc/extensions
  - ls /opt/extensions/kubernetes/
  - ls -l /etc/extensions/kubernetes.raw
  - /usr/lib/systemd/systemd-sysupdate -C kubernetes list
  - cp ~core/kubernetes-v1.33.12-x86-64.raw /opt/extensions/kubernetes/
  - ln -sf /opt/extensions/kubernetes/kubernetes-v1.33.12-x86-64.raw /etc/extensions/kubernetes.raw
  - systemd-sysext refresh
  - systemctl restart kubelet
  - kubelet --version
  - Uncordon flatcar-worker-1
  - Scale up demo-nginx

--------------------------------------------------------------------------------

SETUP: Pre-cached sysext in ~core/kubernetes-v1.33.12-x86-64.raw (setup.sh did this).
       Terminal SSH'd into worker-1.

- STEP 1: [Headlamp] Drain worker-1
  - Click drain on flatcar-worker-1 node
  - "Same pattern as the OS update — take the node out of service first."
  - "Notice this now, all three nodes in the cluster show the same kubelet version."

- STEP 2: [Terminal] Show current kubelet version
  - kubelet --version
  - "v1.33.2 — this came from the kubernetes sysext."

- STEP 3: [Terminal] Show sysext status
  - "Every component here is a composable image overlaid onto /usr. You'll notice docker - here.  I didn't mark it out for the demo, but could have. It ships by default and is opt-out not opt-in.  For those of you like me and other speakers here ... podman is available too."
  - ls -l /etc/extensions
  - "and here are their versions - this is the version_id"

- STEP 4: [Terminal] Show the sysext file
  - ls /opt/extensions/kubernetes/
  - Shows kubernetes-v1.33.2-x86-64.raw
  - "One file. That's the entire kubernetes toolchain — kubelet, kubeadm, kubectl."
  - ls -l /etc/extensions/kubernetes.raw
  - "This is the actual link that systemd-sysext works from - pointing at v1.33.2"

- STEP 5: [Terminal] Show available updates via sysupdate
  - /usr/lib/systemd/systemd-sysupdate -C kubernetes list
  - Shows version 2 (current), versions 0-12 available
  - "These are v1.33 patch releases. Version 2 is v1.33.2, version 12 is v1.33.12.
     sysupdate checks a URL for new sysext images — like a package manager for immutable images.
     I am not going to do version management in this demo and will take latest"

- STEP 6: [Terminal] Copy pre-cached sysext and update
  - cp ~core/kubernetes-v1.33.12-x86-64.raw /opt/extensions/kubernetes/
  - ln -sf /opt/extensions/kubernetes/kubernetes-v1.33.12-x86-64.raw /etc/extensions/kubernetes.raw

- STEP 7: [Terminal] Refresh sysext and restart kubelet
  - systemd-sysext refresh
  - systemctl restart kubelet
  - "In production, sysupdate does this automatically — downloads the image,
     flips the symlink, refreshes the overlay."
  - kubelet --version
  - "v1.33.12. Swapped in place. No package manager. No OS reinstall."

- STEP 8: [Headlamp] Uncordon and rebalance
  - Uncordon flatcar-worker-1
  - Scale up demo-nginx
  - Replacement schedules onto worker-1 (topology spread)
  - "The kubelet rejoined with its existing certs. Scheduler rebalances.
     The component upgrade was invisible to the workloads."
