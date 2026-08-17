# `utilities.sensitivity` — Monte Carlo localization metrics

## Folder purpose

Synthesizes dipole-probe measurements from `zef.L`, runs `zef_inverse_run`, and scores peak location / angle / magnitude / dispersion. Used by studies that need method-comparison statistics without a GUI. Requires a session that already has `zef.L` (and source geometry). Does not mesh or assemble a lead field.

## Main contents

| Function | Role |
|----------|------|
| `method_capability` | Chooses strategy for a method id |
| `run_monte_carlo` | Noise realizations → inverse → per-run metrics |
| `synthesize_measurements` | Build `F` from `L` and probe indices |
| `compute_metrics` | Per-probe distance / angle / magnitude / dispersion / `max_ind` |
| `aggregate_statistics` | Mean/std across `runs` cells |

## Code functionality

`method_capability` strategies: `linear_static` (CSM/MNE/eLORETA), `iterative_static` (dipole scan, beamformer, IAS, RAMUS, HALpR), `stateful_dynamic` (Kalman), or `unsupported`. `run_monte_carlo` sets `zef_local.inv_data_mode = 'raw'` so each realization is a measurement matrix, not filtered EEG. Errors `MissingLeadField` if `zef.L` is empty.

`synthesize_measurements`: `L` must have **3 columns per source**. `SourceDirectionMode` 1 = three unit axes, 2 = normal (still 3 cols in `L`), 3 = one probe along `SourceDirections` (n_sources × 3). `compute_metrics` reconstruction cells must match probe count (3 per source unless mode 3).

## Workflow context

Feeds study scripts that compare inverse methods after a lead field exists. Can use `"execution","cluster"` when a cluster profile is supplied.

## Usage instructions

```matlab
cap = utilities.sensitivity.method_capability("eloreta");
results = utilities.sensitivity.run_monte_carlo(zef, "eloreta", ...
    "NumberOfRuns", 10, ...
    "NoiseLevelDb", -30, ...
    "DiffType", "L2", ...
    "DispersionRadius", 30, ...
    "SourceAmplitude", 10, ...
    "execution", "local");
stats = utilities.sensitivity.aggregate_statistics(results.runs);
```

Key `run_monte_carlo` options (defaults): `NumberOfRuns` 1; `NoiseLevelDb` -30 (`mustBeNonpositive`); `DiffType` `"L2"` or `"minabs"`; `DispersionRadius` 30 (same units as `zef.source_positions`); `SourceAmplitude` 10; `IsolatedFramesPerProbe` 4 (Kalman); `MaxProbesPerBatch` 1000; `MethodParams` `struct`; `execution` `"local"`; `SourceIndices` `procFile.s_ind_0`; optional `Capability` / `ProcFile` to skip recompute.

## Important notes

Does not replace GUI inverse plugins. Cluster path needs Parallel Computing Toolbox / configured profile.

## Developer guidance

When adding a method id, teach `method_capability` the correct strategy. Keep metric definitions stable so study aggregates remain comparable across checkouts.
