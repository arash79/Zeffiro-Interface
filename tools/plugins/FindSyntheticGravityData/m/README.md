# tools/plugins/FindSyntheticGravityData/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_plot_gravity_roi.m` — **function [inv_roi_sphere,h_roi_sphere] = zef_plot_gravity_roi**: Function [inv roi sphere,h roi sphere] = zef plot gravity roi.
- `zef_init_find_synthetic_gravity_data.m` — **set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef**: Set(zef.h inv roi sphere 1 ,'string',num2str(zef.
- `zef_synthetic_gravity_data.m` — **tic;**: Tic;.
- `zef_find_synthetic_gravity_data.m` — **zef.h_find_synthetic_gravity_data = open('find_synthetic_gravity_data**: Zef.h find synthetic gravity data = open('find synthetic gravity data.
- `zef_update_find_synthetic_gravity_data.m` — **zef.inv_roi_sphere(:,1) = str2num(get(zef**: Zef.inv roi sphere(:,1) = str2num(get(zef.
- `compute_gravity_data.m` — **zef_compute_gravity_data**: Zef compute gravity data.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

Open the corresponding tool or plugin from the Zeffiro menu bar (profile-dependent). Widget callbacks in this folder update `zef` and call `zef_update`.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `function [inv_roi_sphere,h_roi_sphere] = zef_plot_gravity_roi` from MATLAB with the project root on the path.`
- `Call `set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef` from MATLAB with the project root on the path.`
- `Call `tic;` from MATLAB with the project root on the path.`
- `Call `zef.h_find_synthetic_gravity_data = open('find_synthetic_gravity_data` from MATLAB with the project root on the path.`
- `Call `zef.inv_roi_sphere(:,1) = str2num(get(zef` from MATLAB with the project root on the path.`
- ``[eit_data_vec] = zef_compute_gravity_data(nodes, elements, rho, electrodes, …)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
