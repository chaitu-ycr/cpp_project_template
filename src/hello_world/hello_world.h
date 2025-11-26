/**
 * @file hello_world.h
 * @brief HelloWorld module header
 * @author Your Name
 * @date 2025
 */

#ifndef HELLO_WORLD_H
#define HELLO_WORLD_H

#include <string>

/**
 * @class HelloWorld
 * @brief A simple HelloWorld utility class
 */
class HelloWorld {
public:
    /**
     * @brief Get a greeting message
     * @param name The name to greet
     * @return A formatted greeting string
     */
    std::string greet(const std::string& name) const;

    /**
     * @brief Get the default greeting message
     * @return A default greeting string
     */
    std::string getDefaultGreeting() const;
};

#endif // HELLO_WORLD_H
