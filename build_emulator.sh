#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: Branch not provided. Usage: ./build_emulator.sh <branch>"
  exit 1
fi
BRANCH="$1"  # Branch name (from first argument)
DEVICE="sdk_phone_x86_64"  # Device codename

VERSION=$(echo ${BRANCH} | sed -E 's/lineage-([0-9]+)(\.[0-9]+)?/\1\2/')

export DEVICE
export VERSION

eval $(envsubst < .env)

JOBS=$(nproc)  # Number of build jobs
WORKSPACE=$(pwd)  # Set workspace to the current directory
JSON_FILE="$WORKSPACE/${DEVICE}.json"  # Path to the generated JSON file
REMOTE_SERVER="$REMOTE_SERVER_SSH_URL"  # Remote server address
REMOTE_USER="$REMOTE_SERVER_SSH_USER"  # SSH username
VERSION=$(echo ${BRANCH} | sed -E 's/lineage-([0-9]+)(\.[0-9]+)?/\1\2/')
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

function build() {
    # Set up the build environment
    echo "Setting up build environment with breakfast..."
    source build/envsetup.sh

    export OUT_DIR=$OUT_DIR

    breakfast ${DEVICE} eng

    # Build LineageOS
    echo "Building LineageOS with brunch..."
    mka -j8

    mka emu_img_zip
}

