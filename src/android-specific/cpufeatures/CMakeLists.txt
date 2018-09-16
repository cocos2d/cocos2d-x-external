cmake_minimum_required(VERSION 3.6)
project(cpufeatures)


# CMake from android SDK set ANDROID_NDK instead of CMAKE_ANDROID_NDK
if(ANDROID_NDK)
    add_library(cpufeatures ${ANDROID_NDK}/sources/android/cpufeatures/cpu-features.c)
    target_include_directories(cpufeatures PUBLIC ${ANDROID_NDK}/sources/android/cpufeatures)
else()
    add_library(cpufeatures ${CMAKE_ANDROID_NDK}/sources/android/cpufeatures/cpu-features.c)
    target_include_directories(cpufeatures PUBLIC ${CMAKE_ANDROID_NDK}/sources/android/cpufeatures)
endif()

target_link_libraries(cpufeatures dl)
