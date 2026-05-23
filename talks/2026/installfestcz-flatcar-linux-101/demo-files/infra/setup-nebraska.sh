#!/bin/bash
# Register the 4628.0.0 update package in Nebraska and assign it to stable.
# Run this after start-infra.sh (or after reset-demo.sh).

set -euo pipefail

APP_ID="e96281a6-d1af-4bde-9a0a-97b76e56dc57"

echo "==> Waiting for Nebraska to be ready..."
for i in $(seq 1 30); do
  if curl -4 -sf http://localhost:8000/health > /dev/null 2>&1; then
    echo "    Nebraska is ready."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "    ERROR: Nebraska did not become ready."
    exit 1
  fi
  sleep 1
done

echo "==> Creating package for Flatcar 4628.0.0"
PKG_RESPONSE=$(curl -4 -s -X POST "http://localhost:8000/api/apps/${APP_ID}/packages" \
  -H 'Content-Type: application/json' \
  -d "{
    \"type\": 1,
    \"version\": \"4628.0.0\",
    \"url\": \"http://192.168.122.1:8080/payload/\",
    \"filename\": \"flatcar_production_update.gz\",
    \"description\": \"Flatcar Container Linux 4628.0.0\",
    \"size\": \"481659137\",
    \"hash\": \"AP4AICVED7VHb32E0UAOTCTYGIs=\",
    \"flatcar_action\": {
      \"event\": \"postinstall\",
      \"sha256\": \"p4wrQrU2Z34cRQqJrG5zoRSCgT/FvUckbXtZ8sCkykQ=\",
      \"needs_admin\": false,
      \"is_delta\": false,
      \"disable_payload_backoff\": true
    },
    \"arch\": 1,
    \"application_id\": \"${APP_ID}\",
    \"channels_blacklist\": []
  }" 2>&1)

PKG_ID=$(echo "$PKG_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null)
if [ -z "$PKG_ID" ]; then
  echo "    Package already exists, looking up ID..."
  PKG_ID=$(podman exec flatcar-infra-postgres psql -U postgres -d nebraska -t -c \
    "SELECT id FROM package WHERE version='4628.0.0' AND application_id='${APP_ID}'" | tr -d ' \n')
fi
echo "    Package ID: $PKG_ID"

echo "==> Adding oem-qemu.gz as extra package file"
podman exec flatcar-infra-postgres psql -U postgres -d nebraska -c \
  "INSERT INTO package_file (package_id, name, hash, size, hash256) \
   VALUES ('${PKG_ID}', 'oem-qemu.gz', '7JZtFFUX2zroRUT6e12tC1mdemE=', '5213', '0a2300e6cb5e4925c268be39ae075e61288c6ba5249853e9d4d4bf635acd0aa0') \
   ON CONFLICT DO NOTHING" \
  >/dev/null 2>&1
echo "    oem-qemu.gz registered"

STABLE_CHANNEL_ID="e06064ad-4414-4904-9a6e-fd465593d1b2"

echo "==> Assigning package to stable AMD64 channel"
curl -4 -sf -X PUT "http://localhost:8000/api/apps/${APP_ID}/channels/${STABLE_CHANNEL_ID}" \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"stable\",
    \"color\": \"#14b9d6\",
    \"package_id\": \"${PKG_ID}\",
    \"arch\": 1,
    \"application_id\": \"${APP_ID}\"
  }" > /dev/null

echo "==> Verifying Omaha response..."
OMAHA_VER=$(curl -4 -s -X POST "http://localhost:8000/v1/update/" \
  -H 'Content-Type: application/xml' \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" version="Flatcar-4515.0.0" updaterversion="0.4.7.1" installsource="scheduler" ismachine="1">
  <os version="Chateau" platform="CoreOS" sp="4515.0.0_x86_64"></os>
  <app appid="{e96281a6-d1af-4bde-9a0a-97b76e56dc57}" version="4515.0.0" track="stable" bootid="{test}" machineid="test" lang="en-US" hardware_class="" delta_okay="false">
    <updatecheck></updatecheck>
  </app>
</request>' | grep -oP 'codebase="[^"]+"' | head -1)

echo "    Nebraska advertises: $OMAHA_VER"
echo "==> Done."
