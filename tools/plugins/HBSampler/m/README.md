# HBSampler / m

Inverse tools → **Hierarchical Bayesian Sampler**. Gibbs / MCMC on source variances (same hyperprior family as IAS, samples instead of a MAP point). Registry ids `legacy_hb` / `legacy_mcmc` call `zef_mcmc`. There is no `inverse.*Inverter`.

User manual: [parent README](../README.md). The leftover `fig/hb_sampler.fig` is not opened by `hb_sampler.m`.

| File | Role |
|------|------|
| `hb_sampler` | INI callback → `zef_tool_start(..., 'zef_open_mcmc', …)` |
| `zef_open_mcmc` | Builds `zef_mcmc_window`, defaults, Start → `zef_update_mcmc; [zef.reconstruction, zef.reconstruction_information] = zef_mcmc(zef)` |
| `zef_mcmc_window` | GUIDE figure dump |
| `zef_update_mcmc` | Widgets → `inv_hyperprior` / snr / burn-in / band / `inv_number_of_frames` |
| `zef_mcmc` | Per-frame Gibbs; tag MCMC; frames from `inv_number_of_frames` (keep in sync with `number_of_frames`) |
| `zef_gibbs_sampler_step` | One update of source `x` and variance `theta` |
