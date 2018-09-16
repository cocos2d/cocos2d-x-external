cmake_minimum_required(VERSION 3.6)
project(cpufeatures)

add_library(cpufeatures ${CMAKE_ANDROID_NDK}/sources/android/cpufeatures/cpu-features.c)

target_link_libraries(cpufeatures dl)
target_include_directories(cpufeatures PUBLIC ${CMAKE_ANDROID_NDK}/sources/android/cpufeatures)
