cmake_minimum_required(VERSION 3.6)
project(tremolo)

set(TREMOLO_SRC
    ./Tremolo/bitwise.c
    ./Tremolo/codebook.c
    ./Tremolo/dsp.c
    ./Tremolo/floor0.c
    ./Tremolo/floor1.c
    ./Tremolo/floor_lookup.c
    ./Tremolo/framing.c
    ./Tremolo/mapping0.c
    ./Tremolo/mdct.c
    ./Tremolo/misc.c
    ./Tremolo/res012.c
    ./Tremolo/treminfo.c
    ./Tremolo/vorbisfile.c
)

add_library(tremolo STATIC
    ${TREMOLO_SRC}
)

target_include_directories(tremolo PUBLIC ..)
