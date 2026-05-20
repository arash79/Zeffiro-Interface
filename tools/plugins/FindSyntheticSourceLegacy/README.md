# tools/plugins/FindSyntheticSourceLegacy

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_find_source_legacy.m` — **find_source**: Find source.
- `zef_init_fss_legacy.m` — **if not(isfield(zef,'inv_synth_source'));**: If not(isfield(zef,'inv synth source'));.
- `zef_find_synthetic_source_legacy_app.m` — **zef.h_find_synthetic_source_legacy = figure(...**: Zef.h find synthetic source legacy = figure(....
- `zef_find_synthetic_source_legacy.m` — **zef_find_synthetic_source_legacy**: Zef find synthetic source legacy.
- `zef_find_synthetic_source_legacy_window.m` — **zef_find_synthetic_source_legacy_window**: Zef find synthetic source legacy window.
- `zef_plot_source_legacy.m` — **zef_plot_source**: Renders or updates a plot_source figure from current `zef` state.
- `zef_update_fss_legacy.m` — **zef_update_fss_legacy**: Syncs GUI control values into `zef` for fss_legacy.

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
- ``[meas_data] = find_source(zef)` with project root and `src` on the path.`
- `Call `if not(isfield(zef,'inv_synth_source'));` from MATLAB with the project root on the path.`
- `Call `zef.h_find_synthetic_source_legacy = figure(...` from MATLAB with the project root on the path.`
- ``[zef] = zef_find_synthetic_source_legacy(zef)` with project root and `src` on the path.`
- ``[zef] = zef_find_synthetic_source_legacy_window(zef)` with project root and `src` on the path.`
- ``[h_source] = zef_plot_source(zef, source_type)` with project root and `src` on the path.`
- ``[zef] = zef_update_fss_legacy(zef)` with project root and `src` on the path.`

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
