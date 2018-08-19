#include "engine.h"
#include "Box2D/Box2D.h"
#include "recast/Detour/DetourNode.h"
#include "zlib.h"

#include <iostream>
#include <sstream>

namespace engine {
std::string getInfo()
{
    std::ostringstream o;
    o << "External libs info\n";
    o << "Box2D version: " << b2_version.major << "." << b2_version.minor
      << "." << b2_version.revision << "\n";

    dtNodeQueue q(10);
    o << "Recast dtNodeQueue: " << q.empty() << "\n";
    o << "zlib version: " << zlibVersion() << "\n";
    return o.str();
}

std::string getInfoExpected()
{
    return R"(External libs info
Box2D version: 2.3.2
Recast dtNodeQueue: 1
zlib version: 1.2.8
)";
}
} // namespace engine