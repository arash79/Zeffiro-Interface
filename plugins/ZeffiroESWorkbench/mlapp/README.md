# plugins/ZeffiroESWorkbench/mlapp

## Folder purpose

App Designer shells for **ES Workbench** (tES electrode-current optimization). Widgets bind to `zef.ES_*` fields. Solver math, HPO, CVX/Gurobi/MOSEK wrappers, and plot helpers live in `../m/`. This is **not** EEG/MEG inverse.

## Main contents

| File | Role |
|------|------|
| `zef_ES_optimization_app.mlapp` | Main workbench: parameter `uitable`, Find currents, Update reconstruction, Plot data, HPO method, solver dropdowns, α/ε / current-limit edits |
| `zef_ES_optimizer_properties_app.mlapp` | Detail view opened from plot context → optimizer properties (`zef_ES_optimizer_properties_show`) |

Runtime wiring is **not** inside the `.mlapp` callbacks as the source of truth: `m/zef_ES_optimization_window.m` copies handles onto `zef.h_*` and sets `ButtonPushedFcn`.

## Code functionality

| UI action (main app) | Implementation in `../m/` |
|----------------------|---------------------------|
| **Find currents** | HPO method 1 → `zef_ES_find_currents`; method 2 → `zef_ES_find_currents_recursive` |
| **Update reconstruction** | `zef_ES_update_reconstruction` then `zef_plot_meshes` — copies `y_ES_interval.volumetric_current_density{sr,sc}` into `zef.reconstruction` for display |
| **Plot data** | `zef_ES_plot_data` |
| Parameter table edit | `zef_ES_optimization_update` / `zef_ES_update_parameter_values` |
| Fixed-electrodes checkbox | `zef.ES_active_electrodes = zef_ES_fix_active_electrodes(zef)` |
| Plot context menu | current pattern, bar plot, error chart, optimizer properties, distance curves |

Column order of the parameter table must stay aligned with `zef_ES_init_parameter_table`.

## Workflow context

**Inverse tools → ES Workbench** → `zef_ES_optimization` → these apps → `zef.y_ES_interval` (currents). Optional density in `zef.reconstruction` is a **stimulation field**, not a neural inverse estimate.

## Usage instructions

```matlab
zef_ES_optimization;   % opens the main mlapp via zef_ES_optimization_window
```

Requires `zef.L`, `zef.source_positions`, and at least one `zef.inv_synth_source` row. After Find currents, use Update reconstruction and/or Plot data.

## Important notes

- Not EEG/MEG inverse. Full solver notes: `../m/README.md` and `../README.md`.
- Optional CVX (`external/CVX` + SDPT3/SeDuMi), Gurobi, or MOSEK depending on the selected search method.
- Unqualified `zef_ES_recursive_search` is this plugin’s function, not `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search`.
- `zef_ES_update_reconstruction(zef)` with one argument hits an `otherwise` error; the GUI uses `nargin == 0`.

## Developer guidance

- Keep table column order in sync with `zef_ES_init_parameter_table`.
- Add buttons in the mlapp **and** wire them in `zef_ES_optimization_window.m`.
- Pitfall: confusing the study-package `zef_ES_recursive_search` with the plugin function of the same name.
