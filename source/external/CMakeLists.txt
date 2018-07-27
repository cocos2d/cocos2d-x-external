cmake_minimum_required(VERSION 3.6)
project(external)

add_subdirectory(Box2D)
add_subdirectory(recast)

add_library(external empty.cpp)
target_link_libraries(external Box2D recast)

if(ANDROID)
    add_subdirectory(android-specific/pvmp3dec)
    add_subdirectory(android-specific/tremolo)
    target_link_libraries(external pvmp3dec tremolo)
endif()