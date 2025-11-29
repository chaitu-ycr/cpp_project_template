#include <gtest/gtest.h>
#include "calculator/calculator.h"
#include <limits>

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

TEST(CalculatorTest, Multiply) {
    Calculator calc;
    EXPECT_EQ(calc.multiply(2, 3), 6);
    EXPECT_EQ(calc.multiply(-2, 3), -6);
    EXPECT_EQ(calc.multiply(-2, -3), 6);
    EXPECT_EQ(calc.multiply(0, 5), 0);
}

TEST(CalculatorTest, Divide) {
    Calculator calc;
    EXPECT_EQ(calc.divide(6, 2), 3);
    EXPECT_EQ(calc.divide(7, 2), 3);
    EXPECT_EQ(calc.divide(-6, 2), -3);
    EXPECT_EQ(calc.divide(10, -2), -5);
}

TEST(CalculatorTest, DivideByZero) {
    Calculator calc;
    EXPECT_THROW(calc.divide(5, 0), std::invalid_argument);
}

TEST(CalculatorTest, Modulo) {
    Calculator calc;
    EXPECT_EQ(calc.modulo(7, 3), 1);
    EXPECT_EQ(calc.modulo(10, 2), 0);
    EXPECT_EQ(calc.modulo(-7, 3), -1);
    EXPECT_EQ(calc.modulo(7, -3), 1);
}

TEST(CalculatorTest, ModuloByZero) {
    Calculator calc;
    EXPECT_THROW(calc.modulo(5, 0), std::invalid_argument);
}

TEST(CalculatorTest, EdgeCasesLargeIntegers) {
    Calculator calc;
    const int imax = std::numeric_limits<int>::max();
    const int imin = std::numeric_limits<int>::min();

    // operations that do not overflow
    EXPECT_EQ(calc.add(imax, 0), imax);
    EXPECT_EQ(calc.add(0, imax), imax);
    EXPECT_EQ(calc.add(imin, 0), imin);

    EXPECT_EQ(calc.subtract(imax, 0), imax);
    EXPECT_EQ(calc.subtract(imin, 0), imin);

    EXPECT_EQ(calc.multiply(imax, 1), imax);
    EXPECT_EQ(calc.multiply(imin, 1), imin);
    EXPECT_EQ(calc.multiply(0, imax), 0);

    EXPECT_EQ(calc.divide(imax, 1), imax);
    EXPECT_EQ(calc.divide(imin, 1), imin);

    EXPECT_EQ(calc.modulo(imax, 1), 0);
    EXPECT_EQ(calc.modulo(imin, 1), 0);

    // Rounding toward zero for negative division
    EXPECT_EQ(calc.divide(-7, 2), -3);
}
