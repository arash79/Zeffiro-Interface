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

`method_capability(method_id)` returns a struct with `strategy`, optional `prep_hooks`, and `notes`. `run_monte_carlo` sets `zef_local.inv_data_mode = 'raw'` so each realization is a measurement matrix, not filtered EEG. Errors `MissingLeadField` if `zef.L` is empty.

| Strategy | Registry ids | Monte Carlo behaviour |
|----------|----------------|------------------------|
| `linear_static` | `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl`, `mne`, `wmne`, `eloreta` | Cached linear operator; bounded probe batches |
| `iterative_static` | `dipolescan` / `dipole_scan`, `beamformer`, `ias`, `ramus` (`prep_hooks`: `ramus_decomposition`), `halpr`, `grouplasso` / `group_lasso` | Per-frame / per-source iterations; RAMUS auto-builds multires if empty |
| `stateful_dynamic` | `kalman`, `kf` | One probe per frame with a **fresh** inverter (state must not leak across probes) |
| `unsupported` | All `legacy_*` ids; `ukfnmm` / `ukf_nmm`; anything else | Falls through to `otherwise`. Use the class-based equivalent from `utilities.cluster.inverse_method_registry`. |

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

Does not replace GUI inverse plugins. Cluster path needs Parallel Computing Toolbox / configured profile. UKFNMM and every `legacy_*` id are **unsupported** here — `method_capability` will not invent a batching strategy for them.

## Developer guidance

When adding a method id, teach `method_capability` the correct strategy. Keep metric definitions stable so study aggregates remain comparable across checkouts.
