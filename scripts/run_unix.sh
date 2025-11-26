#!/usr/bin/env bash
# run_unix.sh
# Find and run built executables in the build directory on Linux/macOS.

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
    # skip empty lines
    [[ -n "$name" ]] && KNOWN+=("$name")
  done < <(grep -RhoE "add_executable[[:space:]]*\([^[:space:]]+" CMakeLists.txt 2>/dev/null | sed -E 's/add_executable\s*\(\s*//I' | sort -u)
fi

# Fallback defaults if nothing found
if [[ ${#KNOWN[@]} -eq 0 ]]; then
  KNOWN=(calculator_app hello_app hello_world_app unit_tests)
fi

usage() {
  echo "Usage: $0 [--name <binary>] [--all] [--list] [--dry-run]"
  echo "  --name <binary>   Run the named binary (without extension)"
  echo "  --all             Run all known binaries"
  echo "  --list            Print discovered targets and exit"
  echo "  --dry-run         Print resolved executable paths without running"
  echo "  --args <...>      Pass remaining args to the executed binary"
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
      # collect remaining args as runtime args to pass to the executable
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
  # allow listing discovered targets without choosing a run target
  if [[ "$LIST" == true ]]; then
    if [[ ${#KNOWN[@]} -eq 0 ]]; then
      echo "No targets discovered."; exit 0
    fi
    echo "Discovered targets:"; for t in "${KNOWN[@]}"; do echo " - $t"; done; exit 0
  fi
  if [[ "$DRY_RUN" == true ]]; then
    # Dry-run mode: show discovered paths for all known targets but don't run
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
    if [[ "$DRY_RUN" == true ]]; then
      echo "  $exe"
    else
      echo "Running: $exe"
      exe_dir=$(dirname "$exe")
      if [[ ${#ARGS[@]} -gt 0 ]]; then
        (cd "$exe_dir" && "$exe" "${ARGS[@]}") || echo "Process $exe exited with non-zero code"
      else
        (cd "$exe_dir" && "$exe") || echo "Process $exe exited with non-zero code"
      fi
    fi
  done
done
