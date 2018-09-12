# based on https://github.com/opencv/opencv/tree/master/3rdparty/libjpeg
cmake_minimum_required(VERSION 3.6)
project(jpeg)

file(GLOB lib_srcs *.c)
file(GLOB lib_hdrs *.h)

if(ANDROID OR IOS OR APPLE)
  list(FILTER lib_srcs EXCLUDE REGEX "jmemansi.c")
else()
  list(FILTER lib_srcs EXCLUDE REGEX "jmemnobs.c")
endif()

if(WINRT)
    target_compile_definitions(jpeg PRIVATE NO_GETENV)
    get_directory_property( DirDefs COMPILE_DEFINITIONS )
    message(STATUS "Adding NO_GETENV to compiler definitions for WINRT:")
    message(STATUS "   COMPILE_DEFINITIONS = ${DirDefs}")
endif()

add_library(jpeg STATIC ${lib_srcs} ${lib_hdrs})
target_include_directories(jpeg PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
