#!/bin/bash
# Start the Flatcar demo infrastructure pod:
#   - PostgreSQL (Nebraska's database)
#   - Nebraska (Omaha update server)
#   - nginx (static file server for payloads and sysexts)
#
# All three containers share a network namespace via the pod.
# Exposed ports:
#   8000 — Nebraska (Omaha API + web UI)
#   8080 — nginx (update payloads + sysext images)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure libvirtd is running and virbr0 exists (socket-activated, so may
# not be up after a fresh reboot with no network)
echo "==> Ensuring libvirtd and virbr0 are up..."
sudo systemctl start libvirtd
sleep 1
if ! ip link show virbr0 >/dev/null 2>&1; then
  sudo virsh net-start default 2>/dev/null || true
  sleep 1
fi
if ! ip link show virbr0 >/dev/null 2>&1; then
  echo "ERROR: virbr0 bridge not available. Is libvirt's default network defined?"
  exit 1
fi

POD_NAME="flatcar-infra"
PG_PASSWORD="nebraska"
PG_DB="nebraska"

echo "==> Creating pod: ${POD_NAME}"
podman pod create \
  --name "${POD_NAME}" \
  --network=host \
  --replace

echo "==> Starting PostgreSQL"
podman run -d --pod "${POD_NAME}" \
  --name "${POD_NAME}-postgres" \
  --replace \
  -e POSTGRES_PASSWORD="${PG_PASSWORD}" \
  -e POSTGRES_DB="${PG_DB}" \
  docker.io/library/postgres:17

# Wait for PostgreSQL to accept connections on host
echo "==> Waiting for PostgreSQL..."
for i in $(seq 1 30); do
  if podman exec "${POD_NAME}-postgres" pg_isready -h 127.0.0.1 -U postgres -q 2>/dev/null; then
    echo "    PostgreSQL is ready."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "    ERROR: PostgreSQL did not become ready in time."
    exit 1
  fi
  sleep 1
done

echo "==> Starting Nebraska"
# Nebraska may fail on first attempt if postgres port isn't fully bound yet.
# Retry up to 3 times with a brief pause.
for attempt in 1 2 3; do
  podman run -d --pod "${POD_NAME}" \
    --name "${POD_NAME}-nebraska" \
    --replace \
    -e NEBRASKA_DB_URL="postgres://postgres:${PG_PASSWORD}@127.0.0.1:5432/${PG_DB}?sslmode=disable&connect_timeout=10" \
    ghcr.io/flatcar/nebraska:latest \
    /nebraska/nebraska \
      -http-static-dir=/nebraska/static \
      -auth-mode=noop

  sleep 3
  if curl -4 -sf http://localhost:8000/health > /dev/null 2>&1; then
    echo "    Nebraska is up (attempt $attempt)."
    break
  fi
  if [ "$attempt" -eq 3 ]; then
    echo "    ERROR: Nebraska failed to start after 3 attempts."
    podman logs "${POD_NAME}-nebraska" 2>&1 | tail -5
    exit 1
  fi
  echo "    Nebraska not ready yet, retrying (attempt $attempt)..."
  sleep 2
done

echo "==> Starting nginx"
podman run -d --pod "${POD_NAME}" \
  --name "${POD_NAME}-nginx" \
  --replace \
  -v "${SCRIPT_DIR}/nginx.conf:/etc/nginx/conf.d/default.conf:ro,z" \
  -v "${PROJECT_DIR}/artifacts/new-4628:/data/payload:ro,z" \
  -v "${PROJECT_DIR}/artifacts/sysext:/data/sysext:ro,z" \
  docker.io/library/nginx:alpine

echo ""
echo "==> Infrastructure pod is up."
echo "    Nebraska UI:  http://localhost:8000"
echo "    nginx files:  http://localhost:8080"
echo "    Pod status:   podman pod ps"
echo ""
podman pod ps
echo ""
podman ps --pod --filter "pod=${POD_NAME}"
