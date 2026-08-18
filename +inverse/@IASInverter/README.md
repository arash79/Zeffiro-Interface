# inverse.IASInverter

## Folder purpose

Class package for **Iterative Alternating Sequential (IAS) MAP** reconstruction under inverse-gamma or gamma hyperpriors, with optional dSPM/sLORETA post-hoc scaling. Registry id: `ias`.

## Main contents

| File | Role |
|------|------|
| `IASInverter.m` | Hyperprior mode/type, `n_map_iterations`, amplitude / prior-over-measurement dB knobs |
| `initialize.m` | Dynamic `theta0` / `beta` / `d_sqrt` / `noise_cov` via `zef_find_ig_hyperprior` / `zef_find_g_hyperprior` |
| `invert.m` | `n_map_iterations` of W-filter update + hyperposterior `d_sqrt` refresh |

No `precompute`. `terminateComputation` deletes dynamic properties.

## Code functionality

**Model:** Conditionally Gaussian sources with hierarchical hyperpriors. Each MAP step builds a weighted filter from current `d_sqrt`, applies to `f`, then updates hyperparameters.

**Key defaults (typical):** `hyperprior="Inverse gamma"`, `n_map_iterations=25`, `hyperprior_mode="Constant"`, SNR-related dB fields (`amplitude_db`, `prior_over_measurement_db`, tail length).

**Deps:** `zef_find_ig_hyperprior`, `zef_find_g_hyperprior` (GUI/callback helpers on path via `src`).

## Workflow context

```
zef_inverse_run(zef,'ias') → run_frame_loop → IASInverter
```

GUI: **IAS MAP estimation** → `zef_ias_iteration` (`legacy_ias`). ROI variant lives in `tools/plugins/IASROIInversion` (legacy only).

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'ias', 'execution', 'local', ...
    'MethodParams', struct('n_map_iterations', 25, 'hyperprior', 'Inverse gamma'));
```

## Important notes

- Last-step dSPM/sLORETA branches compare against `n_map_iterations`.
- Dynamicprops created in `initialize` must be cleaned in `terminateComputation` to avoid stale state across runs.
- Method_type `"None"` vs dSPM/sLORETA strings control post-hoc scaling.

## Developer guidance

- Keep hyperprior helper APIs stable; IAS/RAMUS share them.
- Prefer registry + class path over duplicating IAS loops in new plugins.
