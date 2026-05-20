# src/inverse

## Folder purpose

**Inverse orchestration** between the `zef` project struct and solvers. This folder does **not** implement reconstruction algorithms (those live in `+inverse/@*Inverter` and `tools/plugins/*`). It prepares lead fields, filters measurements, runs the class-based frame loop, extracts cluster bundles, and maps results back to `zef.reconstruction`.

## Main contents

| File | Role |
|------|------|
| `zef_processLeadfields.m` | Subset/reorient `zef.L` using `source_interpolation_ind` and `source_direction_mode`; build `procFile` index bundle |
| `zef_getFilteredData.m` / `zef_getFilteredDataClassObj.m` | Band-pass filter and normalize `zef.measurements` |
| `zef_getTimeStep.m` / `zef_getTimeStepClassObj.m` | Extract per-frame measurement column(s); class path always `mean` over window |
| `zef_process_inversion.m` | Full in-process class pipeline → `utilities.inverse.run_frame_loop` → post-process |
| `zef_postProcessInverse.m` | Legacy: scatter frame vectors to full lead-field column layout |
| `zef_postProcessInverseClassObj.m` | Class path post-process using `procFile.s_ind_0` triplet layout |
| `zef_normalizeInverseReconstruction.m` | Max-norm scaling across frames |
| `zef_inverse_extract_bundle.m` | Serialize `L`, `F`, `procFile`, params for cluster/local dispatch |
| `zef_inverse_run.m` | One-line wrapper: bundle → `utilities.cluster.dispatch_inverse` |
| `zef_inverse_pipeline_run.m` | Multi-method batch driver + optional sensitivity |
| `zef_compute_measurements.m` | Synthetic `zef.measurements = L * s` for testing |
| `zef_inverse_gamma_gpu.m` | Inverse-gamma PDF helper for hyperprior GUIs |

## Code functionality

**Shared gate:** almost every inverse path starts with `zef_processLeadfields`, which requires a prior forward lead field (`zef.L`) and `zef.source_interpolation_ind` from `zef_source_interpolation`.

**Class pipeline:**
```
zef_processLeadfields → run_frame_loop (utilities.inverse)
  → initialize / precompute / invert per frame
  → zef_postProcessInverseClassObj → zef.reconstruction
```

**Legacy plugin pipeline** (dominant in GUI today):
```
zef_processLeadfields → zef_getFilteredData → zef_getTimeStep (per frame)
  → plugin *_iteration → zef_postProcessInverse → zef.reconstruction
```

**Cluster/programmatic:**
```matlab
[zef, result] = zef_inverse_run(zef, "eloreta", "execution", "local");
```

Registry IDs and class/legacy mapping live in `+utilities/+cluster/inverse_method_registry.m`.

## Workflow context

| Consumer | Functions used |
|----------|----------------|
| `+inverse` classes via `computeInversionWithZI` | `zef_process_inversion` |
| `+utilities/+cluster/dispatch_inverse` | bundle fields from `zef_inverse_extract_bundle` |
| `+tests/*`, `+examples`, sensitivity | `zef_inverse_run`, `zef_inverse_pipeline_run` |
| GUI plugins (MNE, IAS, RAMUS, CSM, …) | `zef_processLeadfields`, `zef_getFilteredData`, `zef_getTimeStep`, `zef_postProcessInverse` |

`zeffiro_interface.m` does **not** call this folder directly; inversion runs after mesh + lead field + measurement import.

## Usage instructions

```matlab
% Programmatic class inverse (after zef.L and measurements exist)
[zef, out] = zef_inverse_run(zef, "mne", "execution", "local");

% Direct class object
inv = inverse.ELORETAInverter();
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);

% Synthetic data for testing
zef = zef_compute_measurements(zef);
[zef, r] = zef_inverse_run(zef, "dspm");
```

## Important notes

- **Two parallel architectures:** legacy plugins vs class dispatch; `ClassVsLegacyTest` verifies parity for CSM.
- **`zef_getTimeStepClassObj` differs from `zef_getTimeStep`:** class path always averages columns in the time window.
- **`computeInversionWithZI`** on `inverse.CommonInverseParameters` has no GUI callers yet — plugins still use legacy `*_iteration` functions.
- RAMUS/GroupLasso/HALpR need multiresolution decomposition (`zef_make_multires_dec`) before inversion.

## Developer guidance

- New inverse methods: implement in `+inverse`, register in `inverse_method_registry`, call via `zef_inverse_run` — do not add another per-frame loop here.
- Changes to `procFile` layout must update both `zef_postProcessInverse` and `zef_postProcessInverseClassObj`.
- Keep `zef_inverse_extract_bundle` in sync with cluster worker `run_inverse_job.m`.
- When migrating a plugin to the class API, add a `ClassVsLegacyTest`-style check before removing the legacy entry.
