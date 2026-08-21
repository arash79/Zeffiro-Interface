# tools/plugins/ZeffiroESWorkbench

## Folder purpose

Optimizes **tES electrode currents** so the FEM lead field `zef.L` produces a target current density at synthetic source locations (`zef.inv_synth_source`). This is **not** MEG/EEG inverse. Results go to `zef.y_ES_interval` (currents `y_ES`, volumetric density, residuals). **Update reconstruction** copies a density volume into `zef.reconstruction` for mesh plotting.

## Main contents

Workbench window and solvers under `m/` (find currents, recursive search, update reconstruction, plot data, parameter update, active electrodes). Optional solver packages: MATLAB `linprog`/`quadprog`, Gurobi, CVX, MOSEK (optional folders). App Designer layout under `mlapp/`.

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

HPO search method **2** (`zef_ES_find_currents_recursive`) calls **this folder’s** `zef_ES_recursive_search(zef, num_lattice, recursive_instances)` then a second pass with fixed electrodes. That is not the two-argument study function `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search`. Because `tools/plugins` is on the path, an unqualified `zef_ES_recursive_search` is the workbench file.

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
