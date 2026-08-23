#!/bin/bash
set -e

#rm -rf ./dist;
#./build_android.sh;
#./build_ios.sh;

cd ./dist;

tar -czvf ../../react-native-sip2-builder.releases/release.tar.gz ./