# +inverse — class-based inverse solvers

Object-oriented EEG/MEG (and related) inverse solvers. Each `@*Inverter` implements at least `invert` and inherits band-pass, frames, and SNR handling from `inverse.CommonInverseParameters`.

This is the **programmable / cluster** track, also reached from Inverse-tools **(class solver)** dialogs. Other Inverse-tools menus still call **legacy** functions under `plugins/`. Both write `zef.reconstruction`. Why the methods exist mathematically: [docs/methods.md](../docs/methods.md).

Discovery is **not** a folder scan: `utilities.cluster.inverse_method_registry` maps string ids → class names.

## Main contents

| Item | Role | Registry ids |
|------|------|----------------|
| `CommonInverseParameters.m` | Base: band-pass, frames, SNR, `withPropertiesFromZef`, `computeInversionWithZI`, `computeGMM` | — |
| `+gmm/` | Reconstruction GMM (`inverse.gmm.*`) | via `computeGMM` / JL advanced Start |
| `+kf/` | Kalman predict/update kernels (`inverse.kf.*`) | used by Kalman / UKFNMM |
| `@CSMInverter` | dSPM / sLORETA / SBL | `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` |
| `@MNEInverter` | Weighted MNE | `mne`, `wmne` |
| `@ELORETAInverter` | eLORETA fixed-point | `eloreta` |
| `@KalmanInverter` | KF / sLORETA-KF / EnKF + RTS | `kalman`, `kf` |
| `@UKFNMMInverter` | Spatial KF + Jansen–Rit NMM + UKF | `ukfnmm`, `ukf_nmm` |
| `@BeamformerInverter` | LCMV / UNG / unit-gain | `beamformer` |
| `@DipoleScanInverter` | Dipole-scan GoF | `dipolescan`, `dipole_scan` |
| `@IASInverter` | IAS MAP | `ias` |
| `@RAMUSInverter` | RAMUS multires | `ramus` |
| `@GroupLassoInverter` | Group LASSO via `LG_optimization` | `grouplasso`, `group_lasso` |
| `@HALpRInverter` | Hierarchical Lp via `L1_optimization` | `halpr` |

**Legacy registry ids** (`execution_kind` `"legacy"` in the same registry; they `feval` a plugin function with `zef` in the base workspace — not these classes):

| Id | Plugin function |
|----|-----------------|
| `legacy_csm` | `zef_CSM_iteration` |
| `legacy_mne` | `zef_find_mne_reconstruction` |
| `legacy_kalman` | `zef_KF` |
| `legacy_ias` | `zef_ias_iteration` |
| `legacy_ramus` | `zef_ramus_iteration` |
| `legacy_dipolescan` | `zef_dipoleScan` |
| `legacy_beamformer` | `zef_beamformer` |
| `legacy_sl1` | `zef_sl1_iteration` |
| `legacy_relax` | `zef_relax_iteration` |
| `legacy_sesame` | `SESAME_inversion` |
| `legacy_hb` / `legacy_mcmc` | `zef_mcmc` |
| `legacy_music` | `MUSIC_iteration` |
| `legacy_rap_music` | `RAP_MUSIC_iteration` |
| `legacy_exp` | `exp_iteration` |

Full list: `utilities.cluster.inverse_method_registry`. GUI Inverse-tools buttons call those plugin functions **directly**, not via `legacy_*` ids.

## Code functionality

**Frame loop** (`utilities.inverse.run_frame_loop`):

1. Filter/normalize measurements  
2. Optional `initialize(L, f_data)`  
3. Optional `precompute(L[, procFile])`  
4. Per frame: `invert(f, L, procFile, …)`  
5. Optional `smoother` (Kalman RTS; UKFNMM RTS + NMM/UKF), `terminateComputation`, post-process → `zef.reconstruction`

**Base class:** `REQUIRED_METHODS = "invert"`; `computeInversionWithZI` → `zef_process_inversion`; `computeGMM` → `inverse.gmm`.

**Kalman note:** class Kalman does **not** implement DTI structural Q; that exists only on the legacy `plugins/Kalman` path (`zef_dti_structural_Q`). Pass a user `Q` via `MethodParams` if needed.

**UKFNMM note:** `inverse.UKFNMMInverter` is a separate class, not a Kalman filter type. Head profiles list Inverse tools → **UKF-NMM (class solver)** (`plugins/UKFNMM`, `zef_ukfnmm_start`). Spatial KF uses `inverse.kf.kf_update` on a per-source SVD-modified lead field; NMM/UKF runs once from `smoother`. See `@UKFNMMInverter/README.md`.

## Workflow context

| Track | Entry | Implementation |
|-------|-------|------------------|
| Class / cluster | `zef_inverse_run` → `dispatch_inverse` | `@*Inverter` here |
| Class-solver Inverse tools | **(class solver)** menus → `zef_open_class_inverse` → `zef_inverse_run` | same `@*Inverter` classes |
| Legacy GUI | other Inverse-tools menus | `plugins/*` iterations |
| Tests | `+tests` | ClassVsLegacy, ELORETA*, EndToEndSynthetic, ClassInverseDialog, … |

## Usage instructions

```matlab
[zef, run_result] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');
[zef, run_result] = zef_inverse_run(zef, 'dspm', ...
    'MethodParams', struct('method_type', 'sLORETA'), 'execution', 'local');
```

See each `@*Inverter/README.md` for constructor properties.

## Important notes

- `"sloreta"` / `"sbl"` may still construct CSM with default `method_type="dSPM"` unless `MethodParams.method_type` is set.
- Bundle path forces `inv_data_mode='raw'`; `computeInversionWithZI` does not.
- IAS/RAMUS last-step dSPM/sLORETA use `n_map_iterations` (per-level index for RAMUS).
- GroupLasso/HALpR need EXP optimizers on the path; RAMUS needs `multiresolution_dec`.
- `zef_inverse_run` copies band-pass / frames / SNR from `zef` via `withPropertiesFromZef` (`inv_sampling_frequency`, `inv_time_1/2/3`, `inv_snr`, …). That method **always** sets `normalize_reconstruction = false` (it does not read a `zef` flag). Constructing `inverse.CommonInverseParameters()` uses classdef defaults (`sampling_frequency` **1025** Hz, `time_step` 1 s). `inverse.MNEInverter()` currently passes **1024** Hz into the superclass. Neither matches `zef_init` (`inv_sampling_frequency` 20000, `inv_time_3` 0.001). The repository does not explain why the init sampling rate is 20000.

## Developer guidance

- New solver: add `@NewInverter` + registry entry + `+tests` case; update this table. Step-by-step: [`docs/developer-guide.md`](../docs/developer-guide.md). Kernels shared with Kalman/GMM belong in `+gmm` / `+kf`.
- Prefer `MethodParams` over mutating global `zef` for cluster reproducibility.
- Pitfall: assuming GUI menu labels map 1:1 to class registry ids.
