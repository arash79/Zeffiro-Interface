# src/inverse — inverse orchestration

This folder does **not** recover sources. The inverse problem `L x ≈ y` is solved in `+inverse/@*Inverter` (class path) or `tools/plugins` (GUI / legacy). Files here prepare `zef.L` and `zef.measurements`, loop frames, scatter results onto the full source grid, and expose `zef_inverse_run`.

## Two tracks (same as `+inverse/README.md`)

1. **GUI Inverse tools** — plugin `*_iteration` functions. They typically call `zef_processLeadfields`, `zef_getFilteredData`, `zef_getTimeStep`, then `zef_postProcessInverse`. They do **not** call `zef_inverse_run` or `computeInversionWithZI`.
2. **Programmatic class path** — `zef_inverse_run` → `zef_inverse_extract_bundle` → `utilities.cluster.dispatch_inverse` → `utilities.inverse.run_frame_loop` → class `initialize` / `precompute` / `invert` → `zef_postProcessInverseClassObj` → `zef.reconstruction`.

In-process class alternative: `zef_process_inversion` (from `CommonInverseParameters.computeInversionWithZI`).

## `zef_inverse_run`

```matlab
[zef, run_result] = zef_inverse_run(zef, method_id)
[zef, run_result] = zef_inverse_run(zef, method_id, Name, Value, ...)
```

Name-value options: `execution` (`"local"` default or `"cluster"`), `MethodParams` (struct copied onto inverter properties), `ClusterProfile` (required for cluster), `WorkDir`, `BundleDir`, `ResultDir`.

**Class ids** (from `utilities.cluster.inverse_method_registry`; aliases listed together). The id selects the class; pass `MethodParams.method_type` when the class default is not the algorithm you want:

| method_id | Class |
|-----------|--------|
| `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` | `inverse.CSMInverter` (default `method_type` `"dSPM"`) |
| `mne`, `wmne` | `inverse.MNEInverter` |
| `eloreta` | `inverse.ELORETAInverter` |
| `kalman`, `kf` | `inverse.KalmanInverter` |
| `beamformer` | `inverse.BeamformerInverter` |
| `dipolescan`, `dipole_scan` | `inverse.DipoleScanInverter` |
| `ias` | `inverse.IASInverter` |
| `ramus` | `inverse.RAMUSInverter` |
| `grouplasso`, `group_lasso` | `inverse.GroupLassoInverter` |
| `halpr` | `inverse.HALpRInverter` |

Legacy ids (`legacy_csm`, `legacy_mne`, `legacy_kalman`, …) are listed in `+utilities/+cluster/inverse_method_registry.m` and call plugin functions.

Writes `zef.reconstruction` and `zef.reconstruction_information` from `run_result`.

## Required `zef` fields / outputs

See `+inverse/README.md`. This folder additionally requires `zef.source_interpolation_ind` (error in `zef_processLeadfields` if missing). Noise enters as `zef.inv_snr` (dB), not a dedicated noise matrix, unless a class property `noise_cov` / `error_cov` is set via `MethodParams`.

## Files

| File | Role |
|------|------|
| `zef_inverse_run.m` | Bundle + local `dispatch_inverse` or cluster submit/collect |
| `zef_inverse_extract_bundle.m` | Serialize `L`, framed `F`, `procFile`, common params, `MethodParams` |
| `zef_processLeadfields.m` | Subset/reorient `zef.L`; build `procFile` (`s_ind_0`…`s_ind_4`, `n_interp`, `sizeL2`) |
| `zef_getFilteredData.m` | Legacy band-pass from `zef.inv_*` |
| `zef_getFilteredDataClassObj.m` | Same using `CommonInverseParameters` properties |
| `zef_getTimeStep.m` | Legacy per-frame columns |
| `zef_getTimeStepClassObj.m` | Class path: **always** `mean` over remaining columns in the window |
| `zef_process_inversion.m` | Full in-process class pipeline + optional Kalman smoother |
| `zef_postProcessInverse.m` | Legacy scatter using `procFile.s_ind_1` |
| `zef_postProcessInverseClassObj.m` | Class scatter using interleaved triplets from `s_ind_0` |
| `zef_normalizeInverseReconstruction.m` | Peak vector-norm scaling across frames |
| `zef_inverse_pipeline_run.m` | Batch `zef_inverse_run` / `zef_sensitivity_run` from a methods table |
| `zef_compute_measurements.m` | Synthetic `zef.measurements = L * s` (+ optional noise) |
| `zef_inverse_gamma_gpu.m` | Inverse-gamma PDF via `zef_gamma_gpu` |

## Bundle vs in-process filtering

`zef_inverse_extract_bundle` filters and frames using the **project** `zef.inv_data_mode`, then `dispatch_inverse` builds a shim with `inv_data_mode = 'raw'` and `measurements = F` (already one column per frame). `zef_process_inversion` keeps the original `zef.inv_data_mode` and lets `run_frame_loop` filter again.

For `source_direction_mode` 1 or 2, both extract_bundle and `zef_process_inversion` reorder `L` to node-wise `(x,y,z)` triplets before the inverter sees it.

## Usage

```matlab
[zef, out] = zef_inverse_run(zef, "mne", "execution", "local");

inv = inverse.ELORETAInverter();
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);

zef = zef_compute_measurements(zef, "sources", src, "sampling_frequency", 1000);
[zef, r] = zef_inverse_run(zef, "dspm");
```

## Developer notes

- New algorithms go in `+inverse` + the registry, not a new frame loop here.
- `procFile` layout changes must update both post-process functions.
- `zef_getTimeStepClassObj` always averages; `zef_getTimeStep` only averages when `inv_time_interval_averaging` is true.
- RAMUS/GroupLasso/HALpR still need a multiresolution decomposition before invert.
