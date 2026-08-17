## Folder purpose

Published-style driver that repeatedly solves the ES Workbench current-optimization problem on a shrinking α/ε lattice. Does not mesh, does not build `zef.L`, and is not `zef_inverse_run`.

## Main contents

| File / folder | Role |
|---------------|------|
| `zef_ES_recursive_search.m` | Study entry `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice)` |
| `+helpers/` | Packaged `zef_ES_centralize_recursive_search` |

## Code functionality

tES here means: choose electrode currents `y` so FEM map `zef.L` produces desired current density at `zef.inv_synth_source`. The workbench grids hyperparameters (α, ε), solves a program at each node, stores patterns in `zef.y_ES_interval`. Recursive search recentres that grid around the best node.

**Two implementations (do not mix):**

| Call | File | Used by |
|------|------|---------|
| `zef_ES_recursive_search(zef, num_lattice, recursive_instances)` | `tools/plugins/ZeffiroESWorkbench/m/zef_ES_recursive_search.m` | GUI HPO method 2 |
| `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice)` | this folder | Study only (two args) |

Study sets `zef.ES_step_size = num_lattice`, uses hard-coded window of 40, calls `helpers.zef_ES_centralize_recursive_search`. Each pass after the first: `zef_ES_objective_function` → best `(sr, sc)` → helper shrinks α/ε (8th arg `0` = allow window outside original min/max) → `zef_ES_find_currents(...)`. Shrinkage:

```text
s_alpha  = (min(alpha)/max(alpha))^((adapt_window-1)/(adapt_window*adapt_instances))
```

with `adapt_window = 40`, `adapt_instances = num_lattice`. Result: `zef.adapted_y_ES` (cell, one `y_ES_interval` per pass).

## Workflow context

Requires a Zeffiro session with TES/EEG lead field, synthetic target sources, and ES Workbench functions on the path. GUI path (plugin, not this folder): mesh + `zef.L` → **Inverse tools → ES Workbench** → Find currents (HPO method 1 = single find; method 2 = plugin recursive).

## Usage instructions

```matlab
zef = examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice);
```

Always use the `examples.studies…` prefix; bare `zef_ES_recursive_search` resolves to the **plugin** via `genpath` on `tools/plugins`.

## Important notes

Helper in `+helpers/` is a copy of the plugin helper. Plugin recursive search calls the plugin helper (no package prefix); this study calls the packaged helper. Workbench manual: `tools/plugins/ZeffiroESWorkbench/README.md`.

## Developer guidance

Never rename the study function to collide with the plugin without package qualification. Keep shrinkage-factor documentation in sync with the plugin’s `num_lattice` / `recursive_instances` semantics.
