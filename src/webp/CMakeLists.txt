set(WEBP_LIBRARY webp)
project(webp)

file(GLOB lib_srcs src/dec/*.c src/demux/*.c src/dsp/*.c src/enc/*.c src/mux/*.c src/utils/*.c src/webp/*.c)
file(GLOB lib_hdrs src/dec/*.h src/demux/*.h src/dsp/*.h src/enc/*.h src/mux/*.h src/utils/*.h src/webp/*.h)
add_library(webp STATIC ${lib_srcs} ${lib_hdrs})

target_compile_definitions(webp PRIVATE -DWEBP_USE_THREAD)
target_include_directories(webp PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
