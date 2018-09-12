#include <iostream>
#include "engine/engine.h"

int main()
{
    std::cout << "game1\n";
    std::cout << engine::getInfoActual();

    if (engine::getInfoExpected().compare(engine::getInfoActual()) != 0)
    {
        std::cout << engine::getInfoExpected() << "!=\n" << engine::getInfoActual();
        return 1;
    }
    return 0;
}