#!/usr/bin/env bash
#
# Shared toolchain validation for the A0 Windows x64 build.
# Source this file; it exports PATH and validates the pinned versions.

set -euo pipefail

EXPECTED_CLANG="23.1.5"
EXPECTED_MESON="1.7.2"
EXPECTED_NINJA="1.13.2"
EXPECTED_GLSLANG="16.6.0"

mingw_prefix=${MINGW_PREFIX:-}
if [[ -z "$mingw_prefix" ]]; then
  echo "error: set MINGW_PREFIX to the llvm-mingw 20261104 UCRT root" >&2
  exit 1
fi
if [[ ! -x "$mingw_prefix/bin/x86_64-w64-mingw32-clang++" ]]; then
  echo "error: llvm-mingw not found under MINGW_PREFIX=$mingw_prefix" >&2
  exit 1
fi
if [[ "$mingw_prefix" != *ucrt* ]]; then
  echo "error: MINGW_PREFIX must point at the UCRT llvm-mingw toolchain" >&2
  exit 1
fi

export PATH="$mingw_prefix/bin:$PATH"

clang_line=$("$mingw_prefix/bin/x86_64-w64-mingw32-clang++" --version | head -1)
if [[ "$clang_line" != *"clang version $EXPECTED_CLANG"* ]]; then
  echo "error: expected clang $EXPECTED_CLANG, got: $clang_line" >&2
  exit 1
fi

meson=${MESON:-meson}
meson_version=$("$meson" --version 2>/dev/null || true)
if [[ "$meson_version" != "$EXPECTED_MESON" ]]; then
  echo "error: expected Meson $EXPECTED_MESON, got: ${meson_version:-missing}" >&2
  exit 1
fi

ninja_version=$(ninja --version 2>/dev/null || true)
if [[ "$ninja_version" != "$EXPECTED_NINJA" ]]; then
  echo "error: expected Ninja $EXPECTED_NINJA, got: ${ninja_version:-missing}" >&2
  exit 1
fi

glslang_bin=$(command -v glslang || command -v glslangValidator || true)
if [[ -z "$glslang_bin" ]]; then
  echo "error: glslang / glslangValidator not found on PATH" >&2
  exit 1
fi
glslang_version=$("$glslang_bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
if [[ "$glslang_version" != "$EXPECTED_GLSLANG" ]]; then
  echo "error: expected glslang $EXPECTED_GLSLANG, got: ${glslang_version:-unknown}" >&2
  exit 1
fi

export MINGW_PREFIX="$mingw_prefix"
export MESON="$meson"
