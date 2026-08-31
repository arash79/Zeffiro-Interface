## Folder purpose

Scan every source location for the single dipole (or local orientation) that best fits the current time frame. Use it for a one-source localization map, not a distributed image.

## Main contents

- Start: `m/zef_dipole_start.m` → `zef_dipole_window`
- Solver: `m/zef_dipoleScan.m`
- Layout: `mlapp/dipole_app.mlapp`

## Code functionality

**StartButton** `ButtonPushedFcn`:

```matlab
[zef.reconstruction, zef.reconstruction_information]=zef_dipoleScan(zef);
```

Inversion method (`InversionmethodDropDown` `Items` / `ItemsData`): **SVD** / **matlab pseudoinverse** → `'SVD'` / `'pinv'`. Lead-field regularization (`regType`): **None** / **Reduce dimension to (SVD)** → `'1'` / `'SVD'`. The SVD-rank path uses `inv_leadfield_lambda` as the **number of right singular vectors kept** (not a ridge λ). That applies only to free-orientation sources (`notNormal`); cortical-normal columns use a 1-column lead field.

The map stored in `zef.reconstruction` is goodness-of-fit `1 − ‖f−Lf q‖²/‖f‖²`. Constrained-normal locations copy that scalar onto all three xyz slots; free-orientation locations store `gof × unit moment`. `dipole_type` is stored from the window but is not read by the solver.

Needs: `zef.L`, interpolation, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.inv_snr` stored in `reconstruction_information` (scan itself is residual-based); frames `zef.number_of_frames`, `inv_time_1/2/3`, sampling frequency, band edges.

Writes: `zef.reconstruction` (cell, one frame each); `zef.reconstruction_information` with tag `Dipole` + method name.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Dipole Scan** |
| `_legacy`, `_nse` | Inverse tools → **Dipole Scan** |
| asteroid_radar / asteroid_gravity | Inverse tools → **Dipole scan** |

INI callback: `zef_dipole_start`. Window title at runtime (`zef_dipole_window`): `ZEFFIRO Interface: Dipole scan tool`. The App Designer resource itself is named `ZEFFIRO Interface: Dipole Scan`.

This plugin does **not** construct `inverse.DipoleScanInverter`. Class ids `dipolescan` / `dipole_scan` (and `legacy_dipolescan`) are a separate `zef_inverse_run` track.

## Usage instructions

1. Open Inverse tools → Dipole Scan / Dipole scan.
2. Choose inversion method (SVD / pinv) and lead-field regularization.
3. Press Start.

## Important notes

- `inv_leadfield_lambda` is SVD rank (singular vectors kept), not a ridge λ, on the free-orientation path.
- `dipole_type` is written from the window but is not used by `zef_dipoleScan`.

## Developer guidance

Preserve callback `zef_dipole_start` and tag `Dipole` + method name. Do not conflate with `dipolescan` / `dipole_scan` / `legacy_dipolescan` class ids.
