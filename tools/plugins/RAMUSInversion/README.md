# RAMUSInversion

RAMUS (randomized multiresolution source space) hierarchical Bayes: IAS-style updates on several sparse coarsenings of the source grid, then combine. Use it for focal sources when single-resolution IAS is too smooth.

This plugin does **not** construct `inverse.RAMUSInverter`. Class id `ramus` (and `legacy_ramus`) is a separate `zef_inverse_run` track. The class path still needs a multiresolution decomposition (`zef_make_multires_dec`) first.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **RAMUS Inversion** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `zef_ramus_inversion_tool`.

Window title: `ZEFFIRO Interface: RAMUS Inversion`.

## Run the solver

**Start** (`zef.h_ramus_start`) Callback:

```matlab
zef_update_ramus_inversion_tool; [zef.reconstruction, zef.reconstruction_information] = zef_ramus_iteration(zef);
```

**Create multiresolution decomposition** (`zef.h_ramus_make_multires_dec`) builds `zef.ramus_multires_dec` / `_ind` / `_count` via `zef_make_multires_dec` — run that before Start if those fields are empty.

Each frame runs IAS MAP on every pair `(decomposition, level)`. Coarse lead-field columns are `L(:, mr_dec)` (xyz stacked when direction mode is 1 or 2). After `n_iter(j)` IAS steps the coarse `z` is scattered back with `mr_ind` and **summed**. The frame is then divided by `n_multires * n_decompositions * sum(sparsity_factor.^[0:n_multires-1])`. A level with `n_iter(j)==0` contributes zeros and zeros that level’s weight. `ramus_init_guess_mode == 2` (or the first decomposition) rebuilds `θ` from the hyperprior; otherwise `θ` is indexed from the previous coarsening.

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.ramus_snr` → `10^(-ramus_snr/20)`
- Frames: `zef.ramus_number_of_frames`, `ramus_time_*`, `ramus_sampling_frequency`, band edges (solver copies them onto `zef.inv_*`)
- Multires: `zef.ramus_multires_n_levels`, `ramus_multires_sparsity`, `ramus_multires_n_decompositions`, `ramus_multires_n_iter`
- Hyperprior: `zef.ramus_hyperprior` plus `zef.inv_prior_over_measurement_db`

## Writes

- `zef.reconstruction` after post-process / peak-norm
- `zef.reconstruction_information` with tag `RAMUS`

## Files

- Start: `m/zef_ramus_inversion_tool.m` → `zef_ramus_window`
- Solver: `m/zef_ramus_iteration.m`
