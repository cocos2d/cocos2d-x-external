cmake_minimum_required(VERSION 3.6)
project(recast)

set(RECAST_SRC
    DebugUtils/DebugDraw.cpp
    DebugUtils/DetourDebugDraw.cpp
    Detour/DetourAlloc.cpp
    Detour/DetourCommon.cpp
    Detour/DetourNavMesh.cpp
    Detour/DetourNavMeshBuilder.cpp
    Detour/DetourNavMeshQuery.cpp
    Detour/DetourNode.cpp
    DetourCrowd/DetourCrowd.cpp
    DetourCrowd/DetourLocalBoundary.cpp
    DetourCrowd/DetourObstacleAvoidance.cpp
    DetourCrowd/DetourPathCorridor.cpp
    DetourCrowd/DetourPathQueue.cpp
    DetourCrowd/DetourProximityGrid.cpp
    DetourTileCache/DetourTileCache.cpp
    DetourTileCache/DetourTileCacheBuilder.cpp
    fastlz/fastlz.c
)

add_library(recast STATIC
    ${RECAST_SRC}
)

target_include_directories(recast PUBLIC ..)

set_target_properties(recast
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    FOLDER "External"
)