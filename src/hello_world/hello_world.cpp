/**
 * @file hello_world.cpp
 * @brief HelloWorld module implementation
 */

#include "hello_world.h"

std::string HelloWorld::greet(const std::string& name) const {
    return "Hello, " + name + "!";
}

std::string HelloWorld::getDefaultGreeting() const {
    return "Hello, World!";
}
