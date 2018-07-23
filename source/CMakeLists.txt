cmake_minimum_required(VERSION 3.6)
project(engine)

add_subdirectory(external)

add_library(engine engine/engine.cpp)
target_include_directories(engine PUBLIC .)
target_link_libraries(engine external)
