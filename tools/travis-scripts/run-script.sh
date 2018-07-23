#!/bin/bash

# exit this script if any commmand fails
set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COCOS2DX_ROOT="$DIR"/../..

function build_linux_mac()
{
    echo "Building  ..."
    echo $TRAVIS_BUILD_DIR
    mkdir -p $COCOS2DX_ROOT/build
    cd $COCOS2DX_ROOT/build
    cmake ..
    cmake --build .
    ctest --verbose
}

function build_android_armeabi_v7a()
{
    source ../environment.sh

    echo "Building build_android_armeabi ..."
    echo $TRAVIS_BUILD_DIR

    mkdir -p $COCOS2DX_ROOT/build
    cd $COCOS2DX_ROOT/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=$COCOS2DX_ROOT/tools/android_armeabi_v7a_toolchain.cmake -G Ninja
    cmake --build .
}

function build_android_x86()
{
    source ../environment.sh

    echo "Building build_android_armeabi ..."
    echo $TRAVIS_BUILD_DIR

    mkdir -p $COCOS2DX_ROOT/build
    cd $COCOS2DX_ROOT/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=$COCOS2DX_ROOT/tools/android_x86_toolchain.cmake -G Ninja
    cmake --build .
}

function build_android_x86_64()
{
    source ../environment.sh

    echo "Building build_android_armeabi ..."
    echo $TRAVIS_BUILD_DIR

    mkdir -p $COCOS2DX_ROOT/build
    cd $COCOS2DX_ROOT/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=$COCOS2DX_ROOT/tools/android_x86_64_toolchain.cmake -G Ninja
    cmake --build .
}

function build_android_arm64_v8a()
{
    source ../environment.sh

    echo "Building build_android_armeabi ..."
    echo $TRAVIS_BUILD_DIR

    mkdir -p $COCOS2DX_ROOT/build
    cd $COCOS2DX_ROOT/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=$COCOS2DX_ROOT/tools/android_arm64_v8a_toolchain.cmake -G Ninja
    cmake --build .
}

function android_game12()
{
    source ../environment.sh

    cd $COCOS2DX_ROOT/game1/android
    ./gradlew assembleRelease

    cd $COCOS2DX_ROOT/game2/android
    ./gradlew assembleRelease
}

function build_ios()
{
    mkdir -p $COCOS2DX_ROOT/build_ios
    cd $COCOS2DX_ROOT/build_ios
    cmake .. -DCMAKE_TOOLCHAIN_FILE=../tools/ios.toolchain.cmake
    cmake --build .
}

if [ "$BUILD_TARGET" == "ios_build" ]; then
    build_ios
    exit 0
fi

if [ "$BUILD_TARGET" == "android_lib_armeabi_v7a" ]; then
    build_android_armeabi_v7a
    exit 0
fi

if [ "$BUILD_TARGET" == "android_lib_x86" ]; then
    build_android_x86
    exit 0
fi

if [ "$BUILD_TARGET" == "android_lib_x86_64" ]; then
    build_android_x86_64
    exit 0
fi

if [ "$BUILD_TARGET" == "android_lib_arm64_v8a" ]; then
    build_android_arm64_v8a
    exit 0
fi

if [ "$BUILD_TARGET" == "android_game12" ]; then
    android_game12
    exit 0
fi

build_linux_mac
