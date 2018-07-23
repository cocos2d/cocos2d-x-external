cmake_minimum_required(VERSION 3.6)
project(external)

add_subdirectory(Box2D)
add_subdirectory(recast)

add_library(external empty.cpp)
target_link_libraries(external Box2D recast)
