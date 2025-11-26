/**
 * @file hello_world_app.cpp
 * @brief Hello World application (renamed)
 */

#include <iostream>
#include "hello_world/hello_world.h"

int main(void)
{
  HelloWorld hw;
  std::cout << "=== Hello World Application ===" << std::endl;
  std::cout << hw.getDefaultGreeting() << std::endl;
  std::cout << hw.greet("Alice") << std::endl;
  std::cout << hw.greet("Bob") << std::endl;
  std::cout << hw.greet("C++ Developer") << std::endl;
  return 0;
}
