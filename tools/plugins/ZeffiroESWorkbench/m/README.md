# tools/plugins/ZeffiroESWorkbench/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_ES_find_valid_separation_angle.m` — **angles_list**: Angles list.
- `zef_ES_4x1_fun.m` — **ell_idx**: Ell idx.
- `zef_ES_plot_4x1.m` — **ell_idx**: Ell idx.
- `zef_ES_plot_4x1_fun.m` — **ell_idx**: Ell idx.
- `zef_ES_update_parameter_values.m` — **if ismember(zef**: If ismember(zef.
- `zef_ES_optimization_init.m` — **zef**: Zef.
- `zef_ES_init_parameter_table.m` — **zef.h_ES_parameter_table**: Zef.h ES parameter table.
- `zef_ES_4x1_sensors.m` — **zef_ES_4x1_sensors**: Zef ES 4x1 sensors.
- `zef_ES_centralize_recursive_search.m` — **zef_ES_centralize_recursive_search**: Zef ES centralize recursive search.
- `zef_ES_centralize_recursive_search_window.m` — **zef_ES_centralize_recursive_search_window**: Zef ES centralize recursive search window.
- `zef_ES_clear_plot_data.m` — **zef_ES_clear_plot_data**: Zef ES clear plot data.
- `zef_ES_error_criteria.m` — **zef_ES_error_criteria**: Zef ES error criteria.
- `zef_ES_find_currents.m` — **zef_ES_find_currents**: Zef ES find currents.
- `zef_ES_find_currents_recursive.m` — **zef_ES_find_currents_recursive**: Zef ES find currents recursive.
- `zef_ES_find_parameters.m` — **zef_ES_find_parameters**: Zef ES find parameters.
- `zef_ES_fix_active_electrodes.m` — **zef_ES_fix_active_electrodes**: Zef ES fix active electrodes.
- `zef_ES_objective_function.m` — **zef_ES_objective_function**: Zef ES objective function.
- `zef_ES_optimization.m` — **zef_ES_optimization**: Zef ES optimization.
- `zef_ES_optimization_window.m` — **zef_ES_optimization_window**: Zef ES optimization window.
- `zef_ES_optimize_current.m` — **zef_ES_optimize_current**: Zef ES optimize current.
- `zef_ES_optimizer_properties.m` — **zef_ES_optimizer_properties**: Zef ES optimizer properties.
- `zef_ES_optimizer_properties_show.m` — **zef_ES_optimizer_properties_show**: Zef ES optimizer properties show.
- `zef_ES_plot_barplot.m` — **zef_ES_plot_barplot**: Zef ES plot barplot.
- `zef_ES_plot_current_pattern.m` — **zef_ES_plot_current_pattern**: Zef ES plot current pattern.
- `zef_ES_plot_data.m` — **zef_ES_plot_data**: Zef ES plot data.
- `zef_ES_plot_distance_curves.m` — **zef_ES_plot_distance_curves**: Zef ES plot distance curves.
- `zef_ES_plot_error_chart.m` — **zef_ES_plot_error_chart**: Zef ES plot error chart.
- `zef_ES_recursive_search.m` — **zef_ES_recursive_search**: Zef ES recursive search.
- `zef_ES_rwnnz.m` — **zef_ES_rwnnz**: Zef ES rwnnz.
- `zef_ES_score_sys.m` — **zef_ES_score_sys**: Zef ES score sys.
- `zef_ES_table.m` — **zef_ES_table**: Zef ES table.
- `zef_ES_optimization_update.m` — **zef_ES_update_parameter_values;**: Zef ES update parameter values;.
- `zef_ES_update_plot_data.m` — **zef_ES_update_plot_data**: Zef ES update plot data.
- `zef_ES_update_reconstruction.m` — **zef_ES_update_reconstruction**: Zef ES update reconstruction.
- `zef_cvx_linprog.m` — **zef_cvx_linprog**: Zef cvx linprog.
- `zef_cvx_quadprog.m` — **zef_cvx_linprog**: Zef cvx linprog.
- `zef_cvx_semidefprog.m` — **zef_cvx_linprog**: Zef cvx linprog.
- `zef_gurobi_linprog.m` — **zef_gurobi_linprog**: Zef gurobi linprog.
- `zef_mosek_linprog.m` — **zef_mosek_linprog**: Zef mosek linprog.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_ES_optimization_window**: GUI callback or dialog (`zef_ES_optimization_window`).
- **zef_ES_optimizer_properties**: GUI callback or dialog (`zef_ES_optimizer_properties`).
- **zef_ES_table**: GUI callback or dialog (`zef_ES_table`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `angles_list` from MATLAB with the project root on the path.`
- `Call `ell_idx` from MATLAB with the project root on the path.`
- `Call `ell_idx` from MATLAB with the project root on the path.`
- `Call `ell_idx` from MATLAB with the project root on the path.`
- `Call `if ismember(zef` from MATLAB with the project root on the path.`
- `Call `zef` from MATLAB with the project root on the path.`
- `Call `zef.h_ES_parameter_table` from MATLAB with the project root on the path.`
- ``[ell_idx] = zef_ES_4x1_sensors(varargin)` with project root and `src` on the path.`

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
