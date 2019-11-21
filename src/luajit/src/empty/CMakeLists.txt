cmake_minimum_required(VERSION 3.6)

project(empty C)
message(STATUS "CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}")
message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

add_executable(empty empty.c)




set(default_flags ${CMAKE_C_FLAGS})
separate_arguments(default_flags)
execute_process(COMMAND ${CMAKE_C_COMPILER} 
    ${default_flags}
    --target=${CMAKE_C_COMPILER_TARGET}
    --gcc-toolchain=${ANDROID_TOOLCHAIN_ROOT}
    -D_FILE_OFFSET_BITS=64 
    -D_LARGETFILE_SOURCE 
    -U_FORTIFY_SOURCE 
    -E ${CMAKE_CURRENT_LIST_DIR}/../lj_arch.h 
    -dM
    #-arch armeabi-v7a
    #-march=${ANDROID_ABI}
    -mfloat-abi=softfp -Wl,--fix-cortex-a8
    OUTPUT_VARIABLE TARGET_TESTARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
#message(WARNING "TARGET_TESTARCH: ${TARGET_TESTARCH}")
file(WRITE "C:/Projects/output.txt" ${TARGET_TESTARCH})