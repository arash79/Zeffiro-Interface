# +inverse — class-based EEG/MEG inverse solvers

The inverse problem here is: given a lead field `zef.L` and measurements `y`, recover a source vector `x` such that

```
zef.L * x  ≈  y
```

`zef.L` maps source amplitudes at interpolated brain nodes (often three Cartesian columns per node) to sensor readings. `y` is `zef.measurements` after optional band-pass and frame averaging. The reconstruction is written to `zef.reconstruction` (cell, one vector per time frame) and a small metadata struct to `zef.reconstruction_information`.

This folder holds the **class** solvers. Each `@*Inverter` inherits `inverse.CommonInverseParameters` and implements at least `invert`. Some also implement `initialize` (priors / noise from data), `precompute` (frame-independent operator), `smoother` (Kalman RTS), and `terminateComputation` (clear auto-estimated caches).

## Two tracks

| Track | How you run it | What it calls |
|-------|----------------|---------------|
| **GUI Inverse tools** | Menus from `profile/*/zeffiro_plugins.ini` | Legacy functions in `tools/plugins/` (`zef_CSM_iteration`, `zef_KF`, `zef_ias_iteration`, …). **Not** these classes. |
| **Class / cluster** | `zef_inverse_run(zef, method_id, …)` | `utilities.cluster.inverse_method_registry` → `utilities.cluster.dispatch_inverse` → `utilities.inverse.run_frame_loop` → `inverse.*Inverter` |

There is no Inverse-tools button in the default profiles that constructs an `inverse.*Inverter`. Use `zef_inverse_run` or `computeInversionWithZI` for the class path. `+tests/ClassVsLegacyTest.m` compares `dspm` vs `legacy_csm`.

