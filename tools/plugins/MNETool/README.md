# MNETool

Tikhonov minimum-norm source imaging (MNE) plus dSPM, sLORETA, and weighted MNE. Use it when you want a fast linear inverse of the whole source grid rather than a sparse or sequential method.

This plugin does **not** construct `inverse.MNEInverter`. Class ids `mne` / `wmne` (and `legacy_mne`) are a separate `zef_inverse_run` track.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Minimum norm estimation tool** |
| `multicompartment_head_legacy`, `_nse` | same |
| asteroid_radar / asteroid_gravity | Inverse tools → **Minimum norm estimation tool** |

INI callback: `zef_minimum_norm_estimation`.

Window title: `ZEFFIRO Interface: Minimum norm estimate tool`.

## Run the solver

**Start** (`zef.h_mne_start`) Callback:

```matlab
zef_update_mne; [zef.reconstruction, zef.reconstruction_information] = zef_find_mne_reconstruction(zef);
```

Type popup (`zef.h_mne_type`): `MNE`, `dSPM`, `sLORETA`, `wMNE` → `zef.mne_type` 1–4.

All four start from the same Tikhonov operator `L_inv = √θ L' (LθL' + σ²I)⁻¹` with Gaussian prior `θ` from `zef_find_gaussian_prior`. Then:

| Value | Label | Extra scaling |
|-------|-------|----------------|
| 1 | MNE | none |
| 2 | dSPM | divide rows by `sqrt(sum(L_inv.^2,2))` |
| 3 | sLORETA | divide by `sqrt(sum(L_inv.*L',2))` |
| 4 | wMNE | before the solve, `√θ` is divided by `(∑_xyz ‖L_i‖²)^{0.5·0.6}` (`mne_exponent` is hardcoded `0.6` in the solver) |

Prior popup spatially balanced vs constant is `zef.mne_prior` (same `balance_spatially` flag as IAS).

## Needs

- `zef.L`, `zef.source_interpolation_ind`, `zef.source_direction_mode`
- `zef.measurements` (band-pass via `zef_getFilteredData` / `zef_getTimeStep`)
- SNR: copies `zef.inv_snr` into the run; likelihood std is `10^(-inv_snr/20)`
- Frames: `zef.mne_time_1/2/3`, `zef.mne_number_of_frames` (copied onto `zef.inv_*` / `number_of_frames` inside the solver)
- Filters: `zef.mne_sampling_frequency`, `mne_low_cut_frequency`, `mne_high_cut_frequency`

## Writes

- `zef.reconstruction` — cell of source vectors after `zef_postProcessInverse` / peak-norm
- `zef.reconstruction_information` — tag `mne_type`, SNR, type, prior, frame metadata

## Files

- Start: `m/zef_minimum_norm_estimation.m` → `zef_mne_tool_start` → `zef_mne_tool_window`
- Solver: `m/zef_find_mne_reconstruction.m`
