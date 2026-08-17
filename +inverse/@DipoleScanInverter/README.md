# inverse.DipoleScanInverter

## Folder purpose

Class package for **dipole scanning**: per-source fits on whitened data that store **goodness-of-fit** (not dipole amplitudes) in the reconstruction vector. Registry ids: `dipolescan`, `dipole_scan`.

## Main contents

| File | Role |
|------|------|
| `DipoleScanInverter.m` | Classdef: `method_type` (e.g. SVD), regularization, `noise_cov`, SVD caches |
| `initialize.m` | SNR-scaled identity noise if `noise_cov` empty |
| `precompute.m` | Whiten `L`; cache per-source thin SVDs (expects columns in groups of 3) |
| `invert.m` | Batched GoF from cache, or legacy per-source SVD/pinv |

## Code functionality

For each source (or free-orientation triplet), fit a dipole to measurement `f` under Mahalanobis whitening from `noise_cov`. Store GoF `1 - ‖f − L_s ŝ‖² / ‖f‖²` (free sources may encode direction / √3 in the packed vector).

**Outputs:** `z_vec` in lead-field column layout; post-process via `zef_postProcessInverseClassObj` maps into `zef.reconstruction`.

## Workflow context

Class: `zef_inverse_run(zef,'dipolescan')`. GUI: **Dipole Scan** plugin → `zef_dipoleScan` (`legacy_dipolescan`). Studies such as `+examples/+studies/+santtus_peeling_article` may use legacy helpers.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'dipolescan', 'execution', 'local');
```

## Important notes

- Reconstruction values are **GoF metrics**, not current amplitudes — do not treat peaks as source strength without conversion.
- `precompute` assumes free sources are stored as 3-column blocks.
- No `terminateComputation` / smoother on this class today.

## Developer guidance

- Preserve GoF semantics when changing packing; document any amplitude export separately.
- Prefer extending `precompute` batching over nested per-source loops in `invert`.
- Parity tests should compare peak location (GoF), not amplitude norms, against legacy.