A third, in-process class entry is `inv.computeInversionWithZI(zef)`, which calls `zef_process_inversion` (same frame loop, original `zef.inv_data_mode` rather than the bundle's already-framed `raw` data).

## `initialize` / `precompute` / `invert`

`utilities.inverse.run_frame_loop` (used by both `zef_inverse_run` and `zef_process_inversion`):

1. Filter/normalize measurements (`zef_getFilteredDataClassObj`).
2. If the class has **`initialize`**: call `initialize(L, f_data)` once with all framed columns (or `zef.inverse_initialization_measurements` if set). Typical work: SNR → noise covariance, prior scale `theta0`.
3. If the class has **`precompute`**: call `precompute(L)` or `precompute(L, procFile)` once. Typical work: cache `W` / `P` / per-source SVDs.
4. For each frame: extract `f`, then **`invert(f, L, procFile, source_direction_mode, source_positions, …)`**. Kalman carries `prev_step_reconstruction` across frames.
5. Optional Kalman **`smoother`**, then **`terminateComputation`**, optional peak-norm of `z_inverse`, then `zef_postProcessInverseClassObj` → `zef.reconstruction`.

`CommonInverseParameters.REQUIRED_METHODS` is only `"invert"`. Missing `initialize`/`precompute` is fine.

## How to call `zef_inverse_run`

```matlab
% After zef.L, source interpolation, and zef.measurements exist:
[zef, run_result] = zef_inverse_run(zef, "eloreta", "execution", "local");

% Variant algorithms live on class properties, not on the registry id:
[zef, run_result] = zef_inverse_run(zef, "sloreta", "execution", "local", ...
    "MethodParams", struct("method_type", "sLORETA"));

% Direct object (skips the registry; still needs L + measurements):
inv = inverse.ELORETAInverter("regularization_parameter", 1e-2);
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);
```

`method_id` is case-insensitive. The registry maps an id to a **class** (or a legacy plugin function). It does **not** set `method_type`. Defaults apply unless you pass `MethodParams` fields that exist as properties on that class.

### Class registry ids (`utilities.cluster.inverse_method_registry`)

| Ids | Class | Default `method_type` / notes |
|-----|-------|-------------------------------|
| `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` | `inverse.CSMInverter` | `"dSPM"`. Pass `method_type` `"sLORETA"`, `"sLORETA 3D"`, or `"SBL"` for the others. |
| `mne`, `wmne` | `inverse.MNEInverter` | Always weighted MNE via `theta`; ids are aliases. |
| `eloreta` | `inverse.ELORETAInverter` | Fixed-point eLORETA. |
| `kalman`, `kf` | `inverse.KalmanInverter` | `"Basic Kalman filter"`. Other types via `MethodParams.method_type`. |
| `beamformer` | `inverse.BeamformerInverter` | `"Linearly constrained minimum variance (LCMV) beamformer"`. |
| `dipolescan`, `dipole_scan` | `inverse.DipoleScanInverter` | `"SVD"`. |
| `ias` | `inverse.IASInverter` | IAS MAP; `method_type` is optional post-hoc dSPM/sLORETA. |
| `ramus` | `inverse.RAMUSInverter` | Needs `make_multires_dec` (or sensitivity preflight) first. |
| `grouplasso`, `group_lasso` | `inverse.GroupLassoInverter` | `"IAS"` estimation; constructor currently forces `use_multiresolution = false`. |
| `halpr` | `inverse.HALpRInverter` | Same pattern as Group LASSO; `q` is 1 or 2. |

Legacy ids (`legacy_csm`, `legacy_mne`, `legacy_kalman`, `legacy_ias`, `legacy_ramus`, `legacy_dipolescan`, `legacy_beamformer`, `legacy_sl1`, `legacy_relax`, `legacy_sesame`, `legacy_hb` / `legacy_mcmc`, `legacy_music`, `legacy_rap_music`, `legacy_exp`) dispatch plugin functions, not these classes.

Unknown ids error with `utilities.cluster:UnknownInverseMethod`.

## Required `zef` fields

Minimum for `zef_inverse_run` / `zef_inverse_extract_bundle`:

| Field | Role |
|-------|------|
| `zef.L` | Lead field (sensors × source columns). |
| `zef.measurements` | `y` (sensors × time). |
| `zef.source_interpolation_ind` | From `zef_source_interpolation` after the forward run. |
| `zef.source_positions`, `zef.source_direction_mode`, `zef.source_directions` | Source grid / orientation mode (1 free, 2 constrained, 3 fixed). |
| `zef.inv_snr` | SNR in dB; classes convert to noise power `10^(-SNR/10)` or std `10^(-SNR/20)`. There is no separate `zef.noise` field on this path. |
| `zef.inv_low_cut_frequency`, `zef.inv_high_cut_frequency`, `zef.inv_sampling_frequency` | Band-pass when `inv_data_mode` is `"filtered_temporal"`. |
| `zef.inv_time_1`, `inv_time_2`, `inv_time_3` | Start, window, step (seconds) → frames. |
| `zef.number_of_frames` | How many columns `invert` is called with. |
| `zef.normalize_data` | 1–4 → `"Maximum entry"` / column-norm options / `"None"`. |
| `zef.inv_data_mode` | `"raw"` or `"filtered_temporal"`. Bundle dispatch then re-runs frames as `"raw"`. |
| `zef.use_gpu`, `zef.gpu_count` | Optional GPU. |

`withPropertiesFromZef` copies the `inv_*` / frame fields onto the inverter. Optional: `zef.inverse_initialization_measurements` as the `initialize` data matrix.

## What is written

- `zef.reconstruction` — cell of full-grid source vectors (`zef_postProcessInverseClassObj`).
- `zef.reconstruction_information` — `tag` plus scalar inverter properties.
- `run_result` also has `z_inverse` (reduced-grid cell before scatter) and, on cluster runs, `cluster_summary`.

## Shared class: `CommonInverseParameters`

Properties: band edges, `data_normalization_method`, `number_of_frames`, `sampling_frequency`, `time_start` / `time_window` / `time_step`, `signal_to_noise_ratio` (dB), `normalize_reconstruction`, `GMM`.

Public methods: `withPropertiesFromZef`, `computeGMM` (delegates to `plugins.ClassGMM.ClassGMModeling`), `computeInversionWithZI`, static `isAnInverter` / `substituteCommonInverseParameters`.

## Kalman process noise Q (including DTI)

`inverse.KalmanInverter` builds `evolution_cov` from `evolution_prior_model` (`"Sensitivity scaling"`, `"Avg. sensit. scaling"`, `"SVD-based"`, `"Avg. SVD-based"`, `"Reworked original"`, `"User supplied Q"`). DTI structural Q (`zef_dti_structural_Q`, `zef.kf_structural_Q_type`) is used by **legacy** `zef_KF` only. On the class path, pass a precomputed Q as

```matlab
zef_inverse_run(zef, "kalman", "MethodParams", struct( ...
    "evolution_prior_model", "User supplied Q", ...
    "evolution_cov", Q));
```

`Q` must be `size(L,2)`-by-`size(L,2)` for the processed lead field.

## Examples and tests

- `+utilities/+cluster/+examples/eloreta_workflow.m`, `kalman_workflow.m`
- `+tests/ELORETAInverterTest.m`, `ELORETADispatchTest.m`, `InverseDispatchTest.m`, `ClassVsLegacyTest.m`
- `+examples/+inverse/zef_KalmanDemo.m` still calls legacy `zef_KF`, not this class

## Developer notes

- New solver: `@FooInverter` inheriting `CommonInverseParameters`, register ids in `+utilities/+cluster/inverse_method_registry.m`, call via `zef_inverse_run`. Do not add another per-frame loop.
- `precompute` is optional; `run_frame_loop` tries `(L, procFile)` then falls back to `(L)`.
- RAMUS/GroupLasso/HALpR multiresolution uses `zef_make_multires_dec`. RAMUS errors if `multiresolution_dec` is empty. GroupLasso/HALpR `make_multires_dec` currently names properties that those classes do not define (`number_of_decompositions`, …).
- Numerical cores for Kalman: `+plugins/+ClassKF`. Group LASSO / HALpR call `LG_optimization` / `L1_optimization` (EXP helpers on the path).
