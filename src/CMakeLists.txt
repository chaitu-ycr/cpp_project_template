add_subdirectory(calculator)
add_subdirectory(hello_world)

# Optionally build separate executables. These options are defined in the root CMakeLists.
if(BUILD_CALCULATOR_EXECUTABLE)
	add_executable(calculator_app calculator_app.cpp)
	target_link_libraries(calculator_app PRIVATE calculator)
endif()

if(BUILD_HELLO_EXECUTABLE)
	add_executable(hello_world_app hello_world_app.cpp)
	target_link_libraries(hello_world_app PRIVATE hello_world)
endif()
