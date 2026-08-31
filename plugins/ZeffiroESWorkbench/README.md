## Folder purpose

Optimizes **tES electrode currents** so the FEM lead field `zef.L` produces a target current density at synthetic source locations (`zef.inv_synth_source`). This is **not** MEG/EEG inverse. Results go to `zef.y_ES_interval` (currents `y_ES`, volumetric density, residuals). **Update reconstruction** copies a density volume into `zef.reconstruction` for mesh plotting.

## Main contents

Workbench window and solvers under `m/` (see `m/README.md` for the full file map). App Designer layouts under `mlapp/`.

| Group | Files under `m/` |
|-------|-------------------|
| Start / UI | `zef_ES_optimization`, `_window`, `_init`, `_update`, `_init_parameter_table`, `_update_parameter_values` |
| Solve / HPO | `_find_currents`, `_find_currents_recursive`, `_optimize_current`, `_find_parameters`, `_recursive_search`, `_centralize_recursive_search`, `_objective_function`, `_table`, `_fix_active_electrodes`, `_rwnnz` |
| Solver backends | `zef_cvx_linprog`, `_quadprog`, `_semidefprog`, `zef_gurobi_linprog`, `zef_mosek_linprog` (plus MATLAB `linprog`/`quadprog`) |
| Plot / display | `_update_reconstruction`, `_plot_data`, `_plot_current_pattern`, `_plot_barplot`, `_plot_error_chart`, `_plot_distance_curves`, `_optimizer_properties`, `_optimizer_properties_show`, `zef_lattice_deviation` (2-D Taylor score of α/ε tables) |

Optional numeric backends: MATLAB Optimization Toolbox, Gurobi, CVX (`external/CVX` + SDPT3/SeDuMi), MOSEK.

## Code functionality

Needs `zef.L`, `zef.source_positions`, and at least one row of `zef.inv_synth_source` (position + orientation).

Buttons (`ButtonPushedFcn` in `m/zef_ES_optimization_window.m`):

| Handle | Action |
|--------|--------|
| **Find currents** | confirm dialog; if HPO search method == 1 → `zef_ES_find_currents(zef)`, if 2 → `zef_ES_find_currents_recursive(zef)` |
| **Update reconstruction** | `zef_ES_update_reconstruction` then `zef_plot_meshes` — `zef.reconstruction = y_ES_interval.volumetric_current_density{sr,sc}` from the objective-function indices |
| **Plot data** | `zef_ES_plot_data` |

Right-click on plot: current pattern, bar plot, error chart, optimizer properties, distance curves. Parameter table edits run `zef_ES_optimization_update`. Fixed-electrodes checkbox → `zef.ES_active_electrodes = zef_ES_fix_active_electrodes(zef)`.

`zef_ES_find_currents` grids α/ε (`zef_ES_find_parameters`), calls `zef_ES_optimize_current` (LP / QP / SDP search methods), stores `zef.y_ES_interval`. Recursive search wraps the same optimizer.

HPO search method **2** (`zef_ES_find_currents_recursive`) calls **this folder’s** `zef_ES_recursive_search(zef, num_lattice, recursive_instances)` then a second pass with fixed electrodes. That is not the two-argument study function `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search`. Because `plugins` is on the path, an unqualified `zef_ES_recursive_search` is the workbench file.

## Workflow context

**Inverse tools → ES Workbench** (default profile). Callback: `zef_ES_optimization` → `zef_tool_start(..., 'zef_ES_optimization_window', ...)`.

## Usage instructions

```matlab
zef = zef_ES_find_currents(zef);
zef = zef_ES_update_reconstruction(zef);

% Same family as HPO method 2 (plugin implementation):
zef = zef_ES_recursive_search(zef, zef.ES_step_size, zef.ES_HPO_recursive_instances);
```

Study wrapper with a different signature: `+examples/+studies/+tES_hyperparameter_optimization/`.

1. Set synthetic target sources and lead field.
2. Find currents (HPO method 1 or 2).
3. Update reconstruction and/or plot data.

## Important notes

- Not an MEG/EEG inverse solver; outputs electrode currents and volumetric density.
- Unqualified `zef_ES_recursive_search` resolves to this plugin, not the examples study function.
- Optional external solvers (Gurobi / CVX / MOSEK) live in optional folders.

## Developer guidance

Preserve callback `zef_ES_optimization` and the distinction between plugin `zef_ES_recursive_search` and the examples-study signature. Keep `zef.y_ES_interval` as the primary result container.
