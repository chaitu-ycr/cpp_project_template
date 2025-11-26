# C++ Project Template

This is a template for C++ projects with CMake, Google Test, and Doxygen support.

## Prerequisites

- CMake (3.10 or higher)
- C++ Compiler (GCC, Clang, or MSVC) supporting C++17
- Doxygen (optional, for documentation)

## Building

### Prerequisites Installation (Linux/macOS)
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y build-essential cmake

# macOS (with Homebrew)
brew install cmake
```

### Configure and Build

1. Configure the project:
   ```bash
   # Windows: Run from "Developer Command Prompt for VS 2022"
   cmake -S . -B build -G "NMake Makefiles"
   
   # Linux/macOS
   cmake -S . -B build
   ```

2. Build the project:
   ```bash
   cmake --build build -- -j
   ```

### CMake build options

This repository supports a few CMake options to control what gets built. Pass them at configure time with `-D<option>=ON|OFF`.

- `BUILD_ALL` : Enable all build components (equivalent to turning on calculator, hello, tests and docs).
- `BUILD_CALCULATOR_EXECUTABLE` : Build the `calculator_app` executable (default: ON).
- `BUILD_HELLO_EXECUTABLE` : Build the `hello_app` executable (default: ON).
- `BUILD_TESTS` : Build the unit tests (default: ON).
- `BUILD_DOCS` : Enable Doxygen docs target (default: OFF). The `doc` target always exists but will print a helpful message if Doxygen is missing or docs are disabled.

Examples:

Build everything (recommended):
```bash
cmake -S . -B build -DBUILD_ALL=ON
cmake --build build -- -j
```

Build only the calculator executable:
```bash
cmake -S . -B build -DBUILD_CALCULATOR_EXECUTABLE=ON -DBUILD_HELLO_EXECUTABLE=OFF -DBUILD_TESTS=OFF -DBUILD_DOCS=OFF
cmake --build build --target calculator_app -- -j
```

Enable documentation generation (requires Doxygen installed):
```bash
cmake -S . -B build -DBUILD_DOCS=ON
cmake --build build --target doc
# docs/html/ will contain the generated docs when Doxygen is available
```


## Running

Run the executables produced by this template (one or both may be present depending on CMake options):

```bash
# Calculator application
./build/src/calculator_app

# Hello-world application
./build/src/hello_world_app
```

## Testing

Run the unit tests with verbose output:
```bash
cd build
ctest --output-on-failure
```

Or run the test executable directly:
```bash
./build/tests/unit_tests # Linux/macOS
.\build\tests\Debug\unit_tests.exe # Windows (Debug)
```

**Note:** The test suite includes calculator unit tests (Add and Subtract operations). All tests are expected to pass with a 100% success rate.

## Documentation
The repository provides a `doc` CMake target. Use the `BUILD_DOCS` option to enable generation during configuration. The `doc` target always exists and will either run Doxygen (if found and `BUILD_DOCS=ON`) or print a helpful message explaining how to enable docs.

When Doxygen is available and you enable docs, run:

```bash
cmake -S . -B build -DBUILD_DOCS=ON
cmake --build build --target doc
```

Generated HTML will be placed in `docs/html/`.
