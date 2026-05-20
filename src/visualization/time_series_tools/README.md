# src/visualization/time_series_tools

## Purpose of this folder

Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.

## Contents

MATLAB sources:
- `zef_corr_max_scaling.m` — **zef_corr_max_scaling**: Zef corr max scaling.
- `zef_corr_max_scaling_max_weighting.m` — **zef_corr_max_scaling_max_weighting**: Zef corr max scaling max weighting.
- `zef_corr_mean_scaling.m` — **zef_corr_mean_scaling**: Zef corr mean scaling.
- `zef_corr_mean_scaling_mean_weighting.m` — **zef_corr_mean_scaling_mean_weighting**: Zef corr mean scaling mean weighting.
- `zef_corr_no_scaling.m` — **zef_corr_no_scaling**: Zef corr no scaling.
- `zef_cov_max_scaling.m` — **zef_cov_max_scaling**: Zef cov max scaling.
- `zef_cov_mean_scaling.m` — **zef_cov_mean_scaling**: Zef cov mean scaling.
- `zef_cov_no_scaling.m` — **zef_cov_no_scaling**: Zef cov no scaling.
- `zef_dtw_max_scaling.m` — **zef_dtw_max_scaling**: Zef dtw max scaling.
- `zef_dtw_mean_scaling.m` — **zef_dtw_mean_scaling**: Zef dtw mean scaling.
- `zef_dtw_no_scaling.m` — **zef_dtw_no_scaling**: Zef dtw no scaling.
- `zef_max_energy_max_scaling.m` — **zef_max_energy_max_scaling**: Zef max energy max scaling.
- `zef_max_energy_mean_scaling.m` — **zef_max_energy_mean_scaling**: Zef max energy mean scaling.
- `zef_max_energy_no_scaling.m` — **zef_max_energy_no_scaling**: Zef max energy no scaling.
- `zef_mean_energy_max_scaling.m` — **zef_mean_energy_max_scaling**: Zef mean energy max scaling.
- `zef_mean_energy_mean_scaling.m` — **zef_mean_energy_mean_scaling**: Zef mean energy mean scaling.
- `zef_mean_energy_no_scaling.m` — **zef_mean_energy_no_scaling**: Zef mean energy no scaling.
- `zef_parcellation_boxplot_amplitude.m` — **zef_parcellation_boxplot_amplitude**: Zef parcellation boxplot amplitude.
- `zef_std_mean_scaling.m` — **zef_std_mean_scaling**: Zef std mean scaling.
- `zef_std_max_scaling.m` — **zef_std_no_scaling**: Zef std no scaling.
- `zef_std_no_scaling.m` — **zef_std_no_scaling**: Zef std no scaling.
- `zef_time_series_plot.m` — **zef_time_series_plot**: Zef time series plot.
- `zef_time_series_plot_sqrt.m` — **zef_time_series_plot_sqrt**: Zef time series plot sqrt.

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
- ``[[y_vals, plot_mode]] = zef_corr_max_scaling(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_corr_max_scaling_max_weighting(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_corr_mean_scaling(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_corr_mean_scaling_mean_weighting(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_corr_no_scaling(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_cov_max_scaling(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_cov_mean_scaling(time_series)` with project root and `src` on the path.`
- ``[[y_vals, plot_mode]] = zef_cov_no_scaling(time_series)` with project root and `src` on the path.`

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
