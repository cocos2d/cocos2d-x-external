cmake_minimum_required(VERSION 3.6)

project(luajit C)

set(OPT_CLEAN_GENEARTED_FILES ON)
set(TARGET_64BIT OFF)
set(BUILD_WIN32 OFF)
set(BUILD_WIN64 ON)
set(DASM_ARCH)
set(DASM_AFLAGS)
set(LJ_VM lj_vm.obj)
set(LJVM_MODE elfasm)
set(TARGET_LJARCH)
set(TARGET_COMPILER_GEN_FLAGS)
set(TARGET_COMPILER_TEST_CFLAGS ${CMAKE_C_FLAGS})

if(WIN32)
    set(BUILD_LUA_STATIC OFF)
else()
    set(BUILD_LUA_STATIC ON)
endif()


## host
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
    set(HOST_GENERATOR "Visual Studio 16 2019")
    set(HOST_CMAKE cmake)
    set(HOST_WINDOWS ON)
elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    set(HOST_GENERATOR "Unix Makefiles")
    set(HOST_CMAKE cmake)
    set(HOST_APPLE ON)
    set(LJVM_MODE machasm)
    set(GENERATEOR_ARGS -DCMAKE_SYSTEM_NAME=Darwin)
elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
    set(HOST_GENERATOR "Unix Makefiles")
    set(HOST_CMAKE cmake)
    set(HOST_LINUX ON)
else()
    message(FATAL_ERROR "Unsupport platform \"${CMAKE_HOST_SYSTEM_NAME}\"")
endif()

## target

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    list(APPEND HOST_CFLAGS -DLUAJIT_OS=LUAJIT_OS_OSX)
    set(TARGET_OSX ON)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    list(APPEND HOST_CFLAGS -DLUAJIT_OS=LUAJIT_OS_LINUX)
    set(TARGET_LINUX ON)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    list(APPEND HOST_CFLAGS -DLUAJIT_OS=LUAJIT_OS_WINDOWS -malign-double)
    set(TARGET_WINDOWS ON)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "iOS")
    list(APPEND HOST_CFLAGS -DLUAJIT_OS=LUAJIT_OS_OSX)
    execute_process(COMMAND xcrun --sdk iphoneos --show-sdk-path
        OUTPUT_VARIABLE sdk_path 
    )
    set(IOS_SDK ${sdk_path})
    set(TARGET_IOS ON)
else()
    list(APPEND HOST_CFLAGS -DLUAJIT_OS=LUAJIT_OS_OTHER)
endif()

if(HOST_LINUX AND TARGET_LINUX)
    message(STATUS "LUAJIT_TARGET32: ${LUAJIT_TARGET32}")
endif()


if(MSVC)
    add_definitions(
        /D_CRT_SECURE_NO_DEPRECATE
        /D_CRT_SECURE_NO_WARNINGS
        "/D_CRT_STDIO_INLINE=__declspec(dllexport)__inline"
    )

    string(TOLOWER "${CMAKE_GENERATOR_PLATFORM}" win_platform)
    string(REGEX MATCH "Visual Studio ([0123456789]+) ([0123456789]+) ?(.*)?" vs_version "${CMAKE_GENERATOR}")
    set(VS_VERSION ${CMAKE_MATCH_2})
    set(VS_ARCH ${CMAKE_MATCH_3})
    if("${win_platform}" STREQUAL "win32" OR ( ${VS_VERSION} LESS 2019 AND "${VS_ARCH}" STREQUAL "") )
        set(BUILD_WIN32 ON)
        set(BUILD_WIN64 OFF)
    endif()

    if(BUILD_WIN32)
        list(APPEND TARGET_COMPILER_TEST_CFLAGS  /arch:SSE2)
    else()
        add_definitions(/DLUAJIT_ENABLE_GC64)
    endif()

    message(STATUS "BUILD_WIN64: " ${BUILD_WIN64})
    message(STATUS "BUILD_WIN32: " ${BUILD_WIN32})

    if(BUILD_WIN32)
        set(DASM_AFLAGS -LN -D WIN -D JIT -D FFI)
        set(DASM_ARCH x86)
    elseif(BUILD_WIN64)
        set(DASM_AFLAGS -LN -D WIN -D JIT -D FFI -D P64)
        set(DASM_ARCH x64)
        set(TARGET_64BIT ON)
    endif()
    set(LJVM_MODE peobj)
