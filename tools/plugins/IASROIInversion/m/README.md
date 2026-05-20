# tools/plugins/IASROIInversion/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `ias_map_estimation_roi.m` — **ias_map_estimation**: Ias map estimation.
- `zef_switch_roi_mode.m` — **if get(zef**: If get(zef.
- `zef_update_ias_roi.m` — **zef.iasroi_roi_mode = get(zef**: Zef.iasroi roi mode = get(zef.
- `zef_ias_iteration_roi.m` — **zef_ias_iteration_roi**: Zef ias iteration roi.
- `zef_ias_map_estimation_roi_window.m` — **zef_ias_map_estimation_roi_window**: Zef ias map estimation roi window.
- `zef_iasroi_plot_roi.m` — **zef_iasroi_plot_roi**: Zef iasroi plot roi.
- `zef_init_ias_roi.m` — **zef_init_ias_roi**: Initializes GUI widgets and default `zef` fields for ias_roi.

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
- ``[zef] = ias_map_estimation(zef)` with project root and `src` on the path.`
- `Call `if get(zef` from MATLAB with the project root on the path.`
- `Call `zef.iasroi_roi_mode = get(zef` from MATLAB with the project root on the path.`
- ``[[z, rec_source]] = zef_ias_iteration_roi(zef)` with project root and `src` on the path.`
- ``[zef] = zef_ias_map_estimation_roi_window(zef)` with project root and `src` on the path.`
- ``[[iasroi_roi_sphere, h_roi_sphere]] = zef_iasroi_plot_roi(zef)` with project root and `src` on the path.`
- ``[zef] = zef_init_ias_roi(zef)` with project root and `src` on the path.`

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
