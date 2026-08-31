# plugins/ZeffiroESWorkbench/m

## Folder purpose

**tES electrode-current optimization**: choose currents `y` so the FEM map `zef.L` matches a target current density at `zef.inv_synth_source`. Results live in `zef.y_ES_interval`. This is **not** MEG/EEG inverse and is **not** registered in `inverse_method_registry` / `zef_inverse_run`. **Update reconstruction** only copies volumetric density into `zef.reconstruction` for mesh plotting.

## Main contents

| Group | Files |
|-------|--------|
| Start / UI | `zef_ES_optimization`, `_window`, `_init`, `_update`, `_init_parameter_table`, `_update_parameter_values` |
| Solve / HPO | `_find_currents`, `_find_currents_recursive`, `_optimize_current`, `_find_parameters`, `_recursive_search`, `_centralize_recursive_search`, `_objective_function`, `_table`, `_fix_active_electrodes`, `_rwnnz` |
| Solver backends | `zef_cvx_linprog`, `_quadprog`, `_semidefprog`, `zef_gurobi_linprog`, `zef_mosek_linprog` (+ MATLAB `linprog`/`quadprog` handles) |
| Plot / display | `_update_reconstruction`, `_plot_data`, `_plot_current_pattern`, `_plot_barplot`, `_plot_error_chart`, `_plot_distance_curves`, `_optimizer_properties`, `_optimizer_properties_show`, `zef_lattice_deviation` |

Layouts: `mlapp/zef_ES_optimization_app.mlapp`, `zef_ES_optimizer_properties_app.mlapp`.

## Code functionality

1. Requires `zef.L`, `zef.source_positions`, ≥1 row `zef.inv_synth_source` (position, orientation, density).
2. HPO 1: α/ε grid → `zef_ES_optimize_current` (LP L1L1 / SDP L1L2 / LS / backprop / QP L2L2).
3. Enforces zero-sum currents; caps `ES_total_max_current`, `ES_max_current_channel`.
4. Writes `y_ES_interval` (`y_ES`, volumetric density, residuals, nnz, field metrics, α/ε).
5. HPO 2: recursive search, then fix active electrodes and search again.

## Workflow context

- Menu: **Inverse tools → ES Workbench** (`ES Workbench,inverse_tools,zef_ES_optimization`).
- Sibling study package: `+examples/+studies/+tES_hyperparameter_optimization` (different `zef_ES_recursive_search` signature — **name clash** when both are on the path).
- Display sink: `zef_plot_meshes` after Update reconstruction.

## Usage instructions

```matlab
% Mesh + lead field + synthetic target sources first
zef_ES_optimization;   % opens workbench
% Tune solver / α–ε / current limits → Find currents → Update reconstruction → Plot data
```

## Important notes

- Density in `zef.reconstruction` is a **stimulation field**, not a neural inverse estimate.
- Plugin vs examples `zef_ES_recursive_search` — unqualified calls resolve by path order.
- Optional Gurobi / CVX / MOSEK; optimize may `addpath(genpath('external'))`.
- `zef_ES_update_reconstruction(zef)` with one argument hits an `otherwise` error; GUI uses nargin 0.

## Developer guidance

- Keep solver math in `_optimize_current` / objective; keep UI tables in init/update.
- When changing recursive search, update the examples package or rename one side to end the clash.
- Pitfall: treating ES Workbench results as EEG/MEG reconstructions in downstream inverse metrics.
