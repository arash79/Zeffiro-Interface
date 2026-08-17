# +inverse — class-based inverse solvers

## Folder purpose

Object-oriented **EEG/MEG (and related) inverse solvers**. Each `@*Inverter` implements at least `invert` and inherits shared filtering/time/SNR handling from `inverse.CommonInverseParameters`. This is the **class / cluster** track. GUI Inverse-tools menus still call **legacy** functions under `tools/plugins/`.

## Main contents

| Item | Role | Registry ids |
|------|------|----------------|
| `CommonInverseParameters.m` | Base: band-pass, frames, SNR, `withPropertiesFromZef`, `computeInversionWithZI`, `computeGMM` | — |
| `@CSMInverter` | dSPM / sLORETA / SBL | `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` |
| `@MNEInverter` | Weighted MNE | `mne`, `wmne` |
| `@ELORETAInverter` | eLORETA fixed-point | `eloreta` |
| `@KalmanInverter` | KF / sLORETA-KF / EnKF + RTS | `kalman`, `kf` |
| `@BeamformerInverter` | LCMV / UNG / unit-gain | `beamformer` |
| `@DipoleScanInverter` | Dipole-scan GoF | `dipolescan`, `dipole_scan` |
| `@IASInverter` | IAS MAP | `ias` |
| `@RAMUSInverter` | RAMUS multires | `ramus` |
| `@GroupLassoInverter` | Group LASSO via `LG_optimization` | `grouplasso`, `group_lasso` |
| `@HALpRInverter` | Hierarchical Lp via `L1_optimization` | `halpr` |

Discovery is **not** a folder scan: `utilities.cluster.inverse_method_registry` maps ids → class names.

## Code functionality

**Frame loop** (`utilities.inverse.run_frame_loop`):

1. Filter/normalize measurements  
2. Optional `initialize(L, f_data)`  
3. Optional `precompute(L[, procFile])`  
4. Per frame: `invert(f, L, procFile, …)`  
5. Optional Kalman `smoother`, `terminateComputation`, post-process → `zef.reconstruction`

**Base class:** `REQUIRED_METHODS = "invert"`; `computeInversionWithZI` → `zef_process_inversion`; `computeGMM` → `plugins.ClassGMM`.

**Kalman note:** class Kalman does **not** implement DTI structural Q; that exists only on the legacy `tools/plugins/Kalman` path (`zef_dti_structural_Q`). Pass a user `Q` via `MethodParams` if needed.

## Workflow context

| Track | Entry | Implementation |
|-------|-------|------------------|
| Class / cluster | `zef_inverse_run` → `dispatch_inverse` | `@*Inverter` here |
| Legacy GUI | Inverse-tools menu | `tools/plugins/*` |
| Tests | `+tests` | ClassVsLegacy, ELORETA*, EndToEndSynthetic, … |

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
- IAS/RAMUS: watch for `n_n_map_iterations` vs `n_map_iterations` typos in property wiring.
- GroupLasso/HALpR need EXP optimizers on the path; RAMUS needs `multiresolution_dec`.

## Developer guidance

- New solver: add `@NewInverter` + registry entry + `+tests` case; update this table.
- Prefer `MethodParams` over mutating global `zef` for cluster reproducibility.
- Pitfall: assuming GUI menu labels map 1:1 to class registry ids.
