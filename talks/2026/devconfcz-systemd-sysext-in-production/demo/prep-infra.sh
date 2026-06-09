#!/bin/bash
# ABOUTME: One-time infrastructure setup: Azure infra resource group, storage account,
# ABOUTME: FCoOS managed image, and sysext blobs. Run once per Azure subscription.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.env"

# -----------------------------------------------------------------------
# Prerequisites
# -----------------------------------------------------------------------
for cmd in az curl xz sha256sum python3; do
  command -v "$cmd" &>/dev/null || { echo "ERROR: $cmd not found"; exit 1; }
done

az account show -o none 2>/dev/null || { echo "ERROR: Not logged in to Azure. Run: az login"; exit 1; }

if [ "${STORAGE_ACCOUNT}" = "devconfsysext" ]; then
  echo "ERROR: STORAGE_ACCOUNT is still the default value 'devconfsysext'."
  echo "       Edit common.env and set a globally unique name (e.g. devconfsysextbex)."
  exit 1
fi

ts() { echo "[$(date '+%H:%M:%S')] $*"; }

ts "prep-infra.sh"
echo "    Infra RG:        ${AZ_RG_INFRA}"
echo "    Location:        ${AZ_LOCATION}"
echo "    Storage account: ${STORAGE_ACCOUNT}"
echo "    FCoOS version:   ${FCOS_VERSION}"
echo ""

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

VHD_CACHE_DIR="${SCRIPT_DIR}/fcos-vhd-cache"
mkdir -p "${VHD_CACHE_DIR}"

# -----------------------------------------------------------------------
# Infra resource group
# -----------------------------------------------------------------------
ts "Creating infra resource group: ${AZ_RG_INFRA}"
az group create --name "${AZ_RG_INFRA}" --location "${AZ_LOCATION}" -o none

# -----------------------------------------------------------------------
# Storage account + public blob container
# -----------------------------------------------------------------------
ts "Creating storage account: ${STORAGE_ACCOUNT}"
az storage account create \
  --name "${STORAGE_ACCOUNT}" \
  --resource-group "${AZ_RG_INFRA}" \
  --location "${AZ_LOCATION}" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access true \
  -o none

# Fetch key once — suppresses per-call warnings and avoids repeated API round-trips
export AZURE_STORAGE_ACCOUNT="${STORAGE_ACCOUNT}"
export AZURE_STORAGE_KEY
AZURE_STORAGE_KEY=$(az storage account keys list \
  --account-name "${STORAGE_ACCOUNT}" \
  --resource-group "${AZ_RG_INFRA}" \
  --query "[0].value" -o tsv)

ts "Creating public blob container: ${STORAGE_CONTAINER}"
az storage container create \
  --name "${STORAGE_CONTAINER}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --public-access blob \
  --auth-mode key \
  -o none

# -----------------------------------------------------------------------
# FCoOS managed image
# -----------------------------------------------------------------------
FCOS_IMAGE_CHECK=$(az image show \
  --resource-group "${AZ_RG_INFRA}" \
  --name "${FCOS_IMAGE_NAME}" \
  --query "name" -o tsv 2>/dev/null || true)

if [ -n "${FCOS_IMAGE_CHECK}" ]; then
  ts "FCoOS managed image '${FCOS_IMAGE_NAME}' already exists — skipping VHD upload."
else
  FCOS_XZ="${VHD_CACHE_DIR}/fcos-${FCOS_VERSION}.vhd.xz"
  FCOS_VHD="${VHD_CACHE_DIR}/fcos-${FCOS_VERSION}.vhd"

  if [ ! -f "${FCOS_VHD}" ] && [ ! -f "${FCOS_XZ}" ]; then
    echo "==> Downloading FCoOS VHD (this is ~1.1GB compressed)..."
    curl -L --progress-bar -o "${FCOS_XZ}" "${FCOS_VHD_URL}"
    echo "==> Verifying SHA256..."
    echo "${FCOS_VHD_SHA256}  ${FCOS_XZ}" | sha256sum -c -
  elif [ -f "${FCOS_XZ}" ]; then
    echo "==> FCoOS VHD archive already cached: ${FCOS_XZ}"
  else
    echo "==> FCoOS VHD already decompressed: ${FCOS_VHD}"
  fi

  if [ ! -f "${FCOS_VHD}" ]; then
    echo "==> Decompressing VHD (may take a minute)..."
    xz -d "${FCOS_XZ}"
  fi

  BLOB_NAME="fcos-${FCOS_VERSION}.vhd"
  BLOB_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/fcos-upload/${BLOB_NAME}"

  ts "Creating upload container..."
  az storage container create \
    --name "fcos-upload" \
    --account-name "${STORAGE_ACCOUNT}" \
    --auth-mode key \
    -o none

  ts "Uploading VHD to blob storage (this may take several minutes)..."
  az storage blob upload \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "fcos-upload" \
    --name "${BLOB_NAME}" \
    --file "${FCOS_VHD}" \
    --type page \
    --max-connections 8 \
    --auth-mode key \
    -o none

  ts "Creating FCoOS managed image from VHD..."
  az image create \
    --name "${FCOS_IMAGE_NAME}" \
    --resource-group "${AZ_RG_INFRA}" \
    --source "${BLOB_URL}" \
    --location "${AZ_LOCATION}" \
    --os-type Linux \
    -o none

  ts "Cleaning up upload blob..."
  az storage blob delete \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "fcos-upload" \
    --name "${BLOB_NAME}" \
    --auth-mode key \
    -o none
