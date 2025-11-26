add_library(hello_world hello_world.cpp hello_world.h)

target_include_directories(hello_world PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
