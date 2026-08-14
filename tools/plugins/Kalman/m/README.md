# Kalman / m

MATLAB for the Kalman plugin: `zef_kf_start` opens the app; `zef_KF` is the solver. Filter/RTS helpers in this folder are called from `zef_KF`, not from the menu. User manual: parent README.

DTI structural `Q` (`zef_dti_structural_Q` and FA / tractography helpers) is **this path only**. `inverse.KalmanInverter` does not call these files.

## Internals

| File | Role |
|------|------|
| `zef_kf_start.m` | INI callback |
| `zef_kf_open_window.m` | Instantiates `zef_kf_app`; Start → `zef = zef_KF(zef)` |
| `zef_KF.m` | Solver (`A = I`; optional DTI `Q`) |
| `kalman_filter.m` / `kalman_filter_sLORETA.m` | Types 1, 4 / 3 |
| `EnKF.m` | Type 2 |
| `double_kf_sL.m` / `triple_kf_sL.m` | Types 5–6 / 7–9 |
| `RTS_smoother.m` / `Block_RTS_smoother.m` | `kf_smoothing` 2 / 3–4 |
| `kf_predict.m` / `kf_update.m` / `kf_sL_update.m` | Steps |
| `find_evolution_prior.m` | Scalar `q` when `q_value` omitted |
| `zef_dti_*.m` | Structural `Q` (`kf_structural_Q_type` 1–2) |

Not wired from Start: `kalman_filter_sLORETA_EVO_DIAG_WEIGHT`, `kf_sL_update_approx`, `RTS_smoother_standardized`, `RTS_smoother_normal2standardized`, `sample_RTS_smoother`, `Q_quantities`, `connectivity_matrix`.

## Unpatched

- `zef_kf_open_window` uses `mun2str` (not `num2str`) when `zef.kf_burn_in` already exists.
- `kf_predict` identity test is `all(diag(A) - 1) < eps` as written.
