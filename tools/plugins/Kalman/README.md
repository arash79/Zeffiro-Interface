# tools/plugins/Kalman
## Folder purpose

Discrete-time Kalman filter / RTS smoother on the source vector (`A = I`). Use it for time-resolved imaging when consecutive frames should share a process-noise prior. Optional DTI structural `Q` (`zef.kf_structural_Q_type` 1 FA, 2 tractography) is **this plugin only**, not `inverse.KalmanInverter`.

## Main contents

- Start: `m/zef_kf_start.m` → `zef_kf_open_window`
- Solver: `m/zef_KF.m` (plus `kalman_filter.m`, RTS / block helpers)
- Layout: `mlapp/zef_kf_app.mlapp`
- `Scripts/` and `clusterScripts/` — extra plotting / batch helpers, not the Inverse-tools button

## Code functionality

**StartButton** `ButtonPushedFcn`:

```matlab
zef = zef_KF(zef);
```

**ApplyButton** copies widget `Value` fields onto `zef` (does not invert). **CloseButton** deletes the app.

Filter dropdown (`zef.KF.filter_type` → `zef.filter_type`, ItemsData `'1'`…`'9'` in `zef_kf_open_window`):

| Value | Label | Solver |
|-------|-------|--------|
| 1 | No standardization | `kalman_filter` (plain KF, A = I). Caps smoother at RTS. |
| 2 | EnKF | `EnKF`; ensemble count from `number_of_ensembles`. Caps smoother at none. |
| 3 | Spatiotemporal standardization | `kalman_filter_sLORETA` inside the update |
| 4 | Spatial standardization | `kalman_filter` then diagonal sLORETA weights `W` on each frame |
| 5 / 6 | Double block Kalman (sLORETA1 / 2) | `double_kf_sL` with `sL` = 1 or 2 |
| 7 / 8 / 9 | Triple block Kalman (sLORETA1 / 2 / 3) | `triple_kf_sL` with `sL` = 1, 2, or 3 |

Smoother (`zef.kf_smoothing`): none / RTS / 2Block RTS / 3Block RTS → 1–4. After the filter, `ext_sL` may still apply if `sL < smoothing-1`. Standardization exponent Items: 1/2, 1, 5/4, 3/2, 7/4, 2.

Needs: `zef.L`, interpolation, `zef.source_positions`, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.inv_snr` → `R = (10^(-inv_snr/20))^2 I`; prior scale from `inv_prior_over_measurement_db` / `inv_amplitude_db`; process noise `zef.inv_evolution_prior` via `find_evolution_prior`, or optional second argument `q_value`; frames `zef.number_of_frames`, `inv_time_*`, band edges; `zef.kf_burn_in` for block filters; `zef.filter_type`, `zef.kf_smoothing`, `zef.standardization_exponent`.

Writes: `zef.reconstruction` after `zef_postProcessInverse` / peak-norm; `zef.reconstruction_information` with tag `Kalman`, Q scale, `structural_Q_type`. If `nargout == 0`, `zef_KF` assigns `zef` into the base workspace.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Kalman** |
| `_legacy`, `_nse` | Inverse tools → **Kalman** |
| asteroid_radar / asteroid_gravity | **not in those INIs** |

INI callback: `zef_kf_start`. Window title: `ZEFFIRO Interface: Kalman Filter`.

This plugin does **not** construct `inverse.KalmanInverter`. Class ids `kalman` / `kf` (and `legacy_kalman`) are a separate `zef_inverse_run` track.

## Usage instructions

1. Open Inverse tools → Kalman (default / legacy / NSE profiles).
2. Choose filter type and smoother; optionally set structural `Q`.
3. Press Apply to copy widgets, then Start to run `zef_KF`.

## Important notes

- DTI structural `Q` exists only in this plugin path, not in `inverse.KalmanInverter`.
- Asteroid profiles do not register this menu entry.
- `Scripts/` and `clusterScripts/` are helpers, not the menu Start path.

## Developer guidance

Preserve callback `zef_kf_start` and reconstruction tag `Kalman`. Do not conflate with `kalman` / `kf` / `legacy_kalman` class ids.
