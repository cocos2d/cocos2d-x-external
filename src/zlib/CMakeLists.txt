cmake_minimum_required(VERSION 3.6)
project(zlib)

set(SRC
    adler32.c
    compress.c
    crc32.c
    deflate.c
    gzclose.c
    gzlib.c
    gzread.c
    gzwrite.c
    inflate.c
    infback.c
    inftrees.c
    inffast.c
    trees.c
    uncompr.c
    zutil.c

    crc32.h
    deflate.h
    gzguts.h
    inffast.h
    inffixed.h
    inflate.h
    inftrees.h
    trees.h
    zutil.h

    zlib.h
)

add_library(zlib STATIC
    ${SRC}
)

target_include_directories(zlib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
