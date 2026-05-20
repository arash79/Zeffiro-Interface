# +inverse/@KalmanInverter

## Folder purpose

**Dynamical Kalman filtering** over time series: Basic KF, standardized sLORETA-style KF, approximate standardized update, and EnKF branch. Uses **`plugins.ClassKF`** (`class_kf_predict`, `kf_update`, `kf_sL_update`, …). Optional **RTS smoother** after frame loop.

## Main contents

| File | Role |
|------|------|
| `KalmanInverter.m` | `method_type`, structural Q, evolution priors, smoothing flags |
| `initialize.m` | State/covariance from data |
| `invert.m` | Predict/update per frame; carries `prev_step_reconstruction` across frames |
| `smoother.m` | RTS backward pass when enabled |

## Code functionality

Unlike static inverters, state persists across frames in `invert.m`. Selects update kernel by `method_type` string.

**Registry:** `kalman`, `kf` (class); `legacy_kalman` → `zef_KF` in `tools/plugins/Kalman`.

**GUI/demo gap:** `+examples/+inverse/zef_KalmanDemo.m` still calls legacy `zef_KF`, not this class.

## Workflow context

`+utilities/+cluster/+examples/kalman_workflow.m` demonstrates class path.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'kalman', 'execution', 'local');
```

## Important notes

- DTI structural Q optional via plugin helpers (`zef_dti_structural_Q`).
- EnKF branch has separate code path from standard KF updates.
- Smoothing replaces `z_inverse` cell when `use_smoothing` enabled.

## Developer guidance

- Changes to `plugins.ClassKF` must stay compatible with `invert.m` method_type strings.
- When deprecating `zef_KF`, update Kalman demo and menu callbacks to `zef_inverse_run`.
