# RAMUSSampler / m

MATLAB for the Metropolized RAMUS sampler. There is **no** INI row and no `inverse.*Inverter`. Open with `ramus_sampler` from MATLAB. User-facing Start / Create-decomposition buttons and required `zef` fields: [parent README](../README.md).

Likelihood uses `zef.inv_likelihood_std` (a standard deviation), **not** `inv_snr`. Each draw picks a random RAMUS decomposition and level, runs an inner IAS MAP, then Metropolis–Hastings (`Δ log-posterior ≥ log U(0,1)`). Samples after `inv_n_burn_in` are averaged into `zef.reconstruction`.

| File | Role |
|------|------|
| `ramus_sampler.m` | Opens `fig/ramus_sampler.fig` |
| `zef_init_ramus_sampler.m` / `zef_update_ramus_sampler.m` | Defaults / widgets |
| `ramus_sampling_process.m` | Sampler (`void` unused; reads base `zef`) |

## Unpatched (documented as written)

- Fig Start calls `ramus_sampling_process([])`. Create decomposition in the fig calls `make_multires_dec` (not `zef_make_multires_dec`).
- `zef_init_ramus_sampler`: if `inv_n_sampler` / `inv_n_burn_in` are missing, it writes `inv_multires_n_sampler` instead.
