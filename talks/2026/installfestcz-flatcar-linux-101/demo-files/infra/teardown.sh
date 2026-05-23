#!/bin/bash
# Tear down the Flatcar demo infrastructure pod and all its containers.

set -euo pipefail

POD_NAME="flatcar-infra"

echo "==> Stopping and removing pod: ${POD_NAME}"
podman pod stop "${POD_NAME}" 2>/dev/null || true
podman pod rm -f "${POD_NAME}" 2>/dev/null || true

echo "==> Done. Pod removed."
podman pod ps
