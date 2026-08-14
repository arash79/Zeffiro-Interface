# RAMUSSampler

Metropolized RAMUS: MCMC on the same multiresolution source space as RAMUS inversion. Use it when you want posterior samples of a RAMUS-style model rather than the RAMUS MAP iteration.

There is **no** `inverse.*Inverter` and no registry id for this plugin. The folder is **not** in any profile `zeffiro_plugins.ini`.

## Menu

Not in default INI and not in asteroid / `_legacy` / `_nse` INIs. From MATLAB:

```matlab
ramus_sampler
```

Window title: `ZEFFIRO Interface: Metropolized RAMUS Sampler`.

## Run the sampler

**Start** Callback stored in `fig/ramus_sampler.fig` (not reassigned in `m/`):

```matlab
zef_update_ramus_sampler; zef.reconstruction = ramus_sampling_process([]);
```

**Create multiresolution decomposition** in the same fig calls `make_multires_dec` (not `zef_make_multires_dec`). **Apply** only runs `zef_update_ramus_sampler`.

Likelihood uses `zef.inv_likelihood_std` (a standard deviation), not `inv_snr`. Each draw picks a random RAMUS decomposition and level, proposes `z`/`theta`, and accepts with Metropolis–Hastings (`Δ log-posterior ≥ log U`). Samples after `inv_n_burn_in` are averaged.

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- `zef.inv_likelihood_std`, `inv_beta`, `inv_theta0`, `inv_hyperprior`
- Sampler: `zef.inv_n_sampler`, `zef.inv_n_burn_in`
- Multires: `inv_multires_n_levels`, `inv_multires_sparsity`, `inv_multires_n_decompositions`, `inv_multires_n_iter`
- Frames: `zef.number_of_frames`, `inv_time_*`, band edges
- Reads `zef` from the base workspace

## Writes

- `zef.reconstruction` only (Start does not assign `reconstruction_information`)

## Files

- Start: `m/ramus_sampler.m` opens `fig/ramus_sampler.fig`
- Solver: `m/ramus_sampling_process.m`
