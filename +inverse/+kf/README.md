## Folder purpose

Kalman numerical kernels (predict/update) used by `inverse.KalmanInverter.invert` and the spatial stage of `inverse.UKFNMMInverter.invert`. Not a user-facing inverse method: there is no registry id for this package.

## Main contents

| File | Called when | Math |
|------|-------------|------|
| `class_kf_predict.m` | Basic / standardized / approx sKF | `m = A x`, `P = A P A' + Q` (identity-`A` shortcut: `P = P + Q`) |
| `kf_update.m` | `"Basic Kalman filter"`, sKF when smoother type is RTS, and `UKFNMMInverter` spatial stage | Standard update: `K = P H' / (H P H' + R)`, then `P ← P − K (P H')'` with symmetrization of `S` and `P` (not the Joseph form `(I−KH)P(I−KH)'+KRK'`) |
| `kf_sL_update.m` | `"Standardized Kalman filter"` | Same update plus sLORETA scale `D` from `sqrtm(P)` so invert returns `D*x` |
| `kf_sL_update_approx.m` | `"Approximated Standardized Kalman filter"` | Same idea; `P^{-1/2}` via scaled Denman–Beavers (`spd_invsqrt_denman_beavers`) |
| `spd_invsqrt_denman_beavers.m` | approx sKF filter and RTS | SPD eig `P^{-1/2}`; replaces Schulz-from-I |

## Code functionality

Registry ids `kalman` / `kf` select `inverse.KalmanInverter`, which calls these functions. Ids `ukfnmm` / `ukf_nmm` select `inverse.UKFNMMInverter`, whose spatial stage calls `class_kf_predict` and `kf_update` on a per-source SVD-modified lead field (not `kf_sL_update`). EnKF is implemented inside `KalmanInverter.invert`, not here. Legacy GUI Kalman (`plugins/Kalman/m/zef_KF.m`) does **not** import this package.

## Workflow context

Internal to the class Kalman path and the UKFNMM spatial stage after `zef_inverse_run` / dispatch. DTI structural Q (`zef_dti_structural_Q`) is plugin-side; the class path accepts a user matrix via `evolution_prior_model` `"User supplied Q"` and `evolution_cov`.

## Usage instructions

Not called directly. Configure the inverter:

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local", ...
    "MethodParams", struct("method_type", "Standardized Kalman filter"));
```

`method_type` strings must match the `mustBeMember` list on `inverse.KalmanInverter`.

## Important notes

- `kf_sL_update` uses dense `sqrtm(P)` for the sLORETA weights.
- `kf_sL_update_approx` uses `inverse.kf.spd_invsqrt_denman_beavers` (SPD eigendecomposition). The inherited Schulz-from-I stencil diverged when `λ(P)` left `(0, 2)` and is not used.
- `kf_update` is the standard `P ← P − K(PH')'` update with symmetrization of `S` and `P`, not the Joseph form `(I−KH)P(I−KH)'+KRK'`.

## Developer guidance

Changing these equations requires Kalman inverter tests plus a manual comparison to `zef_KF` on sample data; the two trees are copies, not shared.
