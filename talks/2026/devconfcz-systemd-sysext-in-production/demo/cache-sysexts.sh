#!/bin/bash
# ABOUTME: Downloads all sysext files required by the demo to a local cache.
# ABOUTME: Run once before start.sh; subsequent cluster restarts need no internet.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

# Total download ~715MB.  Individual files:
#   flatcar/kubernetes-v1.33.2-x86-64.raw    ~112MB
#   flatcar/kubernetes-v1.33.10-x86-64.raw   ~112MB  (worker-1/2 intermediate upgrade target)
#   flatcar/kubernetes-v1.33.12-x86-64.raw   ~112MB
#   fedora/kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw  ~185MB
#   fedora/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw  ~186MB

mkdir -p "${SYSEXT_CACHE_DIR}/flatcar"
mkdir -p "${SYSEXT_CACHE_DIR}/fedora"

download_if_missing() {
  local dest="$1"
  local url="$2"
  if [ -f "${dest}" ]; then
    echo "    Already cached: $(basename "${dest}") ($(du -h "${dest}" | cut -f1))"
    return
  fi
  echo "    Downloading $(basename "${dest}") ..."
  curl -fsSL --retry 3 --retry-delay 5 -L -o "${dest}.tmp" "${url}"
  mv "${dest}.tmp" "${dest}"
  echo "    Done: $(basename "${dest}") ($(du -h "${dest}" | cut -f1))"
}

echo "==> Caching Flatcar bakery sysexts (used by worker-1 and worker-2)..."
download_if_missing \
  "${SYSEXT_CACHE_DIR}/flatcar/kubernetes-v1.33.2-x86-64.raw" \
  "https://extensions.flatcar.org/extensions/kubernetes-v1.33.2-x86-64.raw"

download_if_missing \
  "${SYSEXT_CACHE_DIR}/flatcar/kubernetes-v1.33.10-x86-64.raw" \
  "https://extensions.flatcar.org/extensions/kubernetes-v1.33.10-x86-64.raw"

download_if_missing \
  "${SYSEXT_CACHE_DIR}/flatcar/kubernetes-v1.33.12-x86-64.raw" \
  "https://extensions.flatcar.org/extensions/kubernetes-v1.33.12-x86-64.raw"

echo ""
echo "==> Caching fedora-sysexts sysexts (used by worker-3)..."
download_if_missing \
  "${SYSEXT_CACHE_DIR}/fedora/kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw" \
  "https://extensions.fcos.fr/fedora/kubernetes-1.33/kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw"

download_if_missing \
  "${SYSEXT_CACHE_DIR}/fedora/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw" \
  "https://extensions.fcos.fr/fedora/kubernetes-1.33/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw"

echo ""
echo "==> Generating SHA256SUMS manifests (required by systemd-sysupdate)..."
(cd "${SYSEXT_CACHE_DIR}/flatcar" && sha256sum kubernetes-v*.raw > SHA256SUMS && echo "    flatcar/SHA256SUMS updated")
(cd "${SYSEXT_CACHE_DIR}/fedora"  && sha256sum kubernetes-*.raw  > SHA256SUMS && echo "    fedora/SHA256SUMS updated")

echo ""
echo "==> Cache complete!"
echo "    ${SYSEXT_CACHE_DIR}"
du -sh "${SYSEXT_CACHE_DIR}"
