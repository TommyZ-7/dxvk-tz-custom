# A1: Reference VRS baseline (fixed centre)

- Status: complete (2026-11-06)
- Branch: `feat/a1-vrs-fixed-center`
- Base: `chore/a0-build` (`6e4d72b7`)
- Reference: `https://github.com/poprox24/vrchat-dfr-linux` at
  `62c40ef04a82155cfa1f34d7da1c337e6a0b630c`
- DXVK pin: `d30be2baea02a67b9502bffda0ec8b0d915bb3d2`

## Decision

A1 imports the reference DXVK patch as the working VRS baseline instead of
writing the attachment, tile-rate upload, and rate query from scratch. The
patch applies cleanly at the pinned DXVK revision and builds for Windows x64.
This is a ruling, not a silent deviation:

- Why: the reference already contains the dynamic-rendering
  `VkRenderingFragmentShadingRateAttachmentInfoKHR` path, the `R8_UINT`
  tile-rate image, the barriers, the rate query, and the fixed-centre mode.
  Reusing it removes the highest-risk unknowns from A1.
- Cost if wrong: the branch carries the reference's WiVRn-shaped env surface
  and shared-memory reader until A2 replaces it with `vrs.json`. A2 must
  remove that dependency and rename the public knobs.

## Applied patch

```sh
git apply /tmp/opencode/vrchat-dfr-linux/patches/dxvk-gaze-vrs.patch
```

New files:

- `src/dxvk/dxvk_gaze_vrs.cpp`
- `src/dxvk/dxvk_gaze_vrs.h`
- `src/dxvk/dxvk_gaze_dot.h`

Modified DXVK files include `dxvk_context.cpp`, `dxvk_cmdlist.h`,
`dxvk_device_info.cpp`, `dxvk_framebuffer.h`, `dxvk_graphics.cpp`,
`dxvk_shader.cpp`, `src/vulkan/vulkan_loader.h`, and `src/dxvk/meson.build`.

## Build and verification

```sh
git submodule update --init --recursive
rm -rf build.w64
MINGW_PREFIX=/home/tommyz7/work-saeki/toolchains/llvm-mingw-20261104-ucrt-ubuntu-22.04-x86_64 \
MESON=/home/tommyz7/work-saeki/toolchains/meson-venv/bin/meson \
  ./scripts/build-win64.sh
MINGW_PREFIX=... ./scripts/verify-win64.sh
```

Observed result: 258 ninja steps, exit 0. Both DLLs are PE32+ x86-64.
`strings build.w64/src/d3d11/d3d11.dll` contains `GazeVRS: pass fb` and the
`DXVK_GAZE_*` environment names, confirming the VRS path is compiled in.

## Fixed-centre smoke configuration

The reference's synthetic fixed mode avoids the WiVRn shared-memory file:

```sh
DXVK_GAZE_VRS=1 \
DXVK_GAZE_FMT=97 \
DXVK_GAZE_FLIP_Y=1 \
DXVK_GAZE_FAKE=fixed \
DXVK_GAZE_FIXED_Y=0.5 \
DXVK_GAZE_COARSE=auto
```

This is the A1 smoke path. It places the foveation centre at the middle of
each eye and does not require a gaze source.

## A2 handoff

A2 replaces the reference's gaze source with `vrs.json`:

- `center_left` / `center_right` / `center_offset`
- `scene_format` (`rgba16f` default) and `flip_y`
- `inner_radius` / `outer_radius` / `feather`
- `rate_inner` / `rate_mid` / `rate_outer`, clamped to the queried
  `vkGetPhysicalDeviceFragmentShadingRatesKHR` list
- `stereo_only`, `compare`, `compare_interval_ms`, `debug_show_map`
- RADV GFX11 effective rates are `1x1`/`1x2`/`2x1`/`2x2`; `rate_outer=4x4`
  becomes `2x2`. MSAA coarse-rate `sampleCounts` are limited to 1/2/4.
- Remove the WiVRn `/dev/shm` reader and the `DXVK_GAZE_*` public surface from
  the shipping path, or keep it only as a diagnostic fallback.
- A3 adds the file watcher and frame-boundary atomic swap.

## Licensing

The imported patch is Zlib/libpng, same as DXVK. The reference's integration
scripts/docs are MIT. The WiVRn GPL patch is not used. See `NOTICE.md`.
