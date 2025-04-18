#!/bin/bash

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
OTA_DIR="$REMOTE_SERVER_OTA_JSON_DIR"
PATH="$HOME/bin:$PATH"

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

build
