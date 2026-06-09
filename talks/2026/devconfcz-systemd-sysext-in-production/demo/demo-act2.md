# Demo Act 2 — Fedora CoreOS workers: same sysext, different OS; different sysext, same result

1. Drain and cordon worker 2
2. go to worker-2 cat /etc/os-release
3. systemd-sysext status
4. kubelet --version
5. ls -la /var/lib/extensions/kubernetes.raw - you've seen this string before
6. cat /etc/sysupdate.d/kubernetes.transfer
7. /usr/lib/systemd/systemd-sysupdate list
8. cp ~core/kubernetes-v1.33.12-x86-64.raw /opt/extensions/kubernetes/
9. ln -sf /opt/extensions/kubernetes/kubernetes-v1.33.12-x86-64.raw /var/lib/extensions/kubernetes.raw
10. systemd-sysext refresh
11. kubelet --version
12. systemctl restart kubelet
13. uncordon and add workload

14. getenforce - we are cheating

15. Drain and cordon worker 3
16. go to worker-3 cat /etc/os-release
17. systemd-sysext status
18. kubelet --version
19. cat /etc/sysupdate.kubernetes-1.33.d/kubernetes-1.33.transfer
20. getenforce - this one is labeled!
21. /usr/lib/systemd/systemd-sysupdate --component kubernetes-1.33 list
22. cp ~core/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw /var/lib/extensions.d/
23. ln -sf /var/lib/extensions.d/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw  /var/lib/extensions/kubernetes-1.33.raw
24. systemd-sysext refresh
25. systemctl restart kubelet
26. uncordon and add workload
