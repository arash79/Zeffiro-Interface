# HBSampler / m

## Folder purpose

MATLAB files for Inverse tools → **Hierarchical Bayesian Sampler**. Gibbs / MCMC on source variances (same hyperprior family as IAS, samples instead of a MAP point). Registry ids `legacy_hb` / `legacy_mcmc` call `zef_mcmc`. There is no `inverse.*Inverter`.

## Main contents

| File | Role |
|------|------|
| `hb_sampler.m` | INI callback → `zef_tool_start(..., 'zef_open_mcmc', …)` |
| `zef_open_mcmc.m` | Builds `zef_mcmc_window`, defaults; Start → `zef_update_mcmc` then `zef_mcmc` |
| `zef_mcmc_window.m` | GUIDE figure dump |
| `zef_update_mcmc.m` | Widgets → `inv_hyperprior` / snr / burn-in / band / `inv_number_of_frames` |
| `zef_mcmc.m` | Per-frame Gibbs; tag MCMC; frames from `inv_number_of_frames` |
| `zef_gibbs_sampler_step.m` | One update of source `x` and variance `theta` |

## Code functionality

- Opens **ZEFFIRO Interface: Hierarchical Bayesian MCMC sampler** (not leftover `fig/hb_sampler.fig`).
- Defaults include `inv_hyperprior=2`, `inv_sample_size=25`, `n_burn_in=1`.
- Start writes `[zef.reconstruction, zef.reconstruction_information] = zef_mcmc(zef)`.
- Needs `zef.L` and `zef.measurements`.

## Workflow context

Available on default and asteroid profile plugin lists via `hb_sampler`. User manual: parent [`../README.md`](../README.md). Complements MAP IAS tools with sampling of the hierarchical prior.

## Usage instructions

1. Inverse tools → Hierarchical Bayesian Sampler (or `hb_sampler`).
2. Set hyperprior / sample size / burn-in / frames; keep `inv_number_of_frames` in sync with `number_of_frames`.
3. **Start** runs the Gibbs sampler into reconstruction fields.

## Important notes

- `hb_sampler.m` does not open `fig/hb_sampler.fig`.
- Frame-count fields must stay consistent or only a subset of frames is sampled.

## Developer guidance

Keep Start callback wiring in `zef_open_mcmc` aligned with `zef_mcmc` outputs. When changing Gibbs step parameterization, document widget field names in `zef_update_mcmc`. Prefer registry ids `legacy_hb` / `legacy_mcmc` remaining pointed at `zef_mcmc`.
