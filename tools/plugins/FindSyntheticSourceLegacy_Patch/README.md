# tools/plugins/FindSyntheticSourceLegacy_Patch

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_init_fss_patch.m` — **if not(isfield(zef,'inv_synth_source'));**: If not(isfield(zef,'inv synth source'));.
- `zef_find_synthetic_source_patch_app.m` — **zef.h_find_synthetic_source_legacy = figure(...**: Zef.h find synthetic source legacy = figure(....
- `zef_find_source_patch.m` — **zef_find_source_patch**: Zef find source patch.
- `zef_find_synthetic_source_patch.m` — **zef_find_synthetic_source_patch**: Zef find synthetic source patch.
- `zef_find_synthetic_source_patch_window.m` — **zef_find_synthetic_source_patch_window**: Zef find synthetic source patch window.
- `zef_plot_cones_in_roi.m` — **zef_plot_cones_in_roi**: Renders or updates a plot_cones_in_roi figure from current `zef` state.
- `zef_plot_ellipsoid.m` — **zef_plot_ellipsoid**: Renders or updates a plot_ellipsoid figure from current `zef` state.
- `zef_plot_source_patch.m` — **zef_plot_source_patch**: Renders or updates a plot_source_patch figure from current `zef` state.
- `zef_plot_sphere.m` — **zef_plot_sphere**: Renders or updates a plot_sphere figure from current `zef` state.
- `zef_project_L_in_roi.m` — **zef_project_L_in_roi**: Zef project L in roi.
- `zef_update_fss_patch.m` — **zef_update_fss_patch**: Syncs GUI control values into `zef` for fss_patch.

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
- `Call `if not(isfield(zef,'inv_synth_source'));` from MATLAB with the project root on the path.`
- `Call `zef.h_find_synthetic_source_legacy = figure(...` from MATLAB with the project root on the path.`
- ``[[meas_data, all_roi_sources, orientations]] = zef_find_source_patch(zef)` with project root and `src` on the path.`
- ``[zef] = zef_find_synthetic_source_patch(zef)` with project root and `src` on the path.`
- ``[zef] = zef_find_synthetic_source_patch_window(zef)` with project root and `src` on the path.`
- ``[h_synth_source] = zef_plot_cones_in_roi(zef, s_length)` with project root and `src` on the path.`
- ``[h_surf] = zef_plot_ellipsoid(position, a, b, c, …)` with project root and `src` on the path.`
- ``[h_source] = zef_plot_source_patch(zef, source_type)` with project root and `src` on the path.`

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
