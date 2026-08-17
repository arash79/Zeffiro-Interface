# `+plugins` — numerical kernels used by class inverse, not GUI plugins

## Folder purpose

MATLAB package at the repository root for Kalman predict/update and optional GMM post-processing used by class inverters in `+inverse`, without opening a window. Call as `plugins.ClassGMM.*` and `plugins.ClassKF.*` after `zeffiro_interface` adds the project root. Do **not** `addpath('+plugins')`. **This is not `tools/plugins/`** (the Inverse/Forward/Multi tools menus).

## Main contents

| Package | Why it exists | Who calls it |
|---------|---------------|--------------|
| `+ClassGMM/` | Fit a Gaussian mixture to a reconstruction (clusters, optional orientation) | `inverse.CommonInverseParameters.computeGMM` after invert (Statistics Toolbox) |
| `+ClassKF/` | Discrete Kalman predict / update / standardized update | `inverse.KalmanInverter.invert` (registry ids `kalman` / `kf`) |

## Code functionality

Nothing here is a menu callback. Nothing here writes `zef.reconstruction` by itself. Class Kalman uses `plugins.ClassKF.class_kf_predict` / `kf_update` internally during `zef_inverse_run` / `invert`. GMM is optional post-processing via `computeGMM` on an inverter that already has a reconstruction.

## Workflow context

GUI GMM apps (Inverse tools → Gaussian Mixture Model) and GUI Kalman (**Inverse tools → Kalman**) do **not** import this package. DTI structural process-noise `Q` is GUI-Kalman only. Mixing `+plugins` with `tools/plugins` is the usual source of confusion: GUI Kalman is `zef_KF`; class Kalman is `inverse.KalmanInverter` calling `plugins.ClassKF`.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local");

inv = inverse.MNEInverter();
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);
inv = inv.computeGMM(zef.reconstruction, zef);   % ClassGMM
```

## Important notes

Math and name-values: `+ClassGMM/README.md`, `+ClassKF/README.md`. Class inverse overview: `+inverse/README.md`. GUI plugins: `tools/plugins/README.md`.

## Developer guidance

Keep numerical kernels here and GUI start functions under `tools/plugins`. Do not wire menu callbacks into this package. Document APIs in the ClassGMM / ClassKF child READMEs.
