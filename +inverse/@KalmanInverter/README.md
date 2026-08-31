# inverse.KalmanInverter

A static inverse treats every time sample independently. A Kalman filter treats the source vector as a state that is allowed to change slowly: \(x_t = A x_{t-1} + w\), \(w \sim \mathcal{N}(0,Q)\), while each sample still has to match the sensors through \(L\). That is the right family when you have a time series and a process-noise story.

Registry ids: `kalman`, `kf`. Default `method_type` is `"Basic Kalman filter"`. The Inverse-tools Kalman plugin (`zef_KF`) is a **different** implementation (DTI structural \(Q\) lives only there).

## Main contents

| File | Role |
|------|------|
| `KalmanInverter.m` | Filter type, Q model, ensembles, smoothing flags, state |
| `initialize.m` | Reset recursion; `noise_cov`; `theta0` from first `number_of_noise_steps` frames; build Q |
| `invert.m` | One predict-update; EnKF is inline (not `inverse.kf`) |
| `smoother.m` | RTS / Sample RTS over stored `posterior_covs` |

## Code functionality

Not a handle class (unlike other inverters). Predict/update kernels: `inverse.kf`. Optional RTS smoother after the frame loop when `use_smoothing` is true (`dispatch_inverse` / `zef_process_inversion` call `smoother(z_inverse, L)`).

`method_type`: `"Basic Kalman filter"` \| `"Standardized Kalman filter"` \| `"Approximated Standardized Kalman filter"` \| `"Ensembled Kalman filter"`. Standardized types return `z = D x` with sLORETA-style `D` from `kf_sL_update` / `_approx`. When `smoother_type` is `"RTS"`, `invert` stores the raw mean and the filter `D_t` (from the **prior** \(P\)); `smoother` applies that stored `D_t` to the RTS mean, including `standardization_exponent`. EnKF uses `number_of_ensembles` (default 100).

Process noise Q via `evolution_prior_model`:

| Value | What `initialize` stores |
|-------|--------------------------|
| `"Sensitivity scaling"` | Diagonal `evolution_var` from `diff(f_data)` / column norms of `L`, scaled by `evolution_prior_db` |
| `"Avg. sensit. scaling"` | Same with spatially averaged sensitivity |
| `"SVD-based"` | Dense `evolution_cov` from `svd(L)` |
| `"Avg. SVD-based"` | Scaled identity |
| `"Reworked original"` | Identity times `time_step * (σ_max(L)² / ‖L‖_F²) * 10^(db/20)` |
| `"User supplied Q"` | Requires `evolution_cov` of size `n_state × n_state` |

Other parameters: `state_transition_model_A` (default `I`), `initial_prior_steering_db`, `number_of_noise_steps` (4), `smoother_type` `"None"` \| `"RTS"` \| `"Sample RTS"`. Identity detection for the A=I shortcut is `inverse.kf.is_identity_transition` (every diagonal entry is 1). The RTS smoother uses `self.number_of_frames` and the user `A`, not a hard-coded identity.

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

DTI / tractography Q (`zef_dti_structural_Q`, `zef.kf_structural_Q_type`) is **legacy `zef_KF` only**. On this class, precompute Q yourself and pass `"User supplied Q"`. Setting `smoother_type` to `"RTS"` or `"Sample RTS"` also sets `use_smoothing` so the frame-loop driver invokes `smoother`.

## Developer guidance

Keep `inverse.kf` kernel contracts stable. Document Q models here when adding new `evolution_prior_model` values; do not silently depend on plugin DTI helpers.
