# data/log

## Purpose of this folder

Bundled sample projects, segmentations, and runtime data roots referenced by examples and default startup.

## Contents

Other files:
- `zeffiro_interface_1.log`
- `zeffiro_interface_10.log`
- `zeffiro_interface_11.log`
- `zeffiro_interface_12.log`
- `zeffiro_interface_13.log`
- `zeffiro_interface_14.log`
- `zeffiro_interface_15.log`
- `zeffiro_interface_16.log`
- `zeffiro_interface_17.log`
- `zeffiro_interface_18.log`
- `zeffiro_interface_19.log`
- `zeffiro_interface_2.log`
- `zeffiro_interface_20.log`
- `zeffiro_interface_21.log`
- `zeffiro_interface_22.log`
- `zeffiro_interface_23.log`
- `zeffiro_interface_24.log`
- `zeffiro_interface_25.log`
- `zeffiro_interface_26.log`
- `zeffiro_interface_27.log`
- `zeffiro_interface_28.log`
- `zeffiro_interface_29.log`
- `zeffiro_interface_3.log`
- `zeffiro_interface_30.log`
- `zeffiro_interface_31.log`
- `zeffiro_interface_32.log`
- `zeffiro_interface_33.log`
- `zeffiro_interface_34.log`
- `zeffiro_interface_35.log`
- `zeffiro_interface_36.log`

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
