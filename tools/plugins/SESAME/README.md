# SESAME

Stochastic sampling of discrete dipole configurations (SESAME). Use it when you want a small number of equivalent dipoles with posterior samples rather than a dense grid map.

There is **no** `inverse.*Inverter`. Registry id `legacy_sesame` dispatches `SESAME_inversion`. The Start button does not call `+inverse`.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | **not in this INI** |
| `_legacy`, `_nse` | **not in those INIs** |
| asteroid_radar | Inverse tools → **SESAME** |
| asteroid_gravity | Inverse tools → **SESAME** (INI row has a space after the comma: `SESAME, inverse_tools, SESAME_App_run`) |

INI callback: `SESAME_App_run` (script).

Window title: `ZEFFIRO Interface: SESAME App`.

`SESAME_App_run` calls `SESAME_core_check`, which `webread`s `inverse_SESAME.m` from `i-am-sorri/SESAME_core` **only if that file is missing** under `m/`. This tree already ships `m/inverse_SESAME.m`, so the download is a no-op unless you delete it. The sampler does not read `zef`; `SESAME_inversion` builds `cfg` and `leadfield` from the session.

## Run the solver

**h_start** `ButtonPushedFcn`:

```matlab
zef_update_SESAME; zef.reconstruction = SESAME_inversion([]);
```

**h_apply** only runs `zef_update_SESAME`. **h_plot_dipoles** runs `SESAME_plot_movie` (not the solver).

## Needs

- `zef.L`, `zef.source_positions`, interpolation
- `zef.measurements`
- SNR: `zef.SESAME_snr` → `cfg.noise_std = 10^(-SESAME_snr/20)`
- Sampler count: `zef.SESAME_n_sampler`
- Frames: `zef.number_of_frames`, `inv_time_*` (each frame can pass a time window of columns into `inverse_SESAME`)

`SESAME_inversion` indexes `source_positions(s_ind_1,:)` **before** `s_ind_1` is assigned (that name is not set in this file). The waitbar call uses MATLAB `waitbar(..., h, ...)` on a handle `h` that this file never creates (not `zef_waitbar`). Documented as written; do not treat Start as a working run until those lines are fixed.

Lead-field columns are reordered **node-wise** (`xyz` of source 1 adjacent) for `inverse_SESAME`, then the reconstruction is scattered back to Zeffiro’s Cartesian stacking (`s_back_ind`) before `zef_postProcessInverse`. Each estimated dipole’s moment is the **time-mean** of `QV_estimated` for that dipole.

## Writes

- `zef.reconstruction` (cell of 3-component source vectors; dipoles placed at sampled indices)
- Side effect: `zef.SESAME` and `zef.SESAME_time_serie{frame}` via `assignin('base',…)`
- Clears `zef.SESAME_time_serie` at the start of a run if it already exists

## Files

- Start: `m/SESAME_App_run.m`
- Solver: `m/SESAME_inversion.m`
- Layout: `mlapp/SESAME_App.mlapp`
