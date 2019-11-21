cmake_minimum_required(VERSION 3.6)

project(buildvm C)


if(MSVC)
    add_definitions(
        /D_CRT_SECURE_NO_DEPRECATE
        /D_CRT_SECURE_NO_WARNINGS
    )
    set(BUILD_WIN32 ON)
    set(BUILD_WIN64 OFF)
    if("${CMAKE_GENERATOR}" MATCHES ".*in64$" OR "${CMAKE_GENERATOR}" MATCHES ".*2019$")
        set(BUILD_WIN32 OFF)
        set(BUILD_WIN64 ON)
    endif()


    if(BUILD_WIN32)
        set(CMAKE_C_FLAGS  /arch:SSE2)
        set(CMAKE_CXX_FLAGS  /arch:SSE2)
    endif()
endif()

message(STATUS "Current Compiler ${CMAKE_C_COMPILER}")
#message(STATUS "Current Path $ENV{PATH}")

### minilua
add_executable(buildvm
    ${CMAKE_CURRENT_LIST_DIR}/../host/buildvm.c 
    ${CMAKE_CURRENT_LIST_DIR}/../host/buildvm_asm.c 
    ${CMAKE_CURRENT_LIST_DIR}/../host/buildvm_peobj.c 
    ${CMAKE_CURRENT_LIST_DIR}/../host/buildvm_lib.c
    ${CMAKE_CURRENT_LIST_DIR}/../host/buildvm_fold.c
    ${CMAKE_CURRENT_LIST_DIR}/../host/buildvm_arch.h
)


target_include_directories(buildvm PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/..
    ${CMAKE_CURRENT_LIST_DIR}/../host
    ${CMAKE_CURRENT_LIST_DIR}/../../dynasm
)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    target_link_libraries(buildvm m)
endif()