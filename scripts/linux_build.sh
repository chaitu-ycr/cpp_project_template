#!/usr/bin/env bash
# linux_build.sh
# Clean configure, build, and test on Linux/Ubuntu using CMake.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

GENERATOR="Unix Makefiles"
BUILD_TYPE="Release"
RUN_TESTS=false

usage() {
  echo "Usage: $0 [--generator <cmake-generator>] [--build-type <Debug|Release>] [--run-tests]"
  echo ""
  echo "Options:"
  echo "  --generator <name>   CMake generator (default: Unix Makefiles)"
  echo "  --build-type <type>  Build type: Debug or Release (default: Release)"
  echo "  --run-tests          Run ctest after successful build"
  echo ""
  echo "Examples:"
  echo "  $0"
  echo "  $0 --generator Ninja --build-type Debug"
  echo "  $0 --generator 'Unix Makefiles' --run-tests"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --generator)
      GENERATOR="$2"
      shift 2
      ;;
    --build-type)
      BUILD_TYPE="$2"
      shift 2
      ;;
    --run-tests)
      RUN_TESTS=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

echo -e "\033[36mGenerator: $GENERATOR\033[0m"
echo -e "\033[36mBuild Type: $BUILD_TYPE\033[0m"

# Remove existing build directory
if [[ -d build_linux ]]; then
  echo -e "\033[33mRemoving existing build directory\033[0m"
  rm -rf build_linux
fi

# Configure
echo -e "\033[32mConfiguring (cmake)...\033[0m"
cmake -S . -B build_linux -G "$GENERATOR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
if [[ $? -ne 0 ]]; then
  echo -e "\033[31mERROR: cmake configure failed\033[0m"
  exit 1
fi

# Build
echo -e "\033[32mBuilding (cmake --build)...\033[0m"
cmake --build build_linux --config "$BUILD_TYPE" --parallel
if [[ $? -ne 0 ]]; then
  echo -e "\033[31mERROR: cmake build failed\033[0m"
  exit 1
fi

# Run tests if requested
if [[ "$RUN_TESTS" == true ]]; then
  echo -e "\033[32mRunning tests (ctest)...\033[0m"
  cd build_linux
  ctest --output-on-failure
  ctest_code=$?
  cd ..
  if [[ $ctest_code -ne 0 ]]; then
    echo -e "\033[31mERROR: ctest failed\033[0m"
    exit 1
  fi
fi

echo -e "\033[32mSUCCESS: Build completed.\033[0m"
