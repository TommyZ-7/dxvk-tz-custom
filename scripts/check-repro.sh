#!/usr/bin/env bash
#
# Build twice from clean directories and compare the DLL hashes.
# This is the A0 bit-reproducibility check.
#
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
first=${FIRST_BUILD_DIR:-"$repo_root/build.repro1"}
second=${SECOND_BUILD_DIR:-"$repo_root/build.repro2"}

if [[ "${SKIP_BUILD:-0}" != "1" ]]; then
  rm -rf "$first" "$second"
  BUILD_DIR="$first" "$repo_root/scripts/build-win64.sh"
  BUILD_DIR="$second" "$repo_root/scripts/build-win64.sh"
fi

first_hash=$(sha256sum "$first/src/d3d11/d3d11.dll" "$first/src/dxgi/dxgi.dll" | awk '{print $1}')
second_hash=$(sha256sum "$second/src/d3d11/d3d11.dll" "$second/src/dxgi/dxgi.dll" | awk '{print $1}')

echo "first:"
echo "$first_hash"
echo "second:"
echo "$second_hash"

if [[ "$first_hash" != "$second_hash" ]]; then
  echo "A0 reproducibility: FAILED (DLL hashes differ)" >&2
  exit 1
fi

echo "A0 reproducibility: PASS"
