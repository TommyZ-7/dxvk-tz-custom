#!/usr/bin/env bash
#
# Reproducible A0 Windows x64 build for the tz-custom DXVK fork.
#
# Required environment (see docs/superpowers/plans/2026-11-06-a0-build.md):
#   MINGW_PREFIX  llvm-mingw 20261104 UCRT root
#   MESON         meson 1.7.2 executable (or on PATH)
#
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$repo_root/scripts/toolchain-env.sh"

build_dir=${BUILD_DIR:-"$repo_root/build.w64"}

if [[ -z "${SOURCE_DATE_EPOCH:-}" ]]; then
  SOURCE_DATE_EPOCH=$(git -C "$repo_root" log -1 --format=%ct)
  export SOURCE_DATE_EPOCH
fi

setup_args=(
  "$repo_root"
  --cross-file "$repo_root/build-win64-llvm-mingw.txt"
  --buildtype release
  --wrap-mode=nodownload
  -Denable_d3d8=false
  -Denable_d3d9=false
  -Denable_d3d10=false
)

if [[ -f "$build_dir/build.ninja" ]]; then
  # Never trust an existing directory: wipe it so a stale cross file,
  # toolchain, buildtype, or option set cannot silently produce artifacts.
  "$MESON" setup --wipe "$build_dir" "${setup_args[@]}"
else
  "$MESON" setup "$build_dir" "${setup_args[@]}"
fi

ninja -C "$build_dir" src/d3d11/d3d11.dll src/dxgi/dxgi.dll

echo
echo "built with SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH:"
for dll in d3d11 dxgi; do
  echo "  $build_dir/src/$dll/$dll.dll"
done
