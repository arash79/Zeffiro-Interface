# RAP-MUSIC

Recursively applied MUSIC: peel successive dipoles from the signal subspace (`zef.RAPMUSIC_n_dipoles`, default 8). Use it for a few discrete sources when plain MUSIC’s single scan is not enough.

There is **no** `inverse.*Inverter`. Registry id `legacy_rap_music` dispatches `RAP_MUSIC_iteration`. This folder is **not** in any profile `zeffiro_plugins.ini`.

## Menu

Not in default INI (`multicompartment_head`) and not in asteroid / `_legacy` / `_nse` INIs. From MATLAB, with plugins on the path:

```matlab
RAPMUSIC_start
```

Window title: `ZEFFIRO Interface: RAP-MUSIC`.

## Run the solver

**StartButton** `ButtonPushedFcn`:

```matlab
zef.reconstruction = RAP_MUSIC_iteration;
```

`Var_loc` and `reconstruction_information` (extra outputs of `RAP_MUSIC_iteration`) are discarded by this button.

Each peel overwrites `orj` instead of concatenating it (the concatenate line is commented). `A_mat` therefore applies the **last** orientation to every found column. Documented as written.

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.inv_snr` → `10^(-inv_snr/20)`; also `inv_prior_over_measurement_db` for `theta0`
- `zef.RAPMUSIC_n_dipoles`, `zef.RAPMUSIC_leadfield_lambda`
- Frames: `zef.number_of_frames`, `inv_time_*`, band edges
- Reads `zef` from the base workspace

## Writes

- `zef.reconstruction` only (from the Start button)

## Files

- Start: `RAPMUSIC_start.m` constructs `RAPMUSIC_app`
- Solver: `RAP_MUSIC_iteration.m` (uses `zef_subspace_corr`)
- Layout: `RAPMUSIC_app.mlapp`