fi

# -----------------------------------------------------------------------
# Sysext files
# -----------------------------------------------------------------------
FLATCAR_SYSEXTS=(
  "kubernetes-v1.33.2-x86-64.raw|https://extensions.flatcar.org/extensions/kubernetes-v1.33.2-x86-64.raw"
  "kubernetes-v1.33.10-x86-64.raw|https://extensions.flatcar.org/extensions/kubernetes-v1.33.10-x86-64.raw"
  "kubernetes-v1.33.12-x86-64.raw|https://extensions.flatcar.org/extensions/kubernetes-v1.33.12-x86-64.raw"
  "tailscale-v1.94.1-x86-64.raw|https://extensions.flatcar.org/extensions/tailscale-v1.94.1-x86-64.raw"
)

FEDORA_SYSEXTS=(
  "kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw|https://extensions.fcos.fr/fedora/kubernetes-1.33/kubernetes-1.33-1.33.10-1.fc44-44-x86-64.raw"
  "kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw|https://extensions.fcos.fr/fedora/kubernetes-1.33/kubernetes-1.33-1.33.12-1.fc44-44-x86-64.raw"
)

upload_sysext() {
  local prefix="$1"   # flatcar or fedora
  local filename="$2"
  local url="$3"
  local local_path="${VHD_CACHE_DIR}/${filename}"
  local blob_path="${prefix}/${filename}"

  # Check local cache first — skip download and upload if both exist
  if [ ! -f "${local_path}" ]; then
    echo "    Downloading ${filename}..."
    curl -fL --progress-bar --retry 3 --retry-delay 5 -o "${local_path}" "${url}"
  else
    echo "    Using cached ${filename}"
  fi

  # Check if already in blob storage
  EXISTS=$(az storage blob exists \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "${STORAGE_CONTAINER}" \
    --name "${blob_path}" \
    --auth-mode key \
    --query exists -o tsv 2>/dev/null || echo "false")

  if [ "${EXISTS}" = "true" ]; then
    echo "    Already uploaded: ${blob_path}"
    return
  fi

  echo "    Uploading ${blob_path}..."
  az storage blob upload \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "${STORAGE_CONTAINER}" \
    --name "${blob_path}" \
    --file "${local_path}" \
    --auth-mode key \
    -o none
}

echo ""
ts "Uploading all sysexts to blob storage (parallel)..."
_pids=()
for entry in "${FLATCAR_SYSEXTS[@]}"; do
  filename="${entry%%|*}"
  url="${entry##*|}"
  upload_sysext "flatcar" "${filename}" "${url}" &
  _pids+=($!)
done
for entry in "${FEDORA_SYSEXTS[@]}"; do
  filename="${entry%%|*}"
  url="${entry##*|}"
  upload_sysext "fedora" "${filename}" "${url}" &
  _pids+=($!)
done
_failed=0
for _pid in "${_pids[@]}"; do
  wait "$_pid" || _failed=1
done
[ "$_failed" -eq 0 ] || { echo "ERROR: one or more sysext uploads failed"; exit 1; }
ts "All sysexts uploaded."

# -----------------------------------------------------------------------
# Generate and upload SHA256SUMS for each prefix
# (sysupdate fetches <Path>/SHA256SUMS to discover available versions)
# -----------------------------------------------------------------------
gen_and_upload_sha256sums() {
  local prefix="$1"
  shift
  local files=("$@")

  local sums_file="${WORK_DIR}/${prefix}-SHA256SUMS"
  > "${sums_file}"
  for f in "${files[@]}"; do
    local cached="${VHD_CACHE_DIR}/${f}"
    if [ -f "${cached}" ]; then
      sha256sum "${cached}" | awk -v fn="${f}" '{print $1 "  " fn}' >> "${sums_file}"
    fi
  done

  az storage blob upload \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "${STORAGE_CONTAINER}" \
    --name "${prefix}/SHA256SUMS" \
    --file "${sums_file}" \
    --overwrite \
    --auth-mode key \
    -o none
  echo "    Uploaded ${prefix}/SHA256SUMS"
}

echo ""
ts "Generating SHA256SUMS..."

FLATCAR_FILES=()
for entry in "${FLATCAR_SYSEXTS[@]}"; do
  FLATCAR_FILES+=("${entry%%|*}")
done

FEDORA_FILES=()
for entry in "${FEDORA_SYSEXTS[@]}"; do
  FEDORA_FILES+=("${entry%%|*}")
done

gen_and_upload_sha256sums "flatcar" "${FLATCAR_FILES[@]}" &
gen_and_upload_sha256sums "fedora"  "${FEDORA_FILES[@]}" &
wait

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
BLOB_BASE="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}"
FCOS_IMAGE_ID=$(az image show \
  --resource-group "${AZ_RG_INFRA}" \
  --name "${FCOS_IMAGE_NAME}" \
  --query "id" -o tsv)

echo ""
ts "prep-infra.sh complete!"
echo ""
echo "    FCoOS image ID:   ${FCOS_IMAGE_ID}"
echo "    Blob base URL:    ${BLOB_BASE}"
echo ""
echo "    Flatcar sysexts:  ${BLOB_BASE}/flatcar/"
echo "    Fedora sysexts:   ${BLOB_BASE}/fedora/"
echo ""
echo "    Next: run ./setup.sh to create VMs."
