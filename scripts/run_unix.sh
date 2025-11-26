#!/usr/bin/env bash
# run_unix.sh
# Find and run built executables in the build directory on Linux/macOS.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

NAME=""
ALL=false
# Discover targets from CMakeLists.txt (add_executable)
KNOWN=()
if command -v grep >/dev/null 2>&1; then
  while IFS= read -r name; do
    # skip empty lines
    [[ -n "$name" ]] && KNOWN+=("$name")
  done < <(grep -RhoE "add_executable[[:space:]]*\([^[:space:]]+" CMakeLists.txt 2>/dev/null | sed -E 's/add_executable\s*\(\s*//I' | sort -u)
fi

# Fallback defaults if nothing found
if [[ ${#KNOWN[@]} -eq 0 ]]; then
  KNOWN=(calculator_app hello_app hello_world_app unit_tests)
fi

usage() {
  echo "Usage: $0 [--name <binary>] [--all]"
  echo "  --name <binary>   Run the named binary (without extension)"
  echo "  --all             Run all known binaries"
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="$2"
      shift 2
      ;;
    --all)
      ALL=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$(ls -A build 2>/dev/null || true)" ]]; then
  echo "No build directory found. Run build first." >&2
  exit 2
fi

if [[ "$ALL" == true ]]; then
  to_run=("${KNOWN[@]}")
elif [[ -n "$NAME" ]]; then
  to_run=("$NAME")
else
  usage
fi

for n in "${to_run[@]}"; do
  echo "Searching for $n in build/..."
  # Find executable files matching the name (no extension)
  matches=()
  while IFS= read -r -d $'\0' f; do
    matches+=("$f")
  done < <(find build -type f -perm -111 -name "$n" -print0 2>/dev/null)

  if [[ ${#matches[@]} -eq 0 ]]; then
    # Also check for common single-config outputs without exec bit (e.g. created by cmake in some setups)
    while IFS= read -r -d $'\0' f; do
      matches+=("$f")
    done < <(find build -type f -name "$n" -print0 2>/dev/null)
  fi

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No binary found for $n" >&2
    continue
  fi

  for exe in "${matches[@]}"; do
    echo "Running: $exe"
    exe_dir=$(dirname "$exe")
    (cd "$exe_dir" && "$exe") || echo "Process $exe exited with non-zero code"
  done
done
