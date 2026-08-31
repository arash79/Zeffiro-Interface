# +examples/+inverse

## Folder purpose

Worked inverse demo for learners. The shipped script drives the **legacy Kalman plugin** (`zef_KF` in `plugins/Kalman/m`), not `inverse.KalmanInverter`. Use it to see synthetic EEG → reconstruction in one MATLAB file. Production / cluster Kalman should use `zef_inverse_run`.

## Main contents

| File | Role |
|------|------|
| `zef_KalmanDemo.m` | Script (not a package function with `arguments`). Local functions: `zef_KalmanDemo_create_measurement`, `zef_KalmanDemo_runKalman` |

## Code functionality

1. **`zef_KalmanDemo_create_measurement`**  
   - Calls `examples.forward.lead_field_example` with `n_sources=2000`, EEG (`lead_field_type=1`), Cartesian directions, mesh resolution 4.5, smoothing/refinement on.  
   - Places two 10 nAm dipoles (nearest interpolated brain nodes): cortical `[-33,-37,80]` mm, orientation `[0.2,1,0]`; thalamic `[-12,-32,50]` mm (N20 ~2 ms earlier).  
   - Blackman–Harris pulse, 2500 Hz, 25 dB Gaussian noise. Temporarily sets `source_direction_mode=2` for `zef_processLeadfields`, then restores 1. Scales `L` by `1e-6` (µV/nAm) before `y = L*ori*amp*time + noise`.

2. **`zef_KalmanDemo_runKalman`**  
   - `inv_snr=25`, 26 frames, `inv_time_3=0.0004` s, `normalize_data=1`, `inv_evolution_prior=-34`.  
   - `filter_type=1` (plain KF), `kf_smoothing=1` (no RTS).  
   - `[project_struct] = zef_KF(project_struct)` — **not** `zef_inverse_run`.

Needs plugins on the path (`zeffiro_interface` / `genpath(plugins)`). Meshing + lead field can take several minutes and uses GPU if `use_gpu` is left at the forward-example default.

## Workflow context

```
examples.forward.lead_field_example → L + synthetic measurements
  → plugins/Kalman/m/zef_KF → zef.reconstruction
Class track (not this demo):
  zef_inverse_run(zef, "kalman", "execution", "local")
```

Structural DTI `Q` is not exercised here (plugin-only feature; class Kalman has no DTI Q).

## Usage instructions

Project root on the path. The file is a **script**; `examples.inverse.zef_KalmanDemo` is not a callable package function.

```matlab
cd /path/to/zeffiro_interface
zef = zeffiro_interface('start_mode','nodisplay');  % path warmup
run('+examples/+inverse/zef_KalmanDemo.m');
```

Or open the `.m` in the Editor and run cells (`zef_KalmanDemo_create_measurement` then `zef_KalmanDemo_runKalman`).

Class-track equivalent after you already have `zef.L` and measurements:

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local", ...
    "MethodParams", struct("method_type", "Basic Kalman filter"));
```

(`method_type` strings must match `inverse.KalmanInverter`.)

## Important notes

- Script, not `function` with name-value args.
- Does not demonstrate EnKF, RTS, or structural Q.
- Forward example may enable GPU; set `"use_gpu", false` inside `lead_field_example` if you have no CUDA.

## Developer guidance

- Adding a class-path demo should be a **second** file (e.g. `zef_KalmanClassDemo.m`) so this script remains a legacy-plugin walkthrough.
- Pitfall: treating `zef_KF` numerics as identical to `inverse.KalmanInverter` (different Q / DTI / smoother coverage).
