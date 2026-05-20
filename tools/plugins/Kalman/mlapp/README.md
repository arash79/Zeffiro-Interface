# Kalman Plugin — GUI (`mlapp/`)

MATLAB App Designer graphical user interface for the Kalman filter plugin.

## File Reference

| File | Description |
|------|-------------|
| `zef_kf_app.mlapp` | App Designer application file. Provides interactive controls for filter type, smoothing mode, SNR, prior parameters, evolution prior, number of ensembles (EnKF), standardization exponent, and burn-in frames. Opened via `zef_kf_open_window`. |

## Opening the GUI

The Kalman filter GUI can be opened from:

1. **Zeffiro menu:** Inverse Tools > Kalman Filter
2. **Programmatically:** `zef_kf_open_window(zef)`

## GUI-to-Pipeline Connection

The GUI writes parameter values to `zef` struct fields (e.g., `zef.filter_type`, `zef.kf_smoothing`, `zef.inv_snr`) and then calls `zef_KF(zef)` to execute the reconstruction. Results are stored in `zef.reconstruction`.

## Modifying the GUI

To edit the GUI layout and callbacks:

```matlab
appdesigner('zef_kf_app.mlapp')
```

The App Designer file contains the UI layout, component properties, and callback code in a single `.mlapp` package.

## Note on DTI Structural Q

The DTI structural Q type (`zef.kf_structural_Q_type`) is currently configured programmatically rather than through this GUI. To add GUI support, add a dropdown or radio button group in the App Designer and wire its `ValueChangedFcn` to set `zef.kf_structural_Q_type` (0=diagonal, 1=FA-based, 2=tractography).
