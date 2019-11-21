cmake_minimum_required(VERSION 3.6)

project(minilua C)

message(STATUS "Current Compiler ${CMAKE_C_COMPILER}")
#message(STATUS "Current Path $ENV{PATH}")

if(MSVC)
    add_definitions(
        /D_CRT_SECURE_NO_DEPRECATE
        /D_CRT_SECURE_NO_WARNINGS
    )
endif()

### minilua
add_executable(minilua
    ${CMAKE_CURRENT_LIST_DIR}/../host/minilua.c
)

target_include_directories(minilua PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/../
)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    target_link_libraries(minilua m)
endif()