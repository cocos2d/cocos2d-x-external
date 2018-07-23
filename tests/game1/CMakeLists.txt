cmake_minimum_required(VERSION 3.6)
project(game1)

if(${CMAKE_SYSTEM_NAME} MATCHES "Android")
    add_library(game1 SHARED
        android/app/src/main/cpp/hello-jni.cpp)
    target_link_libraries(game1 android log)
else()
    add_executable(game1 main.cpp)

    add_test(NAME game1 COMMAND game1)
endif()

target_link_libraries(game1 engine)
