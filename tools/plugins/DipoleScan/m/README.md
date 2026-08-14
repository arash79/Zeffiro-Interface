# DipoleScan / m

This is the **legacy GUI solver** for Inverse tools → **Dipole Scan**. It fits one equivalent dipole (or a GOF map of all locations) per time frame. The class path is `inverse.DipoleScanInverter` via `zef_inverse_run(zef,'dipolescan')` — this folder does not construct that object.

User manual (menu, Start button, SNR): [parent README](../README.md).

| File | Role |
|------|------|
| `zef_dipole_start.m` | INI callback |
| `zef_dipole_window.m` | Instantiates `dipole_app`; Start → `zef_dipoleScan` |
| `zef_dipoleScan.m` | Per location: SVD (`econ`) or `pinv` of the 1- or 3-column lead field vs the frame; stores GOF × moment. `onlymax` is false as written (full map). Constrained normals use `source_interpolation_ind{3}`. |

Needs `zef.L`, interpolation, `zef.measurements`. Method/regularization come from `zef.dipole_app` dropdowns, not from `+inverse` properties.
