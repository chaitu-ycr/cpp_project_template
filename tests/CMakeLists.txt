include(GoogleTest)

add_executable(unit_tests test_calculator.cpp)

target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(unit_tests PRIVATE calculator gtest_main)

gtest_discover_tests(unit_tests)