function build_release() {
    # Set up the build environment
    echo "Setting up build environment with breakfast..."
    source build/envsetup.sh

    export OUT_DIR=$OUT_DIR

    breakfast ${DEVICE} eng

    # Build LineageOS
    echo "Building LineageOS with brunch..."
    mka -j8

    croot
    sign_target_files_apks -o -d vendor/lineage-priv/keys \
    --extra_apks AdServicesApk.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks FederatedCompute.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks HalfSheetUX.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks HealthConnectBackupRestore.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks HealthConnectController.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks OsuLogin.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks SafetyCenterResources.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks ServiceConnectivityResources.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks ServiceUwbResources.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks ServiceWifiResources.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks WifiDialog.apk=vendor/lineage-priv/keys/releasekey \
    --extra_apks com.android.adbd.apex=vendor/lineage-priv/keys/com.android.adbd \
    --extra_apks com.android.adservices.apex=vendor/lineage-priv/keys/com.android.adservices \
    --extra_apks com.android.adservices.api.apex=vendor/lineage-priv/keys/com.android.adservices.api \
    --extra_apks com.android.appsearch.apex=vendor/lineage-priv/keys/com.android.appsearch \
    --extra_apks com.android.appsearch.apk.apex=vendor/lineage-priv/keys/com.android.appsearch.apk \
    --extra_apks com.android.art.apex=vendor/lineage-priv/keys/com.android.art \
    --extra_apks com.android.bluetooth.apex=vendor/lineage-priv/keys/com.android.bluetooth \
    --extra_apks com.android.btservices.apex=vendor/lineage-priv/keys/com.android.btservices \
    --extra_apks com.android.cellbroadcast.apex=vendor/lineage-priv/keys/com.android.cellbroadcast \
    --extra_apks com.android.compos.apex=vendor/lineage-priv/keys/com.android.compos \
    --extra_apks com.android.configinfrastructure.apex=vendor/lineage-priv/keys/com.android.configinfrastructure \
    --extra_apks com.android.connectivity.resources.apex=vendor/lineage-priv/keys/com.android.connectivity.resources \
    --extra_apks com.android.conscrypt.apex=vendor/lineage-priv/keys/com.android.conscrypt \
    --extra_apks com.android.devicelock.apex=vendor/lineage-priv/keys/com.android.devicelock \
    --extra_apks com.android.extservices.apex=vendor/lineage-priv/keys/com.android.extservices \
    --extra_apks com.android.graphics.pdf.apex=vendor/lineage-priv/keys/com.android.graphics.pdf \
    --extra_apks com.android.hardware.authsecret.apex=vendor/lineage-priv/keys/com.android.hardware.authsecret \
    --extra_apks com.android.hardware.biometrics.face.virtual.apex=vendor/lineage-priv/keys/com.android.hardware.biometrics.face.virtual \
    --extra_apks com.android.hardware.biometrics.fingerprint.virtual.apex=vendor/lineage-priv/keys/com.android.hardware.biometrics.fingerprint.virtual \
    --extra_apks com.android.hardware.boot.apex=vendor/lineage-priv/keys/com.android.hardware.boot \
    --extra_apks com.android.hardware.cas.apex=vendor/lineage-priv/keys/com.android.hardware.cas \
    --extra_apks com.android.hardware.neuralnetworks.apex=vendor/lineage-priv/keys/com.android.hardware.neuralnetworks \
    --extra_apks com.android.hardware.rebootescrow.apex=vendor/lineage-priv/keys/com.android.hardware.rebootescrow \
    --extra_apks com.android.hardware.wifi.apex=vendor/lineage-priv/keys/com.android.hardware.wifi \
    --extra_apks com.android.healthfitness.apex=vendor/lineage-priv/keys/com.android.healthfitness \
    --extra_apks com.android.hotspot2.osulogin.apex=vendor/lineage-priv/keys/com.android.hotspot2.osulogin \
    --extra_apks com.android.i18n.apex=vendor/lineage-priv/keys/com.android.i18n \
    --extra_apks com.android.ipsec.apex=vendor/lineage-priv/keys/com.android.ipsec \
    --extra_apks com.android.media.apex=vendor/lineage-priv/keys/com.android.media \
    --extra_apks com.android.media.swcodec.apex=vendor/lineage-priv/keys/com.android.media.swcodec \
    --extra_apks com.android.mediaprovider.apex=vendor/lineage-priv/keys/com.android.mediaprovider \
    --extra_apks com.android.nearby.halfsheet.apex=vendor/lineage-priv/keys/com.android.nearby.halfsheet \
    --extra_apks com.android.networkstack.tethering.apex=vendor/lineage-priv/keys/com.android.networkstack.tethering \
    --extra_apks com.android.neuralnetworks.apex=vendor/lineage-priv/keys/com.android.neuralnetworks \
    --extra_apks com.android.nfcservices.apex=vendor/lineage-priv/keys/com.android.nfcservices \
    --extra_apks com.android.ondevicepersonalization.apex=vendor/lineage-priv/keys/com.android.ondevicepersonalization \
    --extra_apks com.android.os.statsd.apex=vendor/lineage-priv/keys/com.android.os.statsd \
    --extra_apks com.android.permission.apex=vendor/lineage-priv/keys/com.android.permission \
    --extra_apks com.android.profiling.apex=vendor/lineage-priv/keys/com.android.profiling \
    --extra_apks com.android.resolv.apex=vendor/lineage-priv/keys/com.android.resolv \
    --extra_apks com.android.rkpd.apex=vendor/lineage-priv/keys/com.android.rkpd \
    --extra_apks com.android.runtime.apex=vendor/lineage-priv/keys/com.android.runtime \
    --extra_apks com.android.safetycenter.resources.apex=vendor/lineage-priv/keys/com.android.safetycenter.resources \
    --extra_apks com.android.scheduling.apex=vendor/lineage-priv/keys/com.android.scheduling \
    --extra_apks com.android.sdkext.apex=vendor/lineage-priv/keys/com.android.sdkext \
    --extra_apks com.android.support.apexer.apex=vendor/lineage-priv/keys/com.android.support.apexer \
    --extra_apks com.android.telephony.apex=vendor/lineage-priv/keys/com.android.telephony \
    --extra_apks com.android.telephonymodules.apex=vendor/lineage-priv/keys/com.android.telephonymodules \
    --extra_apks com.android.tethering.apex=vendor/lineage-priv/keys/com.android.tethering \
    --extra_apks com.android.tzdata.apex=vendor/lineage-priv/keys/com.android.tzdata \
    --extra_apks com.android.uwb.apex=vendor/lineage-priv/keys/com.android.uwb \
    --extra_apks com.android.uwb.resources.apex=vendor/lineage-priv/keys/com.android.uwb.resources \
    --extra_apks com.android.virt.apex=vendor/lineage-priv/keys/com.android.virt \
    --extra_apks com.android.vndk.current.apex=vendor/lineage-priv/keys/com.android.vndk.current \
    --extra_apks com.android.vndk.current.on_vendor.apex=vendor/lineage-priv/keys/com.android.vndk.current.on_vendor \
    --extra_apks com.android.wifi.apex=vendor/lineage-priv/keys/com.android.wifi \
    --extra_apks com.android.wifi.dialog.apex=vendor/lineage-priv/keys/com.android.wifi.dialog \
    --extra_apks com.android.wifi.resources.apex=vendor/lineage-priv/keys/com.android.wifi.resources \
    --extra_apks com.google.pixel.camera.hal.apex=vendor/lineage-priv/keys/com.google.pixel.camera.hal \
    --extra_apks com.google.pixel.vibrator.hal.apex=vendor/lineage-priv/keys/com.google.pixel.vibrator.hal \
    --extra_apks com.qorvo.uwb.apex=vendor/lineage-priv/keys/com.qorvo.uwb \
    --extra_apex_payload_key com.android.adbd.apex=vendor/lineage-priv/keys/com.android.adbd.pem \
    --extra_apex_payload_key com.android.adservices.apex=vendor/lineage-priv/keys/com.android.adservices.pem \
    --extra_apex_payload_key com.android.adservices.api.apex=vendor/lineage-priv/keys/com.android.adservices.api.pem \
    --extra_apex_payload_key com.android.appsearch.apex=vendor/lineage-priv/keys/com.android.appsearch.pem \
    --extra_apex_payload_key com.android.appsearch.apk.apex=vendor/lineage-priv/keys/com.android.appsearch.apk.pem \
    --extra_apex_payload_key com.android.art.apex=vendor/lineage-priv/keys/com.android.art.pem \
    --extra_apex_payload_key com.android.bluetooth.apex=vendor/lineage-priv/keys/com.android.bluetooth.pem \
    --extra_apex_payload_key com.android.btservices.apex=vendor/lineage-priv/keys/com.android.btservices.pem \
    --extra_apex_payload_key com.android.cellbroadcast.apex=vendor/lineage-priv/keys/com.android.cellbroadcast.pem \
    --extra_apex_payload_key com.android.compos.apex=vendor/lineage-priv/keys/com.android.compos.pem \
    --extra_apex_payload_key com.android.configinfrastructure.apex=vendor/lineage-priv/keys/com.android.configinfrastructure.pem \
    --extra_apex_payload_key com.android.connectivity.resources.apex=vendor/lineage-priv/keys/com.android.connectivity.resources.pem \
    --extra_apex_payload_key com.android.conscrypt.apex=vendor/lineage-priv/keys/com.android.conscrypt.pem \
    --extra_apex_payload_key com.android.devicelock.apex=vendor/lineage-priv/keys/com.android.devicelock.pem \
    --extra_apex_payload_key com.android.extservices.apex=vendor/lineage-priv/keys/com.android.extservices.pem \
    --extra_apex_payload_key com.android.graphics.pdf.apex=vendor/lineage-priv/keys/com.android.graphics.pdf.pem \
    --extra_apex_payload_key com.android.hardware.authsecret.apex=vendor/lineage-priv/keys/com.android.hardware.authsecret.pem \
    --extra_apex_payload_key com.android.hardware.biometrics.face.virtual.apex=vendor/lineage-priv/keys/com.android.hardware.biometrics.face.virtual.pem \
    --extra_apex_payload_key com.android.hardware.biometrics.fingerprint.virtual.apex=vendor/lineage-priv/keys/com.android.hardware.biometrics.fingerprint.virtual.pem \
    --extra_apex_payload_key com.android.hardware.boot.apex=vendor/lineage-priv/keys/com.android.hardware.boot.pem \
    --extra_apex_payload_key com.android.hardware.cas.apex=vendor/lineage-priv/keys/com.android.hardware.cas.pem \
    --extra_apex_payload_key com.android.hardware.neuralnetworks.apex=vendor/lineage-priv/keys/com.android.hardware.neuralnetworks.pem \
    --extra_apex_payload_key com.android.hardware.rebootescrow.apex=vendor/lineage-priv/keys/com.android.hardware.rebootescrow.pem \
    --extra_apex_payload_key com.android.hardware.wifi.apex=vendor/lineage-priv/keys/com.android.hardware.wifi.pem \
    --extra_apex_payload_key com.android.healthfitness.apex=vendor/lineage-priv/keys/com.android.healthfitness.pem \
    --extra_apex_payload_key com.android.hotspot2.osulogin.apex=vendor/lineage-priv/keys/com.android.hotspot2.osulogin.pem \
    --extra_apex_payload_key com.android.i18n.apex=vendor/lineage-priv/keys/com.android.i18n.pem \
    --extra_apex_payload_key com.android.ipsec.apex=vendor/lineage-priv/keys/com.android.ipsec.pem \
    --extra_apex_payload_key com.android.media.apex=vendor/lineage-priv/keys/com.android.media.pem \
    --extra_apex_payload_key com.android.media.swcodec.apex=vendor/lineage-priv/keys/com.android.media.swcodec.pem \
    --extra_apex_payload_key com.android.mediaprovider.apex=vendor/lineage-priv/keys/com.android.mediaprovider.pem \
    --extra_apex_payload_key com.android.nearby.halfsheet.apex=vendor/lineage-priv/keys/com.android.nearby.halfsheet.pem \
    --extra_apex_payload_key com.android.networkstack.tethering.apex=vendor/lineage-priv/keys/com.android.networkstack.tethering.pem \
    --extra_apex_payload_key com.android.neuralnetworks.apex=vendor/lineage-priv/keys/com.android.neuralnetworks.pem \
    --extra_apex_payload_key com.android.nfcservices.apex=vendor/lineage-priv/keys/com.android.nfcservices.pem \
    --extra_apex_payload_key com.android.ondevicepersonalization.apex=vendor/lineage-priv/keys/com.android.ondevicepersonalization.pem \
    --extra_apex_payload_key com.android.os.statsd.apex=vendor/lineage-priv/keys/com.android.os.statsd.pem \
    --extra_apex_payload_key com.android.permission.apex=vendor/lineage-priv/keys/com.android.permission.pem \
    --extra_apex_payload_key com.android.profiling.apex=vendor/lineage-priv/keys/com.android.profiling.pem \
    --extra_apex_payload_key com.android.resolv.apex=vendor/lineage-priv/keys/com.android.resolv.pem \
    --extra_apex_payload_key com.android.rkpd.apex=vendor/lineage-priv/keys/com.android.rkpd.pem \
    --extra_apex_payload_key com.android.runtime.apex=vendor/lineage-priv/keys/com.android.runtime.pem \
    --extra_apex_payload_key com.android.safetycenter.resources.apex=vendor/lineage-priv/keys/com.android.safetycenter.resources.pem \
    --extra_apex_payload_key com.android.scheduling.apex=vendor/lineage-priv/keys/com.android.scheduling.pem \
    --extra_apex_payload_key com.android.sdkext.apex=vendor/lineage-priv/keys/com.android.sdkext.pem \
    --extra_apex_payload_key com.android.support.apexer.apex=vendor/lineage-priv/keys/com.android.support.apexer.pem \
    --extra_apex_payload_key com.android.telephony.apex=vendor/lineage-priv/keys/com.android.telephony.pem \
    --extra_apex_payload_key com.android.telephonymodules.apex=vendor/lineage-priv/keys/com.android.telephonymodules.pem \
    --extra_apex_payload_key com.android.tethering.apex=vendor/lineage-priv/keys/com.android.tethering.pem \
    --extra_apex_payload_key com.android.tzdata.apex=vendor/lineage-priv/keys/com.android.tzdata.pem \
    --extra_apex_payload_key com.android.uwb.apex=vendor/lineage-priv/keys/com.android.uwb.pem \
    --extra_apex_payload_key com.android.uwb.resources.apex=vendor/lineage-priv/keys/com.android.uwb.resources.pem \
    --extra_apex_payload_key com.android.virt.apex=vendor/lineage-priv/keys/com.android.virt.pem \
    --extra_apex_payload_key com.android.vndk.current.apex=vendor/lineage-priv/keys/com.android.vndk.current.pem \
    --extra_apex_payload_key com.android.vndk.current.on_vendor.apex=vendor/lineage-priv/keys/com.android.vndk.current.on_vendor.pem \
    --extra_apex_payload_key com.android.wifi.apex=vendor/lineage-priv/keys/com.android.wifi.pem \
    --extra_apex_payload_key com.android.wifi.dialog.apex=vendor/lineage-priv/keys/com.android.wifi.dialog.pem \
    --extra_apex_payload_key com.android.wifi.resources.apex=vendor/lineage-priv/keys/com.android.wifi.resources.pem \
    --extra_apex_payload_key com.google.pixel.camera.hal.apex=vendor/lineage-priv/keys/com.google.pixel.camera.hal.pem \
    --extra_apex_payload_key com.google.pixel.vibrator.hal.apex=vendor/lineage-priv/keys/com.google.pixel.vibrator.hal.pem \
    --extra_apex_payload_key com.qorvo.uwb.apex=vendor/lineage-priv/keys/com.qorvo.uwb.pem \
    $OUT/obj/PACKAGING/target_files_intermediates/*-target_files*.zip \
    signed-target_files.zip
    
    ota_from_target_files -k vendor/lineage-priv/keys/releasekey \
    --block --backup=true \
    signed-target_files.zip \
    signed-ota_update.zip
}

build
