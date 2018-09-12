# main cmake
cmake_minimum_required(VERSION 3.6)
project(modern_cmake)

# TODO: check why target_compile_features does work for IOS
# Options set as global for IOS
if (IOS)
    set(CMAKE_CXX_STANDARD 11)
endif()

set(CXX_STANDARD_REQUIRED ON)
set(CXX_EXTENSIONS OFF)

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)
