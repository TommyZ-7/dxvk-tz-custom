#!/usr/bin/env bash
#
# Reproducible A0 Windows x64 build for the tz-custom DXVK fork.
#
# Required environment (see docs/superpowers/plans/2026-11-06-a0-build.md):
#   MINGW_PREFIX  llvm-mingw toolchain root (contains bin/x86_64-w64-mingw32-clang++)
#   MESON         meson executable (default: meson on PATH)
#
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
build_dir=${BUILD_DIR:-"$repo_root/build.w64"}
mingw_prefix=${MINGW_PREFIX:-/home/tommyz7/work-saeki/toolchains/llvm-mingw-20261104-ucrt-ubuntu-22.04-x86_64}
meson=${MESON:-meson}

if [[ ! -x "$mingw_prefix/bin/x86_64-w64-mingw32-clang++" ]]; then
  echo "error: llvm-mingw not found under MINGW_PREFIX=$mingw_prefix" >&2
  echo "       set MINGW_PREFIX to the llvm-mingw 20261104 root" >&2
  exit 1
fi

if ! command -v "$meson" >/dev/null 2>&1; then
  echo "error: meson not found; set MESON to the meson executable" >&2
  exit 1
fi

if ! command -v ninja >/dev/null 2>&1; then
  echo "error: ninja not found on PATH" >&2
  exit 1
fi

if ! command -v glslang >/dev/null 2>&1 && ! command -v glslangValidator >/dev/null 2>&1; then
  echo "error: glslang / glslangValidator not found on PATH" >&2
  exit 1
fi

export PATH="$mingw_prefix/bin:$PATH"

if [[ ! -f "$build_dir/build.ninja" ]]; then
  "$meson" setup "$build_dir" "$repo_root" \
    --cross-file "$repo_root/build-win64-llvm-mingw.txt" \
    --buildtype release \
    --wrap-mode=nodownload \
    -Denable_d3d8=false \
    -Denable_d3d9=false \
    -Denable_d3d10=false
fi

ninja -C "$build_dir" src/d3d11/d3d11.dll src/dxgi/dxgi.dll

echo
echo "built:"
for dll in d3d11 dxgi; do
  echo "  $build_dir/src/$dll/$dll.dll"
done
