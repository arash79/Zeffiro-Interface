# Kalman — App Designer layouts

## Folder purpose

App Designer UI for the **Kalman** inverse plugin: discrete-time Kalman filter / RTS smoother on the source vector (`A = I`), including optional DTI structural `Q` available only on this GUI path.

## Main contents

| File | Role |
|------|------|
| `zef_kf_app.mlapp` | Kalman Filter window (filter type, smoother, SNR / priors, Start / Apply / Close) |
| `README.md` | This documentation |

Solvers: `plugins/Kalman/m/` (`zef_kf_start` → `zef_kf_open_window`, `zef_KF`, `kalman_filter`, EnKF / block helpers).

## Code functionality

`zef_kf_start` opens this app via `zef_kf_open_window`. **Apply** copies widget values onto `zef`; **Start** runs `zef = zef_KF(zef)` (filter types 1–9, optional RTS / block smoothers); **Close** deletes the app. Writes `zef.reconstruction` with tag `Kalman`. Structural `Q` (`kf_structural_Q_type`) exists here only, not in `inverse.KalmanInverter`.

## Workflow context

Inverse tools → **Kalman** on `multicompartment_head` / `_legacy` / `_nse` (`zef_kf_start`). Not registered on asteroid profile INIs. Separate from class ids `kalman` / `kf` / `legacy_kalman` on `zef_inverse_run`.

## Usage instructions

```matlab
zef = zef_kf_start(zef);   % opens zef_kf_app.mlapp
% Title: ZEFFIRO Interface: Kalman Filter
```

1. Open Inverse tools → Kalman.
2. Choose filter type and smoother; optionally set structural `Q`.
3. Apply, then Start.

Edit UI only in App Designer.

## Important notes

- DTI structural `Q` is this plugin path only.
- Asteroid profiles do not register this menu entry.

## Developer guidance

- Preserve callback `zef_kf_start` and reconstruction tag `Kalman`.
- Keep filter-type ItemsData (`'1'`…`'9'`) in sync with `zef_kf_open_window` / `zef_KF`.
- Do not conflate with `inverse.KalmanInverter`.
