- Demo: systemd system extensions
— if /usr is immutable, how do you extend the OS? systsemd system extensions a/k/a/ sysexts.
- This machine has no container runtimes
- STEP 1: cat demo2.bu
  - /etc/extensions/docker-flatcar.raw → /dev/null
  - /etc/extensions/containerd-flatcar.raw → /dev/null
  - Flatcar ships Docker and containerd as system extensions. They're overlaid onto /usr at boot.
  - The system sees /dev/null and skips them. Not masked - literally not there

- STEP 2: docker --version; podman --version

- STEP 3: systemd-sysext status — only oem-qemu loaded

- STEP 4: sudo cp /opt/sysexts/flatcar-podman.raw /var/lib/extensions/
  - I am simulating the download of the sysext for podman
  - Could have been at provisioning

- STEP 5: sudo systemd-sysext refresh
  - This merges in the new extension - could also have been at boot

- STEP 6: podman --version; which podman
  - Tada - podman and where it should be

- STEP 7: sudo rm /var/lib/extensions/flatcar-podman.raw
  - sudo systemd-sysext refresh
  - podman --version → No such file or directory
  - and gone - the path is only known because it is cached in bash

- System extensions let you customize Flatcar without breaking immutability.
- Official extensions come from the release server
- community extensions come from the bakery
- your private extensions come from your infrastructure
