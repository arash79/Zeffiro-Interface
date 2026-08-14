# `+plugins` — numerical kernels used by class inverse, not GUI plugins

This MATLAB package sits at the repository root. `zeffiro_interface` adds the project root to the path, so you call `plugins.ClassGMM.*` and `plugins.ClassKF.*`. Do **not** `addpath('+plugins')`.

It exists because the class inverters in `+inverse` need Kalman predict/update and optional GMM post-processing without opening a window. **This is not `tools/plugins/`.** That tree is the Inverse/Forward/Multi tools menus (`zeffiro_plugins.ini`). Mixing the two names is the usual source of confusion: GUI Kalman is `zef_KF`; class Kalman is `inverse.KalmanInverter` calling `plugins.ClassKF`.

Nothing here is a menu callback. Nothing here writes `zef.reconstruction` by itself.

| Package | Why it exists | Who calls it |
|---------|---------------|--------------|
| `+ClassGMM/` | Fit a Gaussian mixture to a reconstruction (clusters, optional orientation) | `inverse.CommonInverseParameters.computeGMM` after invert. Needs Statistics Toolbox. |
| `+ClassKF/` | Discrete Kalman predict / update / standardized update | `inverse.KalmanInverter.invert`. Registry ids `kalman` / `kf`. |

GUI GMM apps (Inverse tools → Gaussian Mixture Model) and GUI Kalman (**Inverse tools → Kalman**) do **not** import this package. DTI structural process-noise `Q` is also GUI-Kalman only.

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local");
% invert used plugins.ClassKF.class_kf_predict / kf_update internally

inv = inverse.MNEInverter();
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);
inv = inv.computeGMM(zef.reconstruction, zef);   % ClassGMM
```

Math and name-values: [+ClassGMM/README.md](+ClassGMM/README.md), [+ClassKF/README.md](+ClassKF/README.md). Class inverse overview: [../+inverse/README.md](../+inverse/README.md). GUI plugins: [../tools/plugins/README.md](../tools/plugins/README.md).