endif()

if(ANDROID OR HOST_LINUX OR HOST_APPLE)

    if(ANDROID)
        
        if("${ANDROID_ABI}" MATCHES "armeabi.*")
            set(DASM_ARCH arm)
        elseif("${ANDROID_ABI}" STREQUAL "arm64-v8a")
            set(DASM_ARCH arm64)
        elseif("${ANDROID_ABI}" STREQUAL "x86")
            set(DASM_ARCH x86)
            list(APPEND HOST_CFLAGS -march=i686 -msse -msse2 -mfpmath=sse)
        elseif("${ANDROID_ABI}" STREQUAL "x86_64")
            set(DASM_ARCH x64)
        else()
            message(FATAL_ERROR "Unsupport architecture \"${CMAKE_ANDROID_ARCH}\"")
        endif()

    elseif(HOST_LINUX)
        
        if(NOT LUAJIT_TARGET32)
            set(DASM_ARCH x64)
        else()
            set(DASM_ARCH x86)
            list(APPEND TARGET_COMPILER_TEST_CFLAGS "-m32")
        endif()

    elseif(TARGET_OSX)

        if(NOT LUAJIT_TARGET32)
            set(DASM_ARCH x64)
        else()
            set(DASM_ARCH x86)
            list(APPEND TARGET_COMPILER_TEST_CFLAGS "-m32")
        endif()

    elseif(TARGET_IOS)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DLJ_NO_SYSTEM=1")
        if(NOT CMAKE_OSX_ARCHITECTURES)
            ## armv7;armv7s;arm64;i386;x86_64
            message(FATAL_ERROR "CMAKE_OSX_ARCHITECTURES is not set.")
        endif()

        list(LENGTH CMAKE_OSX_ARCHITECTURES ios_architecture_size)
        if(${ios_architecture_size} GREATER 1)
            message(FATAL_ERROR "CMAKE_OSX_ARCHITECTURES only accept one value, but more than 1 are provided.")
        endif()

        message(STATUS "IOS ARCH: ${CMAKE_OSX_ARCHITECTURES}")
        list(GET CMAKE_OSX_ARCHITECTURES 0 LUAJIT_IOS_ARCH)
        if("${LUAJIT_IOS_ARCH}" MATCHES "arm64")
            set(DASM_ARCH "arm64")
        elseif("${LUAJIT_IOS_ARCH}" MATCHES "armv7.*")
            set(DASM_ARCH "arm")
        elseif("${LUAJIT_IOS_ARCH}" MATCHES "i386")
            set(DASM_ARCH "x86")
        elseif("${LUAJIT_IOS_ARCH}" MATCHES "x86_64")
            set(DASM_ARCH "x64")
        else()
            message(FATAL_ERROR "CMAKE_OSX_ARCHITECTURES value incorrect.")
        endif()
    endif()

    message(STATUS "Compiler: ${CMAKE_C_COMPILER}")
    separate_arguments(TARGET_COMPILER_TEST_CFLAGS)
    if(ANDROID)
        execute_process(COMMAND ${CMAKE_C_COMPILER}
            ${TARGET_COMPILER_TEST_CFLAGS}
            --target=${CMAKE_C_COMPILER_TARGET}
            --gcc-toolchain=${ANDROID_TOOLCHAIN_ROOT}
            -D_FILE_OFFSET_BITS=64
            -D_LARGETFILE_SOURCE
            -U_FORTIFY_SOURCE
            -E ${CMAKE_CURRENT_LIST_DIR}/src/lj_arch.h
            -dM
            -mfloat-abi=softfp -Wl,--fix-cortex-a8
            OUTPUT_VARIABLE TARGET_TESTARCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )
    elseif(TARGET_IOS)
        execute_process(COMMAND ${CMAKE_C_COMPILER}
            --sysroot ${IOS_SDK}
            -D_FILE_OFFSET_BITS=64
            -D_LARGETFILE_SOURCE
            -U_FORTIFY_SOURCE
            -arch ${LUAJIT_IOS_ARCH}
            -E ${CMAKE_CURRENT_LIST_DIR}/src/lj_arch.h
            -dM
            -mfloat-abi=softfp -Wl,--fix-cortex-a8
            OUTPUT_VARIABLE TARGET_TESTARCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    elseif(HOST_LINUX OR HOST_APPLE)
        execute_process(COMMAND ${CMAKE_C_COMPILER}
            ${TARGET_COMPILER_TEST_CFLAGS}
           -D_FILE_OFFSET_BITS=64
            -D_LARGETFILE_SOURCE
            -U_FORTIFY_SOURCE
            -E ${CMAKE_CURRENT_LIST_DIR}/src/lj_arch.h
            -dM
            OUTPUT_VARIABLE TARGET_TESTARCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )
    else()
        message(FATAL_ERROR "Dont know which platform")
    endif()

    if("${TARGET_TESTARCH}" STREQUAL "")
        message(FATAL_ERROR "Failed to exec ")
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_TARGET_X64 " fpos)
    if(${fpos} GREATER -1)
        set(TARGET_LJARCH x64)
        set(TARGET_64BIT ON)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_TARGET_X86 " fpos)
    if(${fpos} GREATER -1)
        set(TARGET_LJARCH x86)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_TARGET_ARM " fpos)
    if(${fpos} GREATER -1)
        set(TARGET_LJARCH arm)
        if(TARGET_IOS)
            list(APPEND TARGET_COMPILER_GEN_FLAGS -D IOS)
        endif()
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_TARGET_ARM64 " fpos)
    if(${fpos} GREATER -1)
        set(TARGET_LJARCH arm64)
        string(FIND "${TARGET_TESTARCH}" "__AARCH64EB__" fpos)
        if(${fpos} GREATER -1)
            list(APPEND TARGET_COMPILER_GEN_FLAGS "-D__AARCH64EB__=1")
        endif()
        set(TARGET_64BIT ON)
    endif()

    list(APPEND TARGET_COMPILER_GEN_FLAGS "-DLUAJIT_TARGET=LUAJIT_ARCH_${TARGET_LJARCH}")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDLUAJIT_OS_LINUX")

    string(FIND "${TARGET_TESTARCH}" "LJ_LE 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D ENDIAN_LE)
    else()
        list(APPEND DASM_AFLAGS -D ENDIAN_BE)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_ARCH_BITS 64" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D P64)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_HASJIT 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D JIT)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_HASFFI 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D FFI)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_DUALNUM 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D DUALNUM)
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_ARCH_HASFPU 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D FPU)
        list(APPEND TARGET_COMPILER_GEN_FLAGS "-DLJ_ARCH_HASFPU=1")
    else()
        list(APPEND TARGET_COMPILER_GEN_FLAGS "-DLJ_ARCH_HASFPU=0")
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_ABI_SOFTFP 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND TARGET_COMPILER_GEN_FLAGS "-DLJ_ABI_SOFTFP=1")
    else()
        list(APPEND DASM_AFLAGS -D HFABI)
        list(APPEND TARGET_COMPILER_GEN_FLAGS "-DLJ_ABI_SOFTFP=0")
    endif()

    string(FIND "${TARGET_TESTARCH}" "LJ_NO_UNWIND 1" fpos)
    if(${fpos} GREATER -1)
        list(APPEND DASM_AFLAGS -D LJ_NO_UNWIND)
        list(APPEND TARGET_COMPILER_GEN_FLAGS "-DDLUAJIT_NO_UNWIND")
    endif()

    string(REGEX MATCH "LJ_ARCH_VERSION [0-9]+" version_string "${TARGET_TESTARCH}")
    message(WARNING "LJ_ARCH_VERSION -> ${version_string}")
    if(version_string)
        string(LENGTH "LJ_ARCH_VERSION " start_index)
        string(SUBSTRING "${version_string}" ${start_index} -1 version_number)
        list(APPEND DASM_AFLAGS -D VER=${version_number})
    endif()

    if("${TARGET_LJARCH}" STREQUAL "x64")
        string(FIND "${TARGET_TESTARCH}" "LJ_FR2 1" fpos)
        if(${fpos} GREATER -1)
            set(DASM_ARCH x86)
        endif()
    endif()

    set(LJ_VM lj_vm.S)

    if(NOT TARGET_64BIT)
        list(APPEND TARGET_COMPILER_GEN_FLAGS "-m32")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
    endif()
