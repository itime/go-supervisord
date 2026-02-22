#!/bin/bash
set -e

APP_NAME="supervisord"
CELLAR_DIR="/usr/local/Cellar/${APP_NAME}"
BIN_PATH="/usr/local/bin/${APP_NAME}"
VERSION="${APP_NAME}-$(date +%Y%m%d_%H%M%S)"
KEEP_VERSIONS=10

cd "$(dirname "$0")"

echo "Building ${APP_NAME}..."
go build -o "${VERSION}" .

echo "Installing ${VERSION}..."
sudo mkdir -p "${CELLAR_DIR}"
sudo mv "${VERSION}" "${CELLAR_DIR}/"
sudo ln -sf "${CELLAR_DIR}/${VERSION}" "${BIN_PATH}"

echo "Cleaning old versions (keeping ${KEEP_VERSIONS})..."
cd "${CELLAR_DIR}"
ls -t | tail -n +$((KEEP_VERSIONS + 1)) | xargs -I {} sudo rm -f {} 2>/dev/null || true

echo "Restarting ${APP_NAME}..."
sudo pkill -f "${APP_NAME} -c" 2>/dev/null || true
sleep 1
sudo "${BIN_PATH}" -c /opt/homebrew/etc/supervisord.conf -d

echo "Done. Current version:"
ls -la "${BIN_PATH}"
