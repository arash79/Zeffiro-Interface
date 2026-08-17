# tools/plugins/ZeffiroESWorkbench/mlapp

## Folder purpose

App Designer UIs for **ES Workbench** (tES current optimization). Solver math and HPO live in `../m`.

## Main contents

| File | Role |
|------|------|
| `zef_ES_optimization_app.mlapp` | Main workbench (parameter table, Find currents, plots) |
| `zef_ES_optimizer_properties_app.mlapp` | Optimizer properties / detail view |

## Code functionality

Widgets bind to `ES_*` fields via `zef_ES_optimization_window` / init / update scripts. Find currents triggers `zef_ES_find_currents` / recursive HPO in `m/`.

## Workflow context

Inverse tools → ES Workbench → these apps → `zef.y_ES_interval` (stimulation currents), optional density into `zef.reconstruction` for display only.

## Usage instructions

```matlab
zef_ES_optimization;
```

## Important notes

- Not EEG/MEG inverse; see `../m/README.md`.
- Optional CVX/Gurobi/MOSEK for some methods.

## Developer guidance

- Keep table column order in sync with `zef_ES_init_parameter_table`.
- Pitfall: confusing study-package `zef_ES_recursive_search` with the plugin’s function of the same name.
