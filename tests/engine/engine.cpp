#include "engine.h"
#include "Box2D/Box2D.h"
#include "chipmunk/chipmunk.h"
#include "recast/Detour/DetourNode.h"
#include "zlib.h"

#include "ft2build.h"
#include FT_FREETYPE_H

#include <iostream>
#include <sstream>

namespace engine {
std::string getInfo()
{
    std::ostringstream o;
    o << "External libs info:\n";
    o << "Box2D version: " << b2_version.major << "." << b2_version.minor
      << "." << b2_version.revision << "\n";
    o << "chipmunk: " << cpVersionString << "\n";
    dtNodeQueue q(10);
    o << "Recast dtNodeQueue: " << q.empty() << "\n";
    o << "zlib version: " << zlibVersion() << "\n";
    o << "freetype version: " << getFreeTypeVersion() << "\n";
    return o.str();
}

std::string getInfoExpected()
{
    return R"(External libs info:
Box2D version: 2.3.2
chipmunk: 7.0.1
Recast dtNodeQueue: 1
zlib version: 1.2.8
freetype version: 2.5.5
)";
}

std::string getFreeTypeVersion()
{
    FT_Int major, minor, patch;
    FT_Library _FTLibrary;
    assert(FT_Init_FreeType(&_FTLibrary) == 0);
    FT_Library_Version(_FTLibrary, &major, &minor, &patch);
    assert(FT_Done_FreeType(_FTLibrary) == 0);

    std::ostringstream o;
    o << major << "." << minor << "." << patch;
    return o.str();
}
} // namespace engine