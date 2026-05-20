# src/sensitivity

## Folder purpose

**Bridge function** from interactive `zef` projects to Monte Carlo sensitivity analysis in `+utilities/+sensitivity` — probe stability of inverse solutions under noise and optional multires preflight.

## Main contents

| File | Role |
|------|------|
| `zef_sensitivity_run.m` | `[stats, run_result] = zef_sensitivity_run(zef, method_id, opts)` |

## Code functionality

Validates `zef.L` and `zef.source_positions`, may call `zef_make_multires_dec` for RAMUS/HALpR/GroupLasso capability checks, delegates to `utilities.sensitivity.run_monte_carlo` which repeatedly calls `zef_inverse_run`.

Returns aggregated statistics via `utilities.sensitivity.aggregate_statistics` — does not mutate `zef.reconstruction` in the main path.

## Workflow context

Called from `zef_inverse_pipeline_run` when sensitivity enabled. Study scripts (`+examples/+studies/+santtus_peeling_article`) use **legacy** `zef_sensitivity_map_*` helpers instead of this package.

## Usage instructions

```matlab
[stats, run] = zef_sensitivity_run(zef, 'mne', struct('n_mc', 50, 'execution', 'local'));
```

## Important notes

- Requires completed forward + inverse setup (L, sources, measurements).
- Cluster execution passes through opts to `zef_inverse_run`.
- Distinct from EIT sensitivity **plugin** (`tools/plugins/EITSensitivityTool`).

## Developer guidance

- Extend capability checks in `utilities.sensitivity.method_capability` when adding inverters.
- Keep opts schema aligned with `run_monte_carlo.m`.
