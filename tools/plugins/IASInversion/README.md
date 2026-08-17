## Folder purpose

Iterative alternating sequential (IAS) MAP: alternate a Gaussian source update with a gamma / inverse-gamma hyperprior on per-source variance. Use it for sparse-ish hierarchical Bayes without RAMUS multiresolution.

## Main contents

- Start: `m/ias_map_estimation.m` → `zef_init_ias` → `zef_ias_map_estimation_window`
- Solver: `m/zef_ias_iteration.m`

## Code functionality

**Start** (`zef.h_ias_start`) Callback, set in `zef_init_ias` (overrides the window constructor):

```matlab
zef_update_ias; [zef.reconstruction, zef.reconstruction_information] = zef_ias_iteration(zef);
```

Hyperprior popup: spatially balanced vs constant (`zef.ias_hyperprior`). Standardization popup (`zef.h_ias_type` `String`):

| Value | Label | What `zef_ias_iteration` does |
|-------|-------|-------------------------------|
| 1 | None | Weighted MNE step only: `z = √θ · L' (LθL' + σ²I)⁻¹ f` |
| 2 | sLORETA each step | Divide that operator by `sqrt(sum(L.*L_aux',2))` **every** MAP iteration |
| 3 | sLORETA last step | **Not reached.** Both sLORETA branches are `isequal(ias_type,2)` as written, so value 3 never standardizes |
| 4 | dSPM each step | Divide by `sqrt(sum(L.^2,2))` every iteration |
| 5 | dSPM last step | Same dSPM scale only on the last MAP iteration |

IAS then updates `θ` (inverse-gamma or gamma from `zef.inv_hyperprior`) and repeats `ias_n_map_iterations` times.

Needs: `zef.L`, `zef.source_interpolation_ind`, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.ias_snr` (copied from `zef.inv_snr` at init) → `std_lhood = 10^(-ias_snr/20)`; frames `zef.ias_number_of_frames`, `ias_time_1/2/3`, `ias_sampling_frequency`, `ias_low_cut_frequency`, `ias_high_cut_frequency`; MAP iterations `zef.ias_n_map_iterations` (default 25); hyperprior family `zef.inv_hyperprior` (1 inverse-gamma, 2 gamma) plus `inv_prior_over_measurement_db`.

Writes: `zef.reconstruction` after `zef_postProcessInverse` / peak-norm; `zef.reconstruction_information` with tag `IAS`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **IAS Inversion** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `ias_map_estimation`. Window title: `ZEFFIRO Interface: IAS MAP estimation`.

This plugin does **not** construct `inverse.IASInverter`. Class id `ias` (and `legacy_ias`) is a separate `zef_inverse_run` track.

## Usage instructions

1. Open Inverse tools → IAS Inversion.
2. Set hyperprior, standardization type, and MAP iteration count.
3. Press Start.

## Important notes

- Standardization value 3 (sLORETA last step) is never reached as written — both sLORETA branches test `isequal(ias_type,2)`.
- Hyperprior family still uses global `zef.inv_hyperprior`, not only the IAS-specific popup.

## Developer guidance

Preserve callback `ias_map_estimation`, Start override in `zef_init_ias`, and tag `IAS`. Do not conflate with `ias` / `legacy_ias` class ids.
