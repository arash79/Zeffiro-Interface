# Inverse example — legacy Kalman demo

`zef_KalmanDemo.m` is a **script** (cells), not a package function. It calls **legacy** `zef_KF` in `tools/plugins/Kalman`, not `inverse.KalmanInverter` / `zef_inverse_run`.

```matlab
addpath(fileparts(which('zeffiro_interface')));
run('+examples/+inverse/zef_KalmanDemo.m');
```

Sequence in the file:

1. `zef_KalmanDemo_create_measurement` — `examples.forward.lead_field_example` with `n_sources=2000`, `lead_field_type=1`, then two synthetic dipoles (cortical `[-33,-37,80]`, thalamic `[-12,-32,50]`, 10 nAm, Blackman–Harris, 25 dB noise). Temporarily uses `source_direction_mode=2` for `zef_processLeadfields`.
2. `zef_KalmanDemo_runKalman` — sets `inv_snr=25`, `number_of_frames=26`, `filter_type=1` (Kalman), `kf_smoothing=1` (none), then `[zef] = zef_KF(zef)`.
3. Save / visualization cells are commented (`zef_KalmanDemo_save`, `zef_Kalman_visualization` marked under maintenance).

For the class Kalman path use `zef_inverse_run(zef,"kalman")` or `+utilities/+cluster/+examples/kalman_workflow.m`.
