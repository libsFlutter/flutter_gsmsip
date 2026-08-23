#!/bin/bash
set -e

TARGET_ARCH=$1
TARGET_PATH=/output/pjsip/${TARGET_ARCH}


#cd /tmp/pjsip
#ls
#echo +++++
cp -r /sources/patch/src/pjsip2/* /tmp/pjsip
cd /tmp/pjsip
#ls
#echo ------

#cat /tmp/pjsip/pjlib/include/pj/config_site.h
#exit 1;


cd /tmp/pjsip

export TARGET_ABI=${TARGET_ARCH}
export APP_PLATFORM=android-${ANDROID_TARGET_API}
export ANDROID_NDK_ROOT=/sources/android_ndk

#./configure-android \
#    --use-ndk-cflags \
#    --with-ssl="/output/openssl/${TARGET_ARCH}" \
#    --with-openh264="/output/openh264/${TARGET_ARCH}" \
#    --with-opus="/output/opus/${TARGET_ARCH}"

make dep
make

cd /tmp/pjsip/pjsip-apps/src/swig
make

mkdir -p /output/pjsip/jniLibs/${TARGET_ARCH}/
mv ./java/android/app/src/main/jniLibs/**/libpjsua2.so /output/pjsip/jniLibs/${TARGET_ARCH}/

if [ ! -d "/output/pjsip/java" ]; then
  mv ./java/android/app/src/main/java /output/pjsip/java
fi

#rm -rf /tmp/pjsip