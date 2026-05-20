# assets/fig/tools

## Purpose of this folder

Static GUI resources (`.fig` layouts) used by App Designer tools.

## Contents

Other files:
- `zef_find_synthetic_eit_data.fig`
- `zef_find_synthetic_source.fig`
- `zeffiro_interface.png`
- `zeffiro_interface_butterfly_plot.fig`
- `zeffiro_interface_figure_tool.fig`
- `zeffiro_interface_mesh_tool.fig`
- `zeffiro_interface_parcellation_tool.fig`
- `zeffiro_interface_ramus_inversion_tool.fig`
- `zeffiro_interface_segmentation_tool.fig`
- `zeffiro_logo.png`
- `zeffiro_small_logo.png`

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
