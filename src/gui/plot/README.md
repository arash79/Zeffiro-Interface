# src/gui/plot

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_plot_roi.m` — **function [inv_roi_sphere,h_roi_sphere] = zef_plot_roi**: Function [inv roi sphere,h roi sphere] = zef plot roi.
- `zef_plot_condition.m` — **function zef_plot_condition**: Function zef plot condition.
- `zef_plot_graph.m` — **function zef_plot_graph**: Function zef plot graph.
- `zef_plot_hyperprior.m` — **function zef_plot_hyperprior**: Function zef plot hyperprior.
- `zef_butterfly_plot_app.m` — **h1 = figure(...**: H1 = figure(....
- `zef_plot_volume.m.m` — **if not(isequal(zef**: If not(isequal(zef.
- `zef_visualize_surfaces.m` — **zef = zef_process_meshes(zef,zef**: Zef = zef process meshes(zef,zef.
- `zef_butterfly_plot.m` — **zef_butterfly_plot**: Zef butterfly plot.
- `zef_butterfly_plot_start.m` — **zef_butterfly_plot_start**: Zef butterfly plot start.
- `zef_plot_3D_arrow.m` — **zef_plot_3D_arrow**: Renders or updates a plot_3d_arrow figure from current `zef` state.
- `zef_plot_cone_field.m` — **zef_plot_cone_field**: Renders or updates a plot_cone_field figure from current `zef` state.
- `zef_plot_contour.m` — **zef_plot_contour**: Renders or updates a plot_contour figure from current `zef` state.
- `zef_plot_meshes.m` — **zef_plot_meshes**: Renders or updates a plot_meshes figure from current `zef` state.
- `zef_plot_parcellation_time_series.m` — **zef_plot_parcellation_time_series**: Renders or updates a plot_parcellation_time_series figure from current `zef` state.
- `zef_plot_source.m` — **zef_plot_source**: Renders or updates a plot_source figure from current `zef` state.
- `zef_plot_volume.m` — **zef_plot_volume**: Renders or updates a plot_volume figure from current `zef` state.
- `zef_print_meshes.m` — **zef_print_meshes**: Zef print meshes.
- `zef_visualize_volume.m` — **zef_process_meshes(zef,zef**: Zef process meshes(zef,zef.
- `zef_visualize_dti_streamlines.m` — **zef_visualize_dti_streamlines**: Renders or updates a visualize_dti_streamlines figure from current `zef` state.

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
- `Call `function [inv_roi_sphere,h_roi_sphere] = zef_plot_roi` from MATLAB with the project root on the path.`
- `Call `function zef_plot_condition` from MATLAB with the project root on the path.`
- `Call `function zef_plot_graph` from MATLAB with the project root on the path.`
- `Call `function zef_plot_hyperprior` from MATLAB with the project root on the path.`
- `Call `h1 = figure(...` from MATLAB with the project root on the path.`
- `Call `if not(isequal(zef` from MATLAB with the project root on the path.`
- `Call `zef = zef_process_meshes(zef,zef` from MATLAB with the project root on the path.`
- ``[zef] = zef_butterfly_plot(zef)` with project root and `src` on the path.`

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
