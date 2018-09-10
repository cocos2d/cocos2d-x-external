#!/bin/bash

# exit this script if any commmand fails
set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COCOS2DX_ROOT="$DIR"/../..


if [ "$BUILD_TARGET" == "android_lib_armeabi_v7a" ] || [ "$BUILD_TARGET" == "android_lib_x86" ] || [ "$BUILD_TARGET" == "android_lib_arm64_v8a" ] || [ "$BUILD_TARGET" == "android_lib_x86_64" ]; then
    sudo apt-get update
    sudo apt-get install ninja-build
    ninja --version
    python $COCOS2DX_ROOT/tools/appveyor-scripts/setup_android.py --ndk_only
    exit 0
fi

if [ "$BUILD_TARGET" == "android_game12" ]; then
    python $COCOS2DX_ROOT/tools/appveyor-scripts/setup_android.py
    exit 0
fi

if [ "$BUILD_TARGET" == "linux" ]; then
    eval "CC=gcc-7 && CXX=g++-7"
fi

echo "before-install.sh execution finished!"
