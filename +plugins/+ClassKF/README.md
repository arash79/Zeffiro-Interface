# +plugins/+ClassKF

## Folder purpose

**Kalman filter numerical core** consumed by `inverse.KalmanInverter` — predict/update steps for basic, standardized, and approximate standardized filters. Legacy GUI Kalman (`tools/plugins/Kalman/m/zef_KF.m`) uses a **parallel copy** of related logic, not these package functions directly.

## Main contents

| File | Role |
|------|------|
| `class_kf_predict.m` | State mean/covariance prediction from `KFclassObj` |
| `kf_update.m` | Standard Kalman measurement update |
| `kf_sL_update.m` | Standardized (sLORETA-style) update |
| `kf_sL_update_approx.m` | Approximate standardized update |

(Older monolithic files like `kalman_filter.m`, `EnKF.m` were removed from package — EnKF may remain in plugin tree.)

## Code functionality

Called from `+inverse/@KalmanInverter/invert.m` based on `self.method_type` string. Operates on state vectors sized to processed lead-field columns, not full GUI `zef` unless wrapped.

## Workflow context

```
inverse.KalmanInverter.invert → plugins.ClassKF.kf_*
```

Registry: `kalman` / `kf` class IDs. Cluster: `kalman_workflow.m` example.

## Usage instructions

Not called directly by users — configure via:
```matlab
inv = inverse.KalmanInverter('method_type', 'Standardized Kalman filter');
[zef, inv] = inv.computeInversionWithZI(zef);
```

## Important notes

- Legacy `zef_KF` path does not import this package — parity is behavioral, not shared code.
- Structural covariance from DTI is plugin-side (`zef_dti_structural_Q`).

## Developer guidance

- Consolidate legacy `zef_KF` onto `plugins.ClassKF` before removing duplicate plugin `.m` files.
- Any change to update equations requires Kalman inverter tests + manual comparison to legacy on sample data.
