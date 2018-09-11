#include <iostream>
#include "engine/engine.h"

int main()
{
    std::cout << "--- game1 test ---" << std::endl;
    if (engine::getInfoExpected() != engine::getInfoActual())
    {
        std::cout << "WARNING: expected versions not match" << std::endl << std::endl;
        std::cout << engine::getInfoExpected() << "!=" << std::endl << engine::getInfoActual();
        return 1;
    }
    std::cout << engine::getInfoActual();
    return 0;
}