#ifndef CALCULATOR_H
#define CALCULATOR_H

/**
 * @brief A simple calculator class.
 */
class Calculator {
public:
    /**
     * @brief Adds two integers.
     * @param a First integer.
     * @param b Second integer.
     * @return The sum of a and b.
     */
    int add(int a, int b);

    /**
     * @brief Subtracts two integers.
     * @param a First integer.
     * @param b Second integer.
     * @return The result of a - b.
     */
    int subtract(int a, int b);

    /**
     * @brief Multiplies two integers.
     * @param a First integer.
     * @param b Second integer.
     * @return The product of a and b.
     */
    int multiply(int a, int b);

    /**
     * @brief Divides two integers.
     * @param a Dividend.
     * @param b Divisor.
     * @return The result of a / b.
     * @throws std::invalid_argument if b is zero.
     */
    int divide(int a, int b);

    /**
     * @brief Returns the modulo of two integers.
     * @param a Dividend.
     * @param b Divisor.
     * @return The remainder of a % b.
     * @throws std::invalid_argument if b is zero.
     */
    int modulo(int a, int b);
};

#endif // CALCULATOR_H
