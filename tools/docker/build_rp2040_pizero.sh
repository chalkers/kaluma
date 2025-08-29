#!/usr/bin/env bash
set -euo pipefail

BOARD_NAME=rp2040-pizero
IMAGE_NAME="kaluma-${BOARD_NAME}"

# Host UF2 output directory (project-local)
HOST_OUT_DIR="${PWD}/build"
mkdir -p "${HOST_OUT_DIR}"

# Build image
docker build -f docker/Dockerfile.rp2040-pizero -t "${IMAGE_NAME}" .

# Run build container and copy UF2 artifact to host volume
docker run --rm -v "${HOST_OUT_DIR}:/out" "${IMAGE_NAME}" bash -lc '
  set -e
  ls -la build || true
  cp -v build/*.uf2 /out/
'

echo "UF2(s) copied to ${HOST_OUT_DIR}"

