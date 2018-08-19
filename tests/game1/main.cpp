#include <iostream>
#include "engine/engine.h"

int main()
{
    std::cout << "game1\n";
    std::cout << engine::getInfo();
    if (engine::getInfoExpected() != engine::getInfo())
    {
        std::cout << engine::getInfoExpected() << "!=" << engine::getInfo();
        return 1;
    }
    return 0;
}