# tools/plugins/DynamicalPlotQueue/m/dynamical_plot_queue_bank

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_dpq_plot_GMM.m` — **function zef_PlotGMModel**: Function zef Plot GMModel.
- `zef_dpq_plot_GMM_v1.m` — **function zef_PlotGMModel**: Function zef Plot GMModel.
- `zef_add_dof_space.m` — **function zef_add_dof_space**: Function zef add dof space.
- `zef_dpq_wireframe_plot.m` — **function zef_dpq_wireframe_plot**: Function zef dpq wireframe plot.
- `zef_plot_SESAME_dipoles.m` — **function zef_plot_SESAME_dipoles**: Function zef plot SESAME dipoles.
- `zef_dpq_plot_resection.m` — **zef_dpq_plot_resection**: Zef dpq plot resection.
- `zef_plot_3D_arrow_reconstructed_source.m` — **zef_plot_3D_arrow_reconstructed_source**: Renders or updates a plot_3d_arrow_reconstructed_source figure from current `zef` state.
- `zef_plot_3D_arrow_synthetic_source.m` — **zef_plot_3D_arrow_synthetic_source**: Renders or updates a plot_3d_arrow_synthetic_source figure from current `zef` state.
- `zef_plot_3D_stem_reconstructed_source.m` — **zef_plot_3D_stem_reconstructed_source**: Renders or updates a plot_3d_stem_reconstructed_source figure from current `zef` state.
- `zef_plot_3D_stem_synthetic_source.m` — **zef_plot_3D_stem_synthetic_source**: Renders or updates a plot_3d_stem_synthetic_source figure from current `zef` state.
- `zef_plot_GMModel.m` — **zef_plot_GMModel**: Renders or updates a plot_gmmodel figure from current `zef` state.
- `zef_plot_GMModel_max.m` — **zef_plot_GMModel_max**: Renders or updates a plot_gmmodel_max figure from current `zef` state.
- `zef_plot_strip.m` — **zef_plot_strip**: Renders or updates a plot_strip figure from current `zef` state.
- `zef_plot_strips.m` — **zef_plot_strips**: Renders or updates a plot_strips figure from current `zef` state.
- `zef_plot_synthetic_source.m` — **zef_plot_synthetic_source**: Renders or updates a plot_synthetic_source figure from current `zef` state.
- `zef_simple_plot_sphere_max.m` — **zef_simple_plot_sphere_max**: Zef simple plot sphere max.
- `zef_simple_plot_sphere_min.m` — **zef_simple_plot_sphere_min**: Zef simple plot sphere min.

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
- `Call `function zef_PlotGMModel` from MATLAB with the project root on the path.`
- `Call `function zef_PlotGMModel` from MATLAB with the project root on the path.`
- `Call `function zef_add_dof_space` from MATLAB with the project root on the path.`
- `Call `function zef_dpq_wireframe_plot` from MATLAB with the project root on the path.`
- `Call `function zef_plot_SESAME_dipoles` from MATLAB with the project root on the path.`
- ``zef_dpq_plot_resection(varargin)` with project root and `src` on the path.`
- ``zef_plot_3D_arrow_reconstructed_source(varargin)` with project root and `src` on the path.`
- ``zef_plot_3D_arrow_synthetic_source(varargin)` with project root and `src` on the path.`

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
