# NOTICE

This repository is a fork of [DXVK](https://github.com/doitsujin/dxvk).
DXVK is licensed under the zlib/libpng license; see [`LICENSE`](LICENSE).

## A0 provenance

- Upstream: `https://github.com/doitsujin/dxvk`
- A0/A1 base pin: `d30be2baea02a67b9502bffda0ec8b0d915bb3d2`
  (2026-10-01, DXVK 3.1.1). This is 133 commits behind upstream
  `master` (`cf0a0d90`) as of 2026-11-06. Forward-porting to current
  master is a separate later change.
- VRS reference:
  `https://github.com/poprox24/vrchat-dfr-linux` at
  `62c40ef04a82155cfa1f34d7da1c337e6a0b630c` (2026-11-03).

The reference repository separates its licensing as follows:

- Integration scripts, configuration and documentation: MIT.
- Its DXVK patch (`patches/dxvk-gaze-vrs.patch`): zlib/libpng, the same
  license as DXVK. Binaries built from it are modified DXVK builds.
- Its WiVRn patch (`patches/wivrn-gaze-export.patch`): GPL-3.0-or-later.
  **That WiVRn patch is not copied into this repository and must not be
  used here.**

A0 does not include or enable the reference VRS patch. A1 will adapt the
reference's fixed-centre VRS path and record the resulting modifications
in this notice.
