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

Windows (PowerShell - clean configure & build)

From a Visual Studio Developer PowerShell (or "Developer PowerShell for VS 20XX") you can run a clean configure+build using the included helper script which removes the `build_win` directory before configuring.

PowerShell (run from project root):
```powershell
# Use default generator (NMake Makefiles) or pass a generator name
.\scripts\windows_build.ps1                # uses default generator and Release build
.\scripts\windows_build.ps1 -Generator "Visual Studio 17 2022" -BuildType Debug
.\scripts\windows_build.ps1 -Generator "Ninja" -RunTests
```

If you prefer manual commands (PowerShell):
```powershell
Remove-Item -Recurse -Force .\build_win  # delete existing build directory (clean)
cmake -S . -B build_win -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
cmake --build build_win --config Release --parallel
# Run tests (from repo root)
cd build_win; ctest -C Release --output-on-failure; cd -
```

Linux/Ubuntu (bash - clean configure & build)

Use the included helper script for a clean configure+build workflow on Linux/Ubuntu:

```bash
# Run from project root
./scripts/linux_build.sh                    # uses default generator (Unix Makefiles) and Release build
./scripts/linux_build.sh --generator Ninja --build-type Debug
./scripts/linux_build.sh --run-tests
```

If you prefer manual commands (bash):
```bash
rm -rf build_linux  # delete existing build directory (clean)
cmake -S . -B build_linux -DCMAKE_BUILD_TYPE=Release
cmake --build build_linux --parallel
# Run tests (from repo root)
cd build_linux && ctest --output-on-failure && cd -
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

Run built binaries (Windows & Unix)

This repository includes helper scripts to find and run the built executables from the `build` directory.

Windows (PowerShell):
```powershell
# From a Developer PowerShell in the repository root
.\scripts\windows_run.ps1 -All            # find and run known executables (calculator_app, hello_world_app, unit_tests)
.\scripts\windows_run.ps1 -Name calculator_app -Config Release

# List discovered targets without running
.\scripts\windows_run.ps1 -List

# Print resolved executable paths without running them
.\scripts\windows_run.ps1 -DryRun

# Run a specific binary with runtime arguments
.\scripts\windows_run.ps1 -Name calculator_app -Config Release -Args 'input.txt','--flag'
```

Linux/Ubuntu (bash - using `linux_run.sh`):
```bash
# From the project root
./scripts/linux_run.sh --all
./scripts/linux_run.sh --name calculator_app

# List discovered targets without running
./scripts/linux_run.sh --list

# Print resolved executable paths without running them
./scripts/linux_run.sh --dry-run

# Run a specific binary with runtime arguments (everything after --args is forwarded)
./scripts/linux_run.sh --name calculator_app --args input.txt --flag
```

macOS (bash - using generic `run_unix.sh`):
```bash
# From the project root
./scripts/run_unix.sh --all
./scripts/run_unix.sh --name calculator_app

# List discovered targets without running
./scripts/run_unix.sh --list

# Print resolved executable paths without running them
./scripts/run_unix.sh --dry-run

# Run a specific binary with runtime arguments (everything after --args is forwarded)
./scripts/run_unix.sh --name calculator_app --args input.txt --flag
```

The run scripts auto-discover target names from `CMakeLists.txt` and provide options to list targets (`--list`), preview paths (`--dry-run`), and forward runtime arguments (`--args`).

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
