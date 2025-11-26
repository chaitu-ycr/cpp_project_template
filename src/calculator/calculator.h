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
};

#endif // CALCULATOR_H
