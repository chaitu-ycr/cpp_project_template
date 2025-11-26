/**
 * @file calculator_app.cpp
 * @brief Calculator application
 */

#include <iostream>
#include "calculator/calculator.h"

int main(void)
{
  Calculator calc;
  std::cout << "=== Calculator Application ===" << std::endl;
  std::cout << "5 + 3 = " << calc.add(5, 3) << std::endl;
  std::cout << "10 - 4 = " << calc.subtract(10, 4) << std::endl;
  std::cout << "8 + (-2) = " << calc.add(8, -2) << std::endl;
  std::cout << "15 - 7 = " << calc.subtract(15, 7) << std::endl;
  return 0;
}
