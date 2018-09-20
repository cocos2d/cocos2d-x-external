cmake_minimum_required(VERSION 3.6)
project(external)

if(ANDROID)
    add_subdirectory(android-specific/cpufeatures)
    add_subdirectory(android-specific/pvmp3dec)
    add_subdirectory(android-specific/tremolo)
endif()

add_subdirectory(Box2D)
add_subdirectory(chipmunk)
add_subdirectory(freetype)
add_subdirectory(recast)
add_subdirectory(zlib)
# add_subdirectory(bullet)
# add_subdirectory(curl)
# add_subdirectory(glfw)
add_subdirectory(jpeg)
# add_subdirectory(lua)
# add_subdirectory(luajit)
# add_subdirectory(openssl)
add_subdirectory(png)
# add_subdirectory(rapidjson)
add_subdirectory(tiff)
add_subdirectory(uv)
add_subdirectory(webp)
# add_subdirectory(websockets)

add_library(external empty.cpp)

target_link_libraries(external
    Box2D
    chipmunk
    freetype
    recast
    zlib
    # bullet
    # curl
    # glfw
    jpeg
    # lua
    # luajit
    # openssl
    png
    # rapidjson
    tiff
    uv_a
    webp
    # websockets
)

if(ANDROID)
    target_link_libraries(external pvmp3dec tremolo)
endif()
