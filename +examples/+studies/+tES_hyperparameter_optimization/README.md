# tES hyperparameter recursive search (study script)

This folder is a **published-style driver** that repeatedly solves the ES Workbench current-optimization problem on a shrinking α/ε lattice. It does not mesh, does not build `zef.L`, and is not `zef_inverse_run`. You must already have a Zeffiro session with a TES/EEG lead field, synthetic target sources, and the ES Workbench functions on the path.

tES (transcranial electrical stimulation) here means: choose electrode currents `y` so the FEM map `zef.L` produces a desired current density at `zef.inv_synth_source`. The workbench grids two hyperparameters (α, ε), solves a linear/quadratic program at each node, and stores the current patterns in `zef.y_ES_interval`. Recursive search then recentres that grid around the best node.

## Two implementations (do not mix them)

| Call | File | Used by |
|------|------|---------|
| `zef_ES_recursive_search(zef, num_lattice, recursive_instances)` | `tools/plugins/ZeffiroESWorkbench/m/zef_ES_recursive_search.m` | GUI: Inverse tools → **ES Workbench** → **Find currents** when HPO search method == 2 (`zef_ES_find_currents_recursive`) |
| `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice)` | this folder | Study script only. Two arguments. Sets `zef.ES_step_size = num_lattice`, uses a hard-coded window of 40, and calls `helpers.zef_ES_centralize_recursive_search` |

Because `tools/plugins` is on `genpath`, the name `zef_ES_recursive_search` without a package prefix is the **plugin** function. Always use the `examples.studies…` prefix for this study file.

The helper in `+helpers/` is likewise a copy of `tools/plugins/ZeffiroESWorkbench/m/zef_ES_centralize_recursive_search.m`. The plugin recursive search calls the plugin helper (no package prefix). This study calls the packaged helper.

## GUI path (plugin, not this folder)

1. Mesh + TES/EEG lead field (`zef.L`), interpolation, at least one synthetic source row (`zef.inv_synth_source`).
2. **Inverse tools → ES Workbench** (`zef_ES_optimization`).
3. Fill the parameter table (α/ε bounds, caps, lattice). **Find currents** with HPO search method **1** is a single `zef_ES_find_currents`. Method **2** is the plugin two-stage recursive search (unfixed electrodes, then fixed).
4. **Update reconstruction** copies `y_ES_interval.volumetric_current_density{sr,sc}` into `zef.reconstruction`.

Workbench manual: [`tools/plugins/ZeffiroESWorkbench/README.md`](../../../tools/plugins/ZeffiroESWorkbench/README.md).

## Study script

```matlab
% zef already configured: ES tool open or zef.ES_* fields set, L and synth sources exist.
zef = examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice);
% num_lattice → zef.ES_step_size and the number of refinement passes
% result: zef.adapted_y_ES  (cell, one y_ES_interval per pass)
```

Each pass after the first: `zef_ES_objective_function` → best indices `(sr, sc)` → helper shrinks α/ε (eighth argument `0` = allow the window outside the original min/max) → `zef_ES_find_currents(zef, alpha_psi, epsilon_psi, original_window)`.

Shrinkage factors in this study file:

```text
s_alpha  = (min(alpha)/max(alpha))^((adapt_window-1)/(adapt_window*adapt_instances))
```

with `adapt_window = 40` and `adapt_instances = num_lattice`. The plugin version uses `num_lattice` in both the exponent and `zef_ES_find_parameters`, and a separate `recursive_instances` count.

## Helper

[`+helpers/README.md`](+helpers/README.md) — `zef_ES_centralize_recursive_search`.
