## Folder purpose

Metropolized RAMUS: MCMC on the same multiresolution source space as RAMUS inversion. Use for posterior samples of a RAMUS-style model rather than the RAMUS MAP iteration. No `inverse.*Inverter` and no registry id.

## Main contents

| Path | Role |
|------|------|
| `m/ramus_sampler.m` | Opens `fig/ramus_sampler.fig` |
| `m/ramus_sampling_process.m` | Metropolis–Hastings sampler |
| `m/zef_init_ramus_sampler.m` / `m/zef_update_ramus_sampler.m` | Defaults / widgets |
| `fig/ramus_sampler.fig` | Window layout; Start / Create callbacks |

## Code functionality

Likelihood uses `zef.inv_likelihood_std` (a standard deviation), not `inv_snr`. Each draw picks a random RAMUS decomposition and (after the first draw, which always uses coarsest level `j=1`) a random level, runs `n_iter(j)` IAS MAP steps, then Metropolis–Hastings (`Δ log-posterior ≥ log U`). First draw always accepts. Samples of `z` after `inv_n_burn_in` are averaged into `zef.reconstruction`; `θ` is averaged over every draw (including rejections).

## Workflow context

**Not** in any profile `zeffiro_plugins.ini`. Related MAP GUI: `RAMUSInversion`. Needs `zef.L`, measurements, multires fields (`inv_multires_*`), and sampler counts (`inv_n_sampler`, `inv_n_burn_in`).

## Usage instructions

```matlab
ramus_sampler
```

Window title: `ZEFFIRO Interface: Metropolized RAMUS Sampler`. Start callback (in the fig):

```matlab
zef_update_ramus_sampler; zef.reconstruction = ramus_sampling_process([]);
```

**Apply** only runs `zef_update_ramus_sampler`.

## Important notes

- Fig **Create multiresolution decomposition** calls `make_multires_dec` (no such first-party function). Use `zef_make_multires_dec` or the RAMUS inversion Create button so `inv_multires_dec` / `_ind` exist.
- Start does not assign `reconstruction_information`.
- Reads `zef` from the base workspace.

## Developer guidance

Fix Create to call `zef_make_multires_dec`. Keep sampler math in `m/ramus_sampling_process.m`. Do not register in INI until Start/Create callbacks are patched and documented.
