# cocos2d-x-external

Travis

![Build status](https://travis-ci.org/cocos2d/cocos2d-x-external.svg?branch=master)

Appveyor

![Build status](https://ci.appveyor.com/api/projects/status/?svg=true)

## Plan

use CMake to build external 3rd party modules

setup CI for all platforms to ensure 3rd party works

## Advice

use modern cmake (target_*), for example:
```
# create library
add_library(Box2D file.cpp)
target_compile_features(Box2D PUBLIC cxx_std_11)
target_include_directories(Box2D PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# use library
target_link_libraries(game2 Box2D)
```

## Links

- [cocos2d-x](https://github.com/cocos2d/cocos2d-x)
- [3rd-party-libs-src](https://github.com/cocos2d/cocos2d-x-3rd-party-libs-src)
- [3rd-party-libs-bin](https://github.com/cocos2d/cocos2d-x-3rd-party-libs-bin)
- [modern_cmake example](https://github.com/crazyhappygame/modern_cmake)
