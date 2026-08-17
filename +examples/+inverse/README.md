# +examples/+inverse

## Folder purpose

Worked inverse demos for learners. Currently a single Kalman demonstration that drives the **legacy plugin** path (`zef_KF`), not `inverse.KalmanInverter`.

## Main contents

| File | Role |
|------|------|
| `zef_KalmanDemo.m` | Cell script: synth EEG via forward example + two dipoles → `zef_KF` (`filter_type=1`) |

## Code functionality

Builds or reuses a lead field (often via `examples.forward.lead_field_example`), synthesizes measurements, runs legacy Kalman, optionally plots/saves (some cells may be commented / under maintenance).

## Workflow context

```
examples.forward → L + measurements
  → tools/plugins/Kalman (zef_KF)
Class alternative: zef_inverse_run / inverse.KalmanInverter
```

## Usage instructions

```matlab
edit examples.inverse.zef_KalmanDemo   % or open the .m and run cells
```

Ensure Zeffiro is on the path (`zeffiro_interface` once from repo root).

## Important notes

- Script, not a package function with `arguments`.
- Does not demonstrate structural Q or ClassKF.
- Visualization/save cells may need local path edits.

## Developer guidance

- Prefer adding a second demo that calls `zef_inverse_run(...,'kalman',...)` for the class path.
- Pitfall: treating this as the supported API for production KF studies.
