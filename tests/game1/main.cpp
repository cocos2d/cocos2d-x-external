#include <iostream>
#include "engine/engine.h"

int main()
{
    std::cout << "--- game1 test ---" << std::endl;
    if (engine::getInfoExpected() != engine::getInfo())
    {
        std::cout << "WARNING: versions not match" << std::endl << std::endl;
        std::cout << engine::getInfoExpected() << "!=" << std::endl << engine::getInfo();
        return 1;
    }
    std::cout << engine::getInfo();
    return 0;
}