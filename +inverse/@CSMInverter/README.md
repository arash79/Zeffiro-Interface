# +inverse/@CSMInverter

## Folder purpose

Class implementation of **Classical Sparse Methods (CSM)**: dSPM, sLORETA, 3D sLORETA, and SBL — the workhorse family behind the `ClassicalSparseMethods` GUI plugin.

## Main contents

| File | Role |
|------|------|
| `CSMInverter.m` | Properties: `method_type`, `theta0`, iteration counts; inherits `CommonInverseParameters` |
| `initialize.m` | Set `theta0` from SNR and measurement power |
| `precompute.m` | Cache projector `P` and diagonal weights `d` for dSPM/sLORETA variants |
| `invert.m` | Per-frame apply cached operator or SBL column updates |

## Code functionality

Dispatches on `method_type` string (`dSPM`, `sLORETA`, `sLORETA 3D`, `SBL`, …). dSPM/sLORETA use precomputed `P` and scaling vector `d`; SBL iterates hyperparameters on lead-field columns.

**Registry:** `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` (class); `legacy_csm` → `zef_CSM_iteration`.

## Workflow context

`ClassVsLegacyTest` compares `dspm` class dispatch vs `legacy_csm`. GUI uses `tools/plugins/ClassicalSparseMethods`.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'dspm', 'execution', 'local', ...
    'MethodParams', struct('method_type', 'dSPM'));
```

## Important notes

- `method_type` must match strings expected in `invert.m` switch.
- 3D sLORETA uses per-source `sqrtm` whitening — memory intensive.

## Developer guidance

- Keep parity with `zef_CSM_iteration` when changing formulas; update `ClassVsLegacyTest` thresholds.
