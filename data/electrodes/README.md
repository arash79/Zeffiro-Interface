# data/electrodes

## Purpose of this folder

Bundled sample projects, segmentations, and runtime data roots referenced by examples and default startup.

## Contents

Other files:
- `EGI-256.dat`
- `GSN-HydroCel-128.dat`
- `GSN-HydroCel-129.dat`
- `GSN-HydroCel-256.dat`
- `GSN-HydroCel-257.dat`
- `GSN-HydroCel-32.dat`
- `GSN-HydroCel-64-.dat`
- `GSN-HydroCel-65-.dat`
- `artinis-brite-23.dat`
- `artinis-octamon.dat`
- `biosemi-128.dat`
- `biosemi-16.dat`
- `biosemi-160.dat`
- `biosemi-256.dat`
- `biosemi-32.dat`
- `biosemi-64.dat`
- `brainproducts-RNP-BA-128.dat`
- `easycap-M-1.dat`
- `easycap-M-10.dat`
- `mgh-60.dat`
- `mgh-70.dat`
- `standard-1005.dat`
- `standard-1020.dat`

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

Add the project root to the MATLAB path (`zeffiro_interface` or `addpath(genpath(projectRoot))`), then call functions in child folders using package or `zef_*` names as listed under Contents.

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
