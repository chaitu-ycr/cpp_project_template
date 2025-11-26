#include <gtest/gtest.h>
#include "calculator/calculator.h"

TEST(CalculatorTest, Add) {
    Calculator calc;
    EXPECT_EQ(calc.add(2, 3), 5);
    EXPECT_EQ(calc.add(-1, 1), 0);
    EXPECT_EQ(calc.add(-2, -3), -5);
}

TEST(CalculatorTest, Subtract) {
    Calculator calc;
    EXPECT_EQ(calc.subtract(5, 3), 2);
    EXPECT_EQ(calc.subtract(1, 1), 0);
    EXPECT_EQ(calc.subtract(3, 5), -2);
}
