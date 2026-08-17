# DipoleScan — App Designer layouts

## Folder purpose

App Designer UI for the **Dipole Scan** plugin: scan every source location for the single dipole (or local orientation) that best fits the current time frame, producing a one-source localization map.

## Main contents

| File | Role |
|------|------|
| `dipole_app.mlapp` | Dipole Scan tool (Start, SVD/pinv method, lead-field regularization) |
| `README.md` | This documentation |

Solvers and window binder: `tools/plugins/DipoleScan/m/` (`zef_dipole_start` → `zef_dipole_window`, `zef_dipoleScan`).

## Code functionality

`zef_dipole_start` opens this app via `zef_dipole_window`. **StartButton** runs `[zef.reconstruction, zef.reconstruction_information] = zef_dipoleScan(zef)`. Dropdowns select SVD vs matlab pseudoinverse and optional SVD-rank lead-field regularization (`inv_leadfield_lambda` as singular-vector count on free-orientation sources). The map is goodness-of-fit, tagged `Dipole` + method name.

## Workflow context

Inverse tools → **Dipole Scan** / **Dipole scan** on head and asteroid profiles (`zef_dipole_start`). Needs `zef.L`, measurements, interpolation, and time-frame settings. Separate from class ids `dipolescan` / `dipole_scan` on the `zef_inverse_run` track.

## Usage instructions

```matlab
zef = zef_dipole_start(zef);   % opens dipole_app.mlapp
% Runtime title: ZEFFIRO Interface: Dipole scan tool
```

Or menu: Inverse tools → Dipole Scan. Choose method / regularization, then Start. Edit UI only in App Designer.

## Important notes

- App Designer resource title may say “Dipole Scan”; runtime window name is “Dipole scan tool”.
- `onlymax` is hardcoded false in the solver — Relative residual variance (max) does not collapse to a peak.

## Developer guidance

- Preserve callback `zef_dipole_start` and reconstruction tag `Dipole` + method name.
- Do not conflate this GUI with `inverse.DipoleScanInverter`.
- Keep StartButton / dropdown ItemsData in sync with `zef_dipole_window` and `zef_dipoleScan`.
