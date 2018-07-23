#include "engine.h"
#include "Box2D/Box2D.h"
#include "recast/Detour/DetourNode.h"
#include <iostream>
#include <sstream>

namespace engine {
std::string getInfo()
{
    std::ostringstream o;
    o << "engine info\n";
    o << "Box2D version: " << b2_version.major << "." << b2_version.minor
      << "." << b2_version.revision << "\n";

    dtNodeQueue q(10);
    o << "Recast dtNodeQueue: " << q.empty() << "\n";
    return o.str();
}
} // namespace engine