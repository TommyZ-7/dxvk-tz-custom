#!/usr/bin/env bash
#
# Verify the A0 d3d11.dll / dxgi.dll build: PE32+ x86-64, expected exports,
# and no dynamically linked MinGW C/C++ runtime.
#
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
build_dir=${BUILD_DIR:-"$repo_root/build.w64"}
mingw_prefix=${MINGW_PREFIX:-/home/tommyz7/work-saeki/toolchains/llvm-mingw-20261104-ucrt-ubuntu-22.04-x86_64}
objdump=${OBJDUMP:-x86_64-w64-mingw32-objdump}

export PATH="$mingw_prefix/bin:$PATH"

if ! command -v "$objdump" >/dev/null 2>&1; then
  echo "error: $objdump not found (check OBJDUMP / MINGW_PREFIX)" >&2
  exit 1
fi

fail=0

check_pe() {
  local path=$1
  local description
  description=$(file -b "$path")

  echo "== $path"
  echo "   file: $description"

  if [[ "$description" != *"PE32+ executable"* ||
        "$description" != *"DLL"* ||
        "$description" != *"x86-64"* ]]; then
    echo "   FAIL: not a PE32+ x86-64 DLL" >&2
    fail=1
  fi
}

check_export() {
  local path=$1
  local name=$2

  if ! "$objdump" -p "$path" | grep -qE "[[:space:]]${name}\$"; then
    echo "   FAIL: missing export $name" >&2
    fail=1
  else
    echo "   export: $name"
  fi
}

check_no_dynamic_cxx_runtime() {
  local path=$1

  if "$objdump" -p "$path" |
      grep -qiE 'DLL Name: (libc\+\+|libstdc\+\+-6|libgcc_s_)'; then
    echo "   FAIL: dynamically linked MinGW C/C++ runtime found" >&2
    fail=1
  else
    echo "   runtime: statically linked (no libc++/libstdc++/libgcc DLL)"
  fi
}

for dll in d3d11 dxgi; do
  path="$build_dir/src/$dll/$dll.dll"

  if [[ ! -f "$path" ]]; then
    echo "error: missing $path" >&2
    exit 1
  fi

  check_pe "$path"
  check_no_dynamic_cxx_runtime "$path"
done

for name in \
  D3D11CoreCreateDevice \
  D3D11CreateDevice \
  D3D11CreateDeviceAndSwapChain \
  D3D11On12CreateDevice; do
  check_export "$build_dir/src/d3d11/d3d11.dll" "$name"
done

for name in \
  CreateDXGIFactory \
  CreateDXGIFactory1 \
  CreateDXGIFactory2 \
  DXGIDeclareAdapterRemovalSupport \
  DXGIGetDebugInterface1; do
  check_export "$build_dir/src/dxgi/dxgi.dll" "$name"
done

if (( fail != 0 )); then
  echo "A0 build verification: FAILED" >&2
  exit 1
fi

echo "A0 build verification: PASS"
