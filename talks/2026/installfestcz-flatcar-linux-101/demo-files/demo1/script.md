- Demo running on a Lenovo T460S from 2016 — all local, no WiFi needed. Some steps pre-staged to avoid download spinners.  The VM I am going to show is already running for the same reason.
- STEP 1: cat demo1/demo1.bu
  - SSH key
  - Static IP via systemd-networkd
  - Custom web page - loaded from a file
  - nginx container - loaded from a file
  - Updates masked 

- STEP 2: butane --strict --files-dir . demo1.bu
  - Same content

- STEP 3: curl http://192.168.122.103:8000 from the host — show the web page

- STEP 4: docker ps

- STEP 5: sudo touch /usr/test
  - sudo mount -o remount,rw /usr

- STEP 7: sudo dmsetup table | grep verity

- STEP 8: sudo cgpt show /dev/vda | grep -A3 USR
  — show priority/tries/successful flags
