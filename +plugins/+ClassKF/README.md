# `plugins.ClassKF` — KF for inversion
## Folder purpose

Kalman numerical kernels (predict/update) used by `inverse.KalmanInverter.invert`. Not a user-facing inverse method: there is no registry id for this package.

## Main contents

| File | Called when | Math |
|------|-------------|------|
| `class_kf_predict.m` | Basic / standardized / approx sKF | `m = A x`, `P = A P A' + Q` (identity-`A` shortcut: `P = P + Q`) |
| `kf_update.m` | `"Basic Kalman filter"`, and sKF when smoother type is RTS | Standard update: `K = P H' / (H P H' + R)`, Joseph-style `P` |
| `kf_sL_update.m` | `"Standardized Kalman filter"` | Same update plus sLORETA scale `D` from `sqrtm(P)` so invert returns `D*x` |
| `kf_sL_update_approx.m` | `"Approximated Standardized Kalman filter"` | Same idea; `P^{1/2}` via a few Schulz iterations |

## Code functionality

Registry ids `kalman` / `kf` select `inverse.KalmanInverter`, which calls these functions. EnKF is implemented inside `KalmanInverter.invert`, not here. Legacy GUI Kalman (`tools/plugins/Kalman/m/zef_KF.m`) does **not** import this package.

## Workflow context

Internal to the class Kalman path after `zef_inverse_run` / dispatch. DTI structural Q (`zef_dti_structural_Q`) is plugin-side; the class path accepts a user matrix via `evolution_prior_model` `"User supplied Q"` and `evolution_cov`.

## Usage instructions

Not called directly. Configure the inverter:

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local", ...
    "MethodParams", struct("method_type", "Standardized Kalman filter"));
```

`method_type` strings must match the `mustBeMember` list on `inverse.KalmanInverter`.

## Important notes

`class_kf_predict` reads `state_transition_model_A`, `prev_step_reconstruction`, `prev_step_posterior_cov`, `evolution_cov` from the inverter object. `kf_sL_update` hard-codes `method = '1'` (dense `sqrtm`); path `'2'` (truncated SVD) is dead code unless that string is changed.

## Developer guidance

Changing these equations requires Kalman inverter tests plus a manual comparison to `zef_KF` on sample data; the two trees are copies, not shared.
