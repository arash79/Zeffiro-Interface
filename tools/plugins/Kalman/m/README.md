# tools/plugins/Kalman/m

## Folder purpose

Legacy **Inverse tools → Kalman** implementation: discrete-time Kalman / EnKF / block-sLORETA filters on the source vector, with optional **DTI structural process noise Q**. Parallel to — and **not** the same as — `inverse.KalmanInverter` / `plugins.ClassKF`.

## Main contents

| Group | Files |
|-------|--------|
| UI | `zef_kf_start`, `zef_kf_open_window` (`mlapp/zef_kf_app.mlapp`) |
| Orchestration | `zef_KF` |
| Filters | `kalman_filter`, `kf_predict`, `kf_update`, `EnKF`, `kalman_filter_sLORETA`, `kf_sL_update`, `double_kf_sL`, `triple_kf_sL`, `ext_sL` |
| Smoothers | `RTS_smoother`, `Block_RTS_smoother` (wired); `RTS_smoother_standardized`, `RTS_smoother_normal2standardized`, `sample_RTS_smoother` (not Start-wired) |
| Q / DTI | `find_evolution_prior` (via `zef_KF`), `zef_dti_structural_Q`, `zef_dti_interpolate_to_sources` |
| Unused extras | `Q_quantities`, `connectivity_matrix`, `kalman_filter_sLORETA_EVO_DIAG_WEIGHT`, `kf_sL_update_approx` |

## Code functionality

**StartButton** → `zef = zef_KF(zef)`:

| `filter_type` | Path |
|---------------|------|
| 1 | Plain KF (`A = I`) |
| 2 | EnKF (no RTS) |
| 3 | Spatiotemporal sLORETA KF |
| 4 | Spatial standardization after KF |
| 5–6 | Double-block KF (`sL` 1/2) |
| 7–9 | Triple-block KF (`sL` 1/2/3) |

Smoother (`kf_smoothing`): none / RTS / 2–3 block RTS.  
Default `Q = q_scalar * I` from evolution prior. **Structural Q** (`kf_structural_Q_type`): `0` diagonal; `1` FA covariance; `2` tractography covariance — **this plugin only**.

Needs: `zef.L`, interpolation, measurements, SNR → `R`, frames / time / bands, optional DTI FA/v1 for structural Q.

## Workflow context

```
GUI Inverse tools → Kalman → zef_KF → zef.reconstruction
Class path: zef_inverse_run → inverse.KalmanInverter (no structural Q)
DTI FA/v1 also used by DTIConductivityTool (separate Apply-to-sigma pipeline)
```

## Usage instructions

```matlab
zef_kf_start;
% Set filter_type, smoothing, SNR, frames → Start
% Optional structural Q:
zef.kf_structural_Q_type = 1;  % FA; load DTI volumes first
```

## Important notes

- Structural Q can make `P` dense after the first update — prefer EnKF for large source counts.
- `kron(Q, I_3)` when using Cartesian directions.
- Widget burn-in may use a `mun2str` typo — verify Value conversion if editing UI.
- Extra Scripts/ under the plugin are plotting/batch helpers, not the Start button.

## Developer guidance

- Keep structural Q out of `inverse.KalmanInverter` unless deliberately unifying APIs and tests.
- New filter types: extend dropdown ItemsData **and** the `zef_KF` switch together.
- Pitfall: comparing plugin KF to ClassKF without matching `R`, `Q`, and smoother settings.
