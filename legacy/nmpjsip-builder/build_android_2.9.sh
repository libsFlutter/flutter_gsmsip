#!/bin/bash
set -e

PJSIP_VERSION="2.9"
IMAGE_NAME="react-native-sip2-builder/android_${PJSIP_VERSION}"
CONTAINER_NAME="react-native-sip2-builder-${RANDOM}"


rm -rf ./dist/android;
rm -rf ./dist/android_${PJSIP_VERSION};
mkdir -p ./dist/;

rm -rf ./android_${PJSIP_VERSION}/patch
cp -r ./src/patch_${PJSIP_VERSION} ./android_${PJSIP_VERSION}/patch


#docker build -t react-native-pjsip-builder/android ./android/;
#docker run --name ${CONTAINER_NAME} ${IMAGE_NAME} bin/true -v /home/anton/proj/telefon.one/private/react-native-sip2-builder/src/pjsip2:/sources/pjsip2:nocopy


docker build -t ${IMAGE_NAME} ./android_${PJSIP_VERSION}/;
#docker build --no-cache -t react-native-sip2-builder/android ./android/;

#echo copy
#docker cp ./src/pjproject-2.7.1 ${CONTAINER_NAME}:/sources
#docker cp ./src/pjsip2 ${CONTAINER_NAME}:/sources
#echo copy OK

#docker run --name ${CONTAINER_NAME} ${IMAGE_NAME}  -v ./src/pjsip3:/sources/pjsip3:nocopy ls /sources
#docker run --name ${CONTAINER_NAME} ${IMAGE_NAME} ls /sources/pjsip2/build_pjsip.sh -v ./src/pjsip2:/sources/pjsip2:nocopy
#docker run --name ${CONTAINER_NAME} ${IMAGE_NAME} bin/true

docker run --name ${CONTAINER_NAME} ${IMAGE_NAME} bin/true

docker cp ${CONTAINER_NAME}:/dist/android ./dist/android_${PJSIP_VERSION}
docker rm ${CONTAINER_NAME}
