cmake_minimum_required(VERSION 3.6)
project(chipmunk LANGUAGES CXX)

file(GLOB chipmunk_public_header "include/chipmunk/*.h")

add_library(chipmunk STATIC
    src/chipmunk.c
    src/CMakeLists.txt
    src/cpArbiter.c
    src/cpArray.c
    src/cpBBTree.c
    src/cpBody.c
    src/cpCollision.c
    src/cpConstraint.c
    src/cpDampedRotarySpring.c
    src/cpDampedSpring.c
    src/cpGearJoint.c
    src/cpGrooveJoint.c
    src/cpHashSet.c
    # src/cpHastySpace.c
    src/cpMarch.c
    src/cpPinJoint.c
    src/cpPivotJoint.c
    src/cpPolyline.c
    src/cpPolyShape.c
    src/cpRatchetJoint.c
    src/cpRobust.c
    src/cpRotaryLimitJoint.c
    src/cpShape.c
    src/cpSimpleMotor.c
    src/cpSlideJoint.c
    src/cpSpace.c
    src/cpSpaceComponent.c
    src/cpSpaceDebug.c
    src/cpSpaceHash.c
    src/cpSpaceQuery.c
    src/cpSpaceStep.c
    src/cpSpatialIndex.c
    src/cpSweep1D.c
    src/prime.h

    ${chipmunk_public_header}
)

target_include_directories(chipmunk PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
