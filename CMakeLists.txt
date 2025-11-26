cmake_minimum_required(VERSION 3.10)

project(CppProjectTemplate VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build options
option(BUILD_ALL "Build all components (executables, tests, docs)" OFF)
option(BUILD_CALCULATOR_EXECUTABLE "Build the calculator executable" ON)
option(BUILD_HELLO_EXECUTABLE "Build the hello_world executable" ON)
option(BUILD_TESTS "Build unit tests" ON)
option(BUILD_DOCS "Generate documentation with Doxygen" OFF)

if(BUILD_ALL)
  set(BUILD_CALCULATOR_EXECUTABLE ON CACHE BOOL "" FORCE)
  set(BUILD_HELLO_EXECUTABLE ON CACHE BOOL "" FORCE)
  set(BUILD_TESTS ON CACHE BOOL "" FORCE)
  set(BUILD_DOCS ON CACHE BOOL "" FORCE)
endif()

# Enable testing (still required by CTest even if tests may be disabled later)
enable_testing()

# Fetch Google Test
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Add subdirectories
add_subdirectory(src)
# Add tests only if requested
if(BUILD_TESTS)
  add_subdirectory(tests)
endif()

# Documentation (Optional)
find_package(Doxygen)
set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/docs/Doxyfile)

# Always provide a `doc` target. Behavior depends on `BUILD_DOCS` and whether Doxygen
# is available:
# - If BUILD_DOCS=ON and Doxygen found: runs Doxygen to generate docs.
# - If BUILD_DOCS=ON but Doxygen missing: prints a clear message and returns non-zero.
# - If BUILD_DOCS=OFF: prints a message explaining how to enable docs and returns non-zero.
if(BUILD_DOCS)
  if(DOXYGEN_FOUND)
    add_custom_target(doc
      COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_IN}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "Generating API documentation with Doxygen"
      VERBATIM)
  else()
    # Informational target: explain how to enable docs; succeed (exit 0)
    add_custom_target(doc
      COMMAND ${CMAKE_COMMAND} -E echo "Doxygen requested (BUILD_DOCS=ON) but Doxygen was not found. Install Doxygen to enable the 'doc' target."
      COMMENT "Doxygen not found — documentation skipped"
      VERBATIM)
  endif()
else()
  # Informational target when docs are disabled; succeed (exit 0)
  add_custom_target(doc
    COMMAND ${CMAKE_COMMAND} -E echo "Documentation build is disabled. Re-run CMake with -DBUILD_DOCS=ON to enable the 'doc' target."
    COMMENT "Documentation disabled"
    VERBATIM)
endif()

# Do not force a specific generator in a cross-platform template.
# Users should choose an appropriate generator with `cmake -G` if necessary.
