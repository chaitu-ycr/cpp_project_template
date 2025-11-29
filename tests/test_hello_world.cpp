#include <gtest/gtest.h>
#include "hello_world/hello_world.h"

TEST(HelloWorldTest, DefaultGreeting) {
    HelloWorld hw;
    EXPECT_EQ(hw.getDefaultGreeting(), "Hello, World!");
}

TEST(HelloWorldTest, Greet) {
    HelloWorld hw;
    EXPECT_EQ(hw.greet("Alice"), "Hello, Alice!");
    EXPECT_EQ(hw.greet("") , "Hello, !");
    std::string longName(1000, 'x');
    EXPECT_EQ(hw.greet(longName), std::string("Hello, ") + longName + "!");
}