endif()

# override HOST_GENERATOR
if(HOST_WINDOWS AND NOT TARGET_WINDOWS)
    if(LUAJIT_HOST_GENERATOR)
        set(HOST_GENERATOR "${LUAJIT_HOST_GENERATOR}")
    else()
        set(HOST_GENERATOR "MinGW Makefiles")
    endif()
    if(NOT LUAJIT_MINGW_PATH)
        message(STATUS "Please set LUAJIT_MINGW_PATH to mingw32/bin or mingw64/bin to locate gcc.exe")
    endif()
elseif(HOST_WINDOWS)
    set(HOST_GENERATOR "${CMAKE_GENERATOR}")
    if(NOT "${CMAKE_GENERATOR_PLATFORM}" STREQUAL "")
        set(GENERATEOR_ARGS -A${CMAKE_GENERATOR_PLATFORM} )
    endif()
endif()


set(dynasm_dir ${CMAKE_CURRENT_LIST_DIR}/dynasm)
file(GLOB dasm_lua ${dynasm_dir}/*.lua)


if(HOST_WINDOWS AND NOT "${HOST_GENERATOR}" STREQUAL "MinGW Makefiles")
    set(MINILUA ${CMAKE_BINARY_DIR}/minilua/Debug/minilua.exe)
    set(BUILDVM ${CMAKE_BINARY_DIR}/buildvm/Debug/buildvm.exe)
else()
    set(MINILUA ${CMAKE_BINARY_DIR}/minilua/minilua)
    set(BUILDVM ${CMAKE_BINARY_DIR}/buildvm/buildvm)
endif()


add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/src/host/buildvm_arch.h"
    COMMAND ${MINILUA} ARGS "${dynasm_dir}/dynasm.lua" ${DASM_AFLAGS} -o
        "${CMAKE_CURRENT_LIST_DIR}/src/host/buildvm_arch.h"
        "${CMAKE_CURRENT_LIST_DIR}/src/vm_${DASM_ARCH}.dasc"
    DEPENDS minilua ${dasm_lua} 
)

if(TARGET_64BIT)
    list(APPEND TARGET_COMPILER_GEN_FLAGS -DLUAJIT_ENABLE_GC64)
endif()

list(REMOVE_DUPLICATES TARGET_COMPILER_GEN_FLAGS)

list(APPEND HOST_CFLAGS ${TARGET_COMPILER_GEN_FLAGS})

message(STATUS "DASM_AFLAGS: ${DASM_AFLAGS}")
message(STATUS "DASM_ARCH: ${DASM_ARCH}")
message(STATUS "TARGET_COMPILER_GEN_FLAGS: ${TARGET_COMPILER_GEN_FLAGS}")
message(STATUS "GENERATEOR_ARGS: ${GENERATEOR_ARGS}")
message(STATUS "HOST_CFLAGS: ${HOST_CFLAGS}")
message(STATUS "CMAKE_GENERATOR_INSTANCE: ${CMAKE_GENERATOR_INSTANCE}")
message(STATUS "CMAKE_GENERATOR_TOOLSET: ${CMAKE_GENERATOR_TOOLSET}")
message(STATUS "CMAKE_GENERATOR: ${CMAKE_GENERATOR}")


file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/minilua)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/buildvm)

function(build_host_target)
        
    set(oneValueArgs TARGET TARGET_DIR COMMENT NEW_PATH)
    set(multiValueArgs COMMANDS DEPENDS)
    cmake_parse_arguments(opt "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    set(COMMAND_STR)
    foreach(i ${opt_COMMANDS})
        set(COMMAND_STR "${COMMAND_STR} ${i}")
    endforeach()

    if(HOST_APPLE)
        add_custom_target(${opt_TARGET} 
            #COMMAND ${CMAKE_COMMAND} -E remove_directory ${opt_TARGET_DIR}
            COMMAND env -i bash --login -c "${COMMAND_STR}"
            COMMAND env -i bash --login -c "make -C ${opt_TARGET_DIR}"
            DEPENDS ${opt_DEPENDS}
            WORKING_DIRECTORY ${opt_TARGET_DIR}
            COMMENT ${opt_COMMENT}
        )
    else()
        set(SETUP_ENV)
        if(opt_NEW_PATH AND NOT "${opt_NEW_PATH}" STREQUAL "")
            set(SETUP_ENV ${CMAKE_COMMAND} -E env PATH="${opt_NEW_PATH}")
        endif()

        add_custom_target(${opt_TARGET}  
            #COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/buildvm
            COMMAND ${SETUP_ENV}
                    ${opt_COMMANDS}
            COMMAND ${SETUP_ENV}
                ${HOST_CMAKE} --build "${opt_TARGET_DIR}"
            DEPENDS ${opt_DEPENDS}
            WORKING_DIRECTORY ${opt_TARGET_DIR}
            COMMENT ${opt_COMMENT}
        )
    endif()
endfunction()

if(HOST_WINDOWS AND NOT TARGET_WINDOWS)
    set(OVERRIDE_PATH ${LUAJIT_MINGW_PATH})
endif()

build_host_target(TARGET buildvm 
    TARGET_DIR  ${CMAKE_BINARY_DIR}/buildvm 
    NEW_PATH    ${OVERRIDE_PATH}
    COMMENT     "Compiling buildvm..."
    COMMANDS    ${HOST_CMAKE}
                -S "${CMAKE_CURRENT_LIST_DIR}/src/buildvm"
                -G"${HOST_GENERATOR}"
                -B"${CMAKE_BINARY_DIR}/buildvm" 
                -DCMAKE_C_FLAGS="${HOST_CFLAGS}"
                ${GENERATEOR_ARGS}
    DEPENDS     "${CMAKE_CURRENT_LIST_DIR}/src/host/buildvm_arch.h"
)

build_host_target(TARGET minilua 
    TARGET_DIR  ${CMAKE_BINARY_DIR}/minilua 
    NEW_PATH    ${OVERRIDE_PATH}
    COMMENT     "Compiling minilua..."
    COMMANDS    ${HOST_CMAKE}
                -S "${CMAKE_CURRENT_LIST_DIR}/src/minilua"
                -G"${HOST_GENERATOR}"
                -B"${CMAKE_BINARY_DIR}/minilua" 
                -DCMAKE_C_FLAGS="${HOST_CFLAGS}"
                ${GENERATEOR_ARGS}
)
    


set(GENERATE_DIR ${CMAKE_BINARY_DIR}/include)
if(NOT EXISTS ${CMAKE_BINARY_DIR}/include)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/include)
endif()
if(NOT EXISTS ${CMAKE_BINARY_DIR}/include/objs)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/include/objs)
endif()

set(EXPORT_HEADERS 
    ${CMAKE_CURRENT_LIST_DIR}/src/lua.h
    ${CMAKE_CURRENT_LIST_DIR}/src/lualib.h
    ${CMAKE_CURRENT_LIST_DIR}/src/lauxlib.h
    ${CMAKE_CURRENT_LIST_DIR}/src/luaconf.h
    ${CMAKE_CURRENT_LIST_DIR}/src/lua.hpp
    ${CMAKE_CURRENT_LIST_DIR}/src/luajit.h
)

set(LBLIB_SC
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_base.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_math.c
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_bit.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_string.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_table.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_io.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_os.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_package.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_debug.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_jit.c 
    ${CMAKE_CURRENT_LIST_DIR}/src/lib_ffi.c
)

### lua
file(GLOB lua_src src/lj_*.c src/lib_*.c)
set(LUA luajit)
if(BUILD_LUA_STATIC)
    add_library(${LUA}
        ${lua_src}
    )
else()
    add_library(${LUA} SHARED
        ${lua_src}
    )
    target_compile_definitions(${LUA} PUBLIC
        LUA_BUILD_AS_DLL
    )
endif()

target_include_directories(${LUA} PRIVATE
    ${GENERATE_DIR}
)
set_target_properties(${LUA} PROPERTIES  
    PUBLIC_HEADER "${EXPORT_HEADERS}"
)

if(TARGET_64BIT)
    target_compile_definitions(${LUA} PRIVATE LUAJIT_ENABLE_GC64)
endif()

add_dependencies(${LUA} minilua buildvm)

if(OPT_CLEAN_GENEARTED_FILES)
    add_custom_command(TARGET ${LUA} POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E echo "POST_BUILD: remove generated file ${CMAKE_CURRENT_LIST_DIR}/src/host/buildvm_arch.h"
        COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_CURRENT_LIST_DIR}/src/host/buildvm_arch.h
    )
endif()
### generate headers 
function(buildvm_generate)
    set(oneValueArgs DEF OUTPUT)
    set(multiValueArgs DEPENDS)
    cmake_parse_arguments(opt "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    add_custom_command(OUTPUT ${opt_OUTPUT}
        COMMAND ${BUILDVM} ARGS -m ${opt_DEF} -o ${opt_OUTPUT} ${opt_DEPENDS}
        DEPENDS ${opt_DEPENDS}
    )
    target_sources(${LUA} PRIVATE ${opt_OUTPUT})
    if(OPT_CLEAN_GENEARTED_FILES)
        add_custom_command(TARGET ${LUA} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E echo "POST_BUILD: remove generated file ${opt_OUTPUT}"
            COMMAND ${CMAKE_COMMAND} -E remove -f ${opt_OUTPUT}
        )
    endif()
endfunction()


buildvm_generate(OUTPUT ${GENERATE_DIR}/objs/${LJ_VM} DEF ${LJVM_MODE})
buildvm_generate(OUTPUT ${GENERATE_DIR}/lj_bcdef.h DEF bcdef DEPENDS ${LBLIB_SC})
buildvm_generate(OUTPUT ${GENERATE_DIR}/lj_ffdef.h DEF ffdef DEPENDS ${LBLIB_SC})
buildvm_generate(OUTPUT ${GENERATE_DIR}/lj_libdef.h DEF libdef DEPENDS ${LBLIB_SC})
buildvm_generate(OUTPUT ${GENERATE_DIR}/lj_recdef.h DEF recdef DEPENDS ${LBLIB_SC})
buildvm_generate(OUTPUT ${CMAKE_CURRENT_LIST_DIR}/src/jit/vmdef.lua DEF vmdef DEPENDS ${LBLIB_SC})
buildvm_generate(OUTPUT ${GENERATE_DIR}/lj_folddef.h DEF folddef DEPENDS ${CMAKE_CURRENT_LIST_DIR}/src/lj_opt_fold.c)

install(TARGETS ${LUA}
    ARCHIVE DESTINATION lib/
    PUBLIC_HEADER DESTINATION include
)