## Folder purpose

Helper for the **tES recursive hyperparameter search** study: shrink the alpha/epsilon lattice about the current best grid indices so the next search window is centered and refined.

## Main contents

| File | Role |
|------|------|
| `zef_ES_centralize_recursive_search.m` | Compute new `alpha_psi`, `epsilon_psi` lattices via `zef_ES_find_parameters` |

Parent study script: `../zef_ES_recursive_search.m`. ES algorithms: `tools/plugins/ZeffiroESWorkbench/m/`.

## Code functionality

**Inputs:** current `alpha`, `epsilon` vectors; best indices `(sr, sc)`; `original_window`; scale factors `s_alpha`, `s_epsilon`; optional `non_floating` flag (default clamp to original min/max).

**Outputs:** refined `alpha_psi`, `epsilon_psi` for the next recursive step.

Geometric window half-widths use `B_alpha = sqrt((max/min)*s_alpha)` (similarly for epsilon).

## Workflow context

```
zef_ES_recursive_search → evaluate objective on lattice
  → zef_ES_centralize_recursive_search → next lattice → repeat
```

Requires ES Workbench functions on path (`zef_ES_find_parameters`, current finders/optimizers).

## Usage instructions

```matlab
% Prefer running the parent study entry:
zef = examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice);

% Direct helper:
[a2, e2] = zef_ES_centralize_recursive_search(alpha, epsilon, sr, sc, ...
    original_window, s_alpha, s_epsilon, 1);
```

## Important notes

- Duplicate copies of this helper may exist at the study root — prefer the package `+helpers` path.
- Clamping (`non_floating=1`) prevents the window from leaving the original bounds.

## Developer guidance

- Keep the 8th-argument semantics documented; callers in ES Workbench may pass `0` to allow floating windows.
- When changing lattice generation, update `zef_ES_find_parameters` once for all callers.
