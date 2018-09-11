cmake_minimum_required(VERSION 3.6)
project(engine)


add_library(engine engine.cpp)
target_include_directories(engine PUBLIC ..)
target_link_libraries(engine external)
