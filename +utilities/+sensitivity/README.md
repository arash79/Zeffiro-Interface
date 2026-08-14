# `utilities.sensitivity` — Monte Carlo localization metrics

Synthesizes dipole-probe measurements from `zef.L`, runs `zef_inverse_run`, and scores peak location / angle / magnitude / dispersion. Used by studies that need method-comparison statistics without a GUI.

Requires a session that already has `zef.L` (and source geometry). Does not mesh or assemble a lead field.

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

## `run_monte_carlo`

| Option | Default | Meaning |
|--------|---------|---------|
| `NumberOfRuns` | 1 | Independent noise realizations |
| `NoiseLevelDb` | -30 | SNR for AWGN (`mustBeNonpositive`) |
| `DiffType` | `"L2"` | `"L2"` or `"minabs"` peak picking |
| `DispersionRadius` | 30 | Same units as `zef.source_positions` (typically mm) |
| `SourceAmplitude` | 10 | Probe scale |
| `IsolatedFramesPerProbe` | 4 | Stateful (Kalman) path |
| `MaxProbesPerBatch` | 1000 | Linear/static batching |
| `MethodParams` | `struct` | Forwarded to `zef_inverse_run` |
| `execution` | `"local"` | `"cluster"` needs `ClusterProfile` |
| `SourceIndices` | `procFile.s_ind_0` | Subset of sources |
| `Capability` / `ProcFile` | auto | Skip recompute if you already have them |

Errors `MissingLeadField` if `zef.L` is empty. Sets `zef_local.inv_data_mode = 'raw'` so each realization is a measurement matrix, not filtered EEG.

`method_capability` chooses strategy: `linear_static` (CSM/MNE/eLORETA), `iterative_static` (dipole scan, beamformer, IAS, RAMUS, HALpR), `stateful_dynamic` (Kalman), or `unsupported`.

## `synthesize_measurements`

`F = synthesize_measurements(L, source_indices, amp, noise_db, ...)`. `L` must have **3 columns per source**. `SourceDirectionMode` 1 = three unit axes, 2 = normal (still 3 cols in `L`), 3 = one probe along `SourceDirections` (n_sources × 3).

## `compute_metrics`

Per-probe `distance`, `angle`, `magnitude`, `dispersion`, `max_ind`. Reconstruction cells must match probe count (3 per source unless mode 3).

## `aggregate_statistics`

Mean/std across `runs` cells produced by `run_monte_carlo`.
