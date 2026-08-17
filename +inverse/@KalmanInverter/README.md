## Folder purpose

Sequential Kalman filter for `L x_t ≈ y_t` with state `x_t = A x_{t-1} + w`, `w ~ N(0, Q)`. Registry ids: `kalman`, `kf`. Default `method_type` is `"Basic Kalman filter"`.

## Main contents

| File | Role |
|------|------|
| `KalmanInverter.m` | Filter type, Q model, ensembles, smoothing flags, state |
| `initialize.m` | Reset recursion; `noise_cov`; `theta0` from first `number_of_noise_steps` frames; build Q |
| `invert.m` | One predict-update; EnKF is inline (not ClassKF) |
| `smoother.m` | RTS / Sample RTS over stored `posterior_covs` |

## Code functionality

Not a handle class (unlike other inverters). Predict/update kernels: `plugins.ClassKF`. Optional RTS smoother after the frame loop when `use_smoothing` is true (`dispatch_inverse` / `zef_process_inversion` call `smoother(z_inverse, L)`).

`method_type`: `"Basic Kalman filter"` \| `"Standardized Kalman filter"` \| `"Approximated Standardized Kalman filter"` \| `"Ensembled Kalman filter"`. Standardized types return `z = D x` with sLORETA-style `D` from `kf_sL_update` / `_approx`. EnKF uses `number_of_ensembles` (default 100).

Process noise Q via `evolution_prior_model`:

| Value | What `initialize` stores |
|-------|--------------------------|
| `"Sensitivity scaling"` | Diagonal `evolution_var` from `diff(f_data)` / column norms of `L`, scaled by `evolution_prior_db` |
| `"Avg. sensit. scaling"` | Same with spatially averaged sensitivity |
| `"SVD-based"` | Dense `evolution_cov` from `svd(L)` |
| `"Avg. SVD-based"` | Scaled identity |
| `"Reworked original"` | Identity times `time_step * (σ_max(L)² / ‖L‖_F²) * 10^(db/20)` |
| `"User supplied Q"` | Requires `evolution_cov` of size `n_state × n_state` |

Other parameters: `state_transition_model_A` (default `I`), `initial_prior_steering_db`, `number_of_noise_steps` (4), `smoother_type` `"None"` \| `"RTS"` \| `"Sample RTS"`.

## Workflow context

GUI Kalman still calls `zef_KF` (`legacy_kalman`). `+examples/+inverse/zef_KalmanDemo.m` also still calls `zef_KF`. Cluster example: `+utilities/+cluster/+examples/kalman_workflow.m`.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local");
[zef, r] = zef_inverse_run(zef, "kf", "MethodParams", struct( ...
    "method_type", "Standardized Kalman filter", ...
    "evolution_prior_model", "Sensitivity scaling", ...
    "evolution_prior_db", -34));
```

## Important notes

DTI / tractography Q (`zef_dti_structural_Q`, `zef.kf_structural_Q_type`) is **legacy `zef_KF` only**. On this class, precompute Q yourself and pass `"User supplied Q"`. The `smoother_type` setter currently only toggles `use_smoothing` and does not store `val`.

## Developer guidance

Keep ClassKF kernel contracts stable. Document Q models here when adding new `evolution_prior_model` values; do not silently depend on plugin DTI helpers.
