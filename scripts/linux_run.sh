#!/usr/bin/env bash
# linux_run.sh
# Find and run built executables in the build directory on Linux.
# Auto-discovers targets from CMakeLists.txt and provides --list, --dry-run, --args support.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

NAME=""
ALL=false
LIST=false
DRY_RUN=false
ARGS=()

# Discover targets from CMakeLists.txt (add_executable)
KNOWN=()
if command -v grep >/dev/null 2>&1; then
  while IFS= read -r name; do
    [[ -n "$name" ]] && KNOWN+=("$name")
  done < <(grep -RhoE "add_executable[[:space:]]*\([^[:space:]]+" CMakeLists.txt 2>/dev/null | sed -E 's/add_executable\s*\(\s*//I' | sort -u)
fi

# Fallback defaults if nothing found
if [[ ${#KNOWN[@]} -eq 0 ]]; then
  KNOWN=(calculator_app hello_app hello_world_app unit_tests)
fi

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --name <binary>   Run the named binary (without extension)"
  echo "  --all             Run all known binaries"
  echo "  --list            Print discovered targets and exit"
  echo "  --dry-run         Print resolved executable paths without running"
  echo "  --args <...>      Pass remaining arguments to the executed binary"
  echo "  -h, --help        Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 --list"
  echo "  $0 --all"
  echo "  $0 --name calculator_app"
  echo "  $0 --dry-run"
  echo "  $0 --name unit_tests --args --verbose"
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
    --list)
      LIST=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --args)
      shift
      # Collect remaining args as runtime args to pass to the executable
      while [[ $# -gt 0 ]]; do
        ARGS+=("$1")
        shift
      done
      break
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$(ls -A build_linux 2>/dev/null || true)" ]]; then
  echo "No build directory found. Run ./scripts/linux_build.sh first." >&2
  exit 2
fi

if [[ "$ALL" == true ]]; then
  to_run=("${KNOWN[@]}")
elif [[ -n "$NAME" ]]; then
  to_run=("$NAME")
else
  if [[ "$LIST" == true ]]; then
    if [[ ${#KNOWN[@]} -eq 0 ]]; then
      echo "No targets discovered."; exit 0
    fi
    echo "Discovered targets:"
    for t in "${KNOWN[@]}"; do echo "  - $t"; done
    exit 0
  fi
  if [[ "$DRY_RUN" == true ]]; then
    to_run=("${KNOWN[@]}")
  else
    usage
  fi
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry-run mode: discovered executables:"
fi

for n in "${to_run[@]}"; do
  if [[ "$DRY_RUN" != true ]]; then
    echo "Searching for $n in build/..."
  fi
  
  # Find executable files matching the name (no extension)
  matches=()
  while IFS= read -r -d $'\0' f; do
    matches+=("$f")
  done < <(find build_linux -type f -perm -111 -name "$n" -print0 2>/dev/null)

  if [[ ${#matches[@]} -eq 0 ]]; then
    # Also check for files without exec bit (some CMake setups)
    while IFS= read -r -d $'\0' f; do
      matches+=("$f")
    done < <(find build_linux -type f -name "$n" -print0 2>/dev/null)
  fi

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No binary found for $n" >&2
    continue
  fi

  for exe in "${matches[@]}"; do
    if [[ "$DRY_RUN" == true ]]; then
      echo "  $exe"
    else
      echo "Running: $exe"
      exe_dir=$(dirname "$exe")
      exe_file=$(basename "$exe")
      if [[ ${#ARGS[@]} -gt 0 ]]; then
        (cd "$exe_dir" && ./"$exe_file" "${ARGS[@]}") || echo "Process $exe exited with non-zero code"
      else
        (cd "$exe_dir" && ./"$exe_file") || echo "Process $exe exited with non-zero code"
      fi
    fi
  done
done
