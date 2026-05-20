# tools/plugins/FindSyntheticSource/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `find_synthetic_source.m` — **find_synthetic_source**: Find synthetic source.
- `zef_plot_source_intensity.m` — **function zef_plot_source_intensity**: Function zef plot source intensity.
- `remove_synthetic_source.m` — **if isfield(zef,'synth_source_data')**: If isfield(zef,'synth source data').
- `add_synthetic_source.m` — **zef.find_synth_source.h_source_parameters.Data=zef**: Zef.find synth source.h source parameters.Data=zef.
- `zef_find_source.m` — **zef_find_source**: Zef find source.
- `zef_generate_time_sequence.m` — **zef_generate_time_sequence**: Zef generate time sequence.
- `zef_plot_source.m` — **zef_plot_source**: Renders or updates a plot_source figure from current `zef` state.
- `zef_update_fss.m` — **zef_update_fss**: Syncs GUI control values into `zef` for fss.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **find_synthetic_source**: GUI callback or dialog (`find_synthetic_source`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[zef] = find_synthetic_source(zef)` with project root and `src` on the path.`
- `Call `function zef_plot_source_intensity` from MATLAB with the project root on the path.`
- `Call `if isfield(zef,'synth_source_data')` from MATLAB with the project root on the path.`
- `Call `zef.find_synth_source.h_source_parameters.Data=zef` from MATLAB with the project root on the path.`
- ``[meas_data] = zef_find_source(zef)` with project root and `src` on the path.`
- ``[[time_serie, time_var]] = zef_generate_time_sequence(zef)` with project root and `src` on the path.`
- ``[h_source] = zef_plot_source(source_type)` with project root and `src` on the path.`
- ``[zef] = zef_update_fss(zef)` with project root and `src` on the path.`

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
