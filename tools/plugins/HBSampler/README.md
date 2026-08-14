# HBSampler

Hierarchical Bayes MCMC / Gibbs sampler on source variances (same gamma / inverse-gamma family as IAS, but posterior samples instead of a MAP point). Use it when you want a Monte Carlo reconstruction rather than IAS iterations.

There is **no** `inverse.*Inverter`. Registry ids `legacy_hb` / `legacy_mcmc` dispatch `zef_mcmc`.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Hierarchical Bayesian Sampler** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `hb_sampler`.

Window title (live, from `zef_open_mcmc` / `zef_mcmc_window`): `ZEFFIRO Interface: Hierarchical Bayesian MCMC sampler`.

The leftover GUIDE file `fig/hb_sampler.fig` is **not** opened by `hb_sampler.m`. Its saved Start string (`mcmc_sampler`) is not the live callback.

## Run the solver

**Start** (`zef.h_mcmc_start`) Callback, set in `zef_open_mcmc`:

```matlab
zef_update_mcmc; [zef.reconstruction, zef.reconstruction_information] = zef_mcmc(zef);
```

The window constructor also has a one-output form (`zef.reconstruction = zef_mcmc(zef)`); init overrides it to keep `reconstruction_information`.

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.inv_snr` → `10^(-inv_snr/20)`
- Frames: solver reads `zef.inv_number_of_frames` (the window widget writes `zef.number_of_frames` — keep those consistent)
- Sample size / burn-in: `zef.inv_sample_size`, `zef.inv_n_burn_in`
- Hyperprior: `zef.inv_hyperprior` plus `inv_prior_over_measurement_db`
- Parallel chains: `zef.parallel_processes` (opens or resizes a `parpool`). Outer loop is `ceil(inv_sample_size / parallel_processes)` Gibbs steps per chain (`zef_gibbs_sampler_step`). Burn-in is compared to that **outer index** `i`, not to the total sample count. The mean then divides by `n_iter_process*parallel_processes - n_burn_in`, which is **not** equal to the number of added vectors `(n_iter_process - n_burn_in)*parallel_processes`.

## Writes

- `zef.reconstruction` after post-process / peak-norm
- `zef.reconstruction_information` with tag `MCMC`

## Files

- Start: `m/hb_sampler.m` → `zef_open_mcmc` → `zef_mcmc_window`
- Solver: `m/zef_mcmc.m`
