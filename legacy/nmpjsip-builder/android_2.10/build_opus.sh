#!/bin/bash
set -e

TARGET_ARCH=$1
TARGET_PATH=/output/opus/${TARGET_ARCH}

export NDK_TOOLCHAIN_VERSION=4.9
export APP_PLATFORM=android-${ANDROID_TARGET_API}
export ANDROID_NDK_ROOT=/sources/android_ndk

cp -r /sources/opus /tmp/opus

cd /tmp/opus/jni
ndk-build APP_ABI="${TARGET_ARCH}" 

mkdir -p ${TARGET_PATH}/include
mkdir -p ${TARGET_PATH}/lib
cp -r ../include ${TARGET_PATH}/include/opus
cp ../obj/local/${TARGET_ARCH}/libopus.a ${TARGET_PATH}/lib/

rm -rf /tmp/pjsip