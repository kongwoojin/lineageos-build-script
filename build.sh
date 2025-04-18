#!/bin/bash

# Load .env
set -a ; . ./.env ; set +a

# Check if DEVICE and BRANCH are provided as arguments, otherwise set default values
if [ -z "$1" ]; then
  echo "Error: Device codename not provided. Usage: ./build.sh <device> <branch>"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Error: Branch not provided. Usage: ./build.sh <device> <branch>"
  exit 1
fi

DEVICE="$1"  # Device codename (from first argument)
BRANCH="$2"  # Branch name (from second argument)

VERSION=$(echo ${BRANCH} | sed -E 's/lineage-([0-9]+)(\.[0-9]+)?/\1\2/')

export DEVICE
export VERSION

eval $(envsubst < .env)

JOBS=$(nproc)  # Number of build jobs
WORKSPACE=$(pwd)  # Set workspace to the current directory
JSON_FILE="$WORKSPACE/${DEVICE}.json"  # Path to the generated JSON file
REMOTE_SERVER="$REMOTE_SERVER_SSH_URL"  # Remote server address
REMOTE_USER="$REMOTE_SERVER_SSH_USER"  # SSH username
OUT_DIR="/hdd1/aosp/lineage/${VERSION}"  # Build output directory
ZIP_FILE="$OUT_DIR/target/product/${DEVICE}/lineage-*.zip"  # Path to the generated ROM file
SHA256SUM_FILE="$OUT_DIR/target/product/${DEVICE}/lineage-*.zip.sha256sum"  # Path to the sha256sum
RECOVERY_FILE="$OUT_DIR/target/product/${DEVICE}/recovery.img"  # Path to the recovery file
if [[ ! $VERSION =~ \. ]]; then
    VERSION="${VERSION}.0"
fi
OTA_DIR="$REMOTE_SERVER_OTA_JSON_DIR"
DOWNLOAD_DIR="$REMOTE_SERVER_OTA_FILE_DIR"
PATH="$HOME/bin:$PATH"

function sync() {
    # Initialize the repository with Git LFS
    if [ ! -d "$WORKSPACE/.repo" ]; then
    echo "Initializing LineageOS repository with Git LFS..."
    repo init -u https://github.com/LineageOS/android.git -b ${BRANCH} --git-lfs
    else
    echo "Repository already initialized."
    fi

    # Sync the source code
    echo "Syncing LineageOS source code..."
    repo sync --force-sync --no-tags --no-clone-bundle -j${JOBS} -c
}

function clean() {
  echo "Cleanup output directory..."
  rm -rf $OUT_DIR
}

function build() {
    # Set up the build environment
    echo "Setting up build environment with breakfast..."
    source build/envsetup.sh

    export OUT_DIR=$OUT_DIR

    breakfast ${DEVICE}

    # Build LineageOS
    echo "Building LineageOS with brunch..."
    brunch ${DEVICE}
}

function generate_ota() {
    # Generate update.json using Python
    echo "Generating update.json with Python script..."
    python3 ${WORKSPACE}/generate.py ${DEVICE} ${OUT_DIR}
}

function upload() {
    # Upload artifacts via SCP
    echo "Uploading ROM zip file, and recovery image via SCP..."
    scp -P 212 -O ${ZIP_FILE} ${SHA256SUM_FILE} ${RECOVERY_FILE} ${REMOTE_USER}@${REMOTE_SERVER}:${DOWNLOAD_DIR}
    echo "Uploading update.json via SCP..."
    scp -P 212 -O ${JSON_FILE} ${REMOTE_USER}@${REMOTE_SERVER}:${OTA_DIR}
}

clean
sync
build
generate_ota
upload
