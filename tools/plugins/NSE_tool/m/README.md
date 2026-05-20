# tools/plugins/NSE_tool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_nse_apply_nvc_source.m` — **h_axes = gca;**: H axes = gca;.
- `zef_nse_apply_source.m` — **h_axes = gca;**: H axes = gca;.
- `zef_nse_dir_v_node.m` — **h_axes = gca;**: H axes = gca;.
- `zef_nse_apply_roi.m` — **if isempty(findobj(allchild(zef**: If isempty(findobj(allchild(zef.
- `zef_nse_balloon_model_solver.m` — **zef_nse_balloon_model_solver**: Zef nse balloon model solver.
- `zef_nse_calculate_perfusion.m` — **zef_nse_calculate_perfusion**: Zef nse calculate perfusion.
- `zef_nse_haemodynamic_response_solver.m` — **zef_nse_haemodynamic_response_solver**: Zef nse haemodynamic response solver.
- `zef_nse_interpolate.m` — **zef_nse_interpolate**: Zef nse interpolate.
- `zef_nse_mean_velocity_roi.m` — **zef_nse_mean_velocity_roi**: Zef nse mean velocity roi.
- `zef_nse_mollifier.m` — **zef_nse_mollifier**: Zef nse mollifier.
- `zef_nse_plot_epoched.m` — **zef_nse_plot_epoched**: Zef nse plot epoched.
- `zef_nse_plot_full.m` — **zef_nse_plot_full**: Zef nse plot full.
- `zef_nse_plot_graph.m` — **zef_nse_plot_graph**: Zef nse plot graph.
- `zef_nse_plot_histogram.m` — **zef_nse_plot_histogram**: Zef nse plot histogram.
- `zef_nse_plot_roi.m` — **zef_nse_plot_roi**: Zef nse plot roi.
- `zef_nse_plot_signal_pulse.m` — **zef_nse_plot_signal_pulse**: Zef nse plot signal pulse.
- `zef_nse_plot_sphere.m` — **zef_nse_plot_sphere**: Zef nse plot sphere.
- `zef_nse_roi_ind.m` — **zef_nse_roi_ind**: Zef nse roi ind.
- `zef_nse_separate_waves_roi.m` — **zef_nse_separate_waves_roi**: Zef nse separate waves roi.
- `zef_nse_tool_init.m` — **zef_nse_tool_init**: Zef nse tool init.
- `zef_nse_tool_start.m` — **zef_nse_tool_start**: Zef nse tool start.
- `zef_nse_tool_update.m` — **zef_nse_tool_update**: Zef nse tool update.
- `zef_nse_tool_window.m` — **zef_nse_tool_window**: Zef nse tool window.
- `zef_nse_vel_dir.m` — **zef_nse_vel_dir**: Zef nse vel dir.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_nse_tool_window**: GUI callback or dialog (`zef_nse_tool_window`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `h_axes = gca;` from MATLAB with the project root on the path.`
- `Call `h_axes = gca;` from MATLAB with the project root on the path.`
- `Call `h_axes = gca;` from MATLAB with the project root on the path.`
- `Call `if isempty(findobj(allchild(zef` from MATLAB with the project root on the path.`
- ``[[y, dy]] = zef_nse_balloon_model_solver(time_vec, blood_flow_signal_decay_rate, flow_dependent_elimination_constant, neural_activity_impulse, …)` with project root and `src` on the path.`
- ``[perfusion_estimate] = zef_nse_calculate_perfusion(nse_field, nodes, tetra, domain_labels, …)` with project root and `src` on the path.`
- ``[nse_field] = zef_nse_haemodynamic_response_solver(zef, nse_field, nodes, tetra, …)` with project root and `src` on the path.`
- ``[zef] = zef_nse_interpolate(zef, type)` with project root and `src` on the path.`

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
