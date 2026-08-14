# MUSIC

MUSIC subspace scan: SVD of the data covariance, then score each lead-field column against the signal (or noise) subspace. Use it for a few focal sources when you want a subspace correlation map rather than a distributed inverse.

There is **no** `inverse.*Inverter` for MUSIC. Registry id `legacy_music` dispatches `MUSIC_iteration`.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **MUSIC** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `MUSIC_app_start` (script).

Window title in the `.mlapp`: `ZEFFIRO Interface: MUSIC`.

## Run the solver

**StartButton** `ButtonPushedFcn`:

```matlab
zef.reconstruction = MUSIC_iteration;
```

`Var_loc` (second output of `MUSIC_iteration`) is discarded. `reconstruction_information` is **not** assigned.

Types: `Source projection` / `Noise out-projection` → `zef.MUSIC_type`. Lead-field regularization: `Basic` / `Pseudoinverse` → `zef.MUSIC_L_reg_type`; ridge `zef.MUSIC_leadfield_lambda` (disabled for pseudoinverse).

Each frame first **means the time window to a single topography** (`mean(f,2)`), then builds `C = (f − mean(f,1))(·)' / size(f,2)`. After that mean, `f` is `n_sensors × 1`, so `C` is rank-1. The SVD signal subspace is therefore typically one-dimensional (empty `U` still errors if that singular value is below `10^(-inv_snr/20)^2 * max(f.^2)`). This is not a multi-snapshot data covariance.

Type 2 can return a complex generalized eigenvalue. The solver clamps `amp`, then if the eigenvector is complex it reconstructs a real orientation in the (Re, Im) plane with a 2×2 quadratic. That is not textbook complex-MUSIC. The real type-2 path stores `(1-amp)*orientation` (a perfect noise-space match is a null).

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.inv_snr` → `10^(-inv_snr/20)`; if the signal subspace is empty the solver errors `Given signal-to-noise ratio is too high!`
- Frames: `zef.number_of_frames`, `inv_time_*`, band edges
- Reads `zef` from the base workspace (`evalin`)

## Writes

- `zef.reconstruction` only (peak-normalized in the solver)

## Files

- Start: `MUSIC_app_start.m` constructs `MUSIC_app`
- Solver: `MUSIC_iteration.m`
- Layout: `MUSIC_app.mlapp`
