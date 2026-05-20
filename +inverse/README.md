# +inverse

## Purpose of this folder

Object-oriented **inverse solvers** for EEG/MEG (and related) reconstruction. Each `@*Inverter` class implements `initialize` / `precompute` / `invert` (where applicable) and inherits shared filtering, framing, and SNR handling from `inverse.CommonInverseParameters`.

## Contents

| Class | Registry IDs (typical) | Algorithm (from implementation) |
|-------|------------------------|----------------------------------|
| `inverse.CSMInverter` | `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` | dSPM, sLORETA, 3D sLORETA, SBL |
| `inverse.MNEInverter` | `mne`, `wmne` | Minimum-norm / weighted MNE |
| `inverse.ELORETAInverter` | `eloreta` | Fixed-point eLORETA |
| `inverse.KalmanInverter` | `kalman`, `kf` | KF / standardized KF / EnKF via `plugins.ClassKF`; optional RTS smoother |
| `inverse.BeamformerInverter` | `beamformer` | LCMV / UNG / unit-gain beamforming |
| `inverse.DipoleScanInverter` | `dipolescan` | Dipole scan goodness-of-fit |
| `inverse.IASInverter` | `ias` | Iterative alternating sequential MAP |
| `inverse.RAMUSInverter` | `ramus` | RAMUS multiresolution IAS-style |
| `inverse.GroupLassoInverter` | `grouplasso` | Group LASSO via `LG_optimization` |
| `inverse.HALpRInverter` | `halpr` | Hierarchical Lp via `L1_optimization` |

Shared: `CommonInverseParameters.m` — SNR, band-pass, frames, `withPropertiesFromZef`, `computeInversionWithZI`.

## How this folder fits into the overall workflow

```
zef (mesh, L, measurements)
  → zef_processLeadfields (src/inverse)
  → utilities.inverse.run_frame_loop
       → inverter.initialize / precompute / invert (per frame)
  → zef_postProcessInverseClassObj
  → zef.reconstruction
```

Entry points:

- **In-process:** `MethodClassObj.computeInversionWithZI(zef)` → `zef_process_inversion`
- **Dispatch:** `zef_inverse_run(zef, method_id)` → `utilities.cluster.dispatch_inverse`
- **Cluster:** `utilities.cluster.submit_inverse_jobs`, `run_inverse_job`

**GUI gap:** most inverse **buttons** still call legacy `tools/plugins` functions (`zef_CSM_iteration`, `zef_find_mne_reconstruction`, …). Class API is the supported programmatic/cluster path; see `+tests/ClassVsLegacyTest.m`.

## GUI usage

Indirect only today: configure bands/SNR in **Forward & inverse options**, run lead field in **mesh tool**, then use a plugin that may still call legacy code. For class parity testing, run `+tests` from MATLAB.

## Programmatic usage

```matlab
addpath(fileparts(which('zeffiro_interface')));
addpath(genpath(fullfile(fileparts(which('zeffiro_interface')),'src')));

% High-level (recommended)
[zef, out] = zef_inverse_run(zef, "dspm", ...
    "execution", "local", ...
    "MethodParams", struct("method_type", "dSPM"));

% Direct object
inv = inverse.ELORETAInverter("regularization_parameter", 1e-2);
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);

% Registry
ids = utilities.cluster.inverse_method_registry();
```

Per-frame API (used by `run_frame_loop`):

```matlab
[z_vec, inv] = inv.invert(f, L, procFile, source_direction_mode, source_positions, opts);
```

## Examples

- `+examples/+inverse/zef_KalmanDemo.m`
- `+utilities/+cluster/+examples/eloreta_workflow.m`, `kalman_workflow.m`
- `+tests/ELORETAInverterTest.m`, `InverseDispatchTest.m`

## Dependencies and assumptions

- `zef.L` or processed lead field from `zef_processLeadfields`
- Filtered measurements via `zef_getFilteredDataClassObj` / class path
- `procFile` indices (`s_ind_0`, `s_ind_4`, `n_interp`, …) from lead-field processing
- Kalman: `plugins.ClassKF`; RAMUS/GroupLasso/HALpR: multires decomposition and EXP helpers when enabled
- GPU optional via `use_gpu` name-value pairs

## Notes for developers

- Add a new solver: new `@FooInverter` folder, inherit `CommonInverseParameters`, register in `utilities.cluster.inverse_method_registry`.
- Implement `invert` at minimum; add `precompute` when operator is frame-independent.
- Do not duplicate frame loops—extend `utilities.inverse.run_frame_loop`.
- Keep legacy plugin until `ClassVsLegacyTest`-style parity exists.
