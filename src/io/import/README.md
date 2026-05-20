# src/io/import

## Purpose of this folder

Project load/save, segmentation import, figure import, FEM export.

## Contents

MATLAB sources:
- `zef_bst_2_zef_atlas.m` — **zef_bst_2_zef_atlas**: Zef bst 2 zef atlas.
- `zef_bst_2_zef_sensors.m` — **zef_bst_2_zef_sensors**: Zef bst 2 zef sensors.
- `zef_bst_2_zef_surface.m` — **zef_bst_2_zef_surface**: Zef bst 2 zef surface.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[[p_c_table, p_points]] = zef_bst_2_zef_atlas(subject, surface_ind_aux, surface_struct, atlas_compartment, …)` with project root and `src` on the path.`
- ``[[sensor_positions, sensor_orientations, sensor_ind]] = zef_bst_2_zef_sensors(varargin)` with project root and `src` on the path.`
- ``[[vertices, faces, surface_data]] = zef_bst_2_zef_surface(varargin)` with project root and `src` on the path.`

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
