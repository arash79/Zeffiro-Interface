# HBSampler — leftover GUIDE layout (`fig/`)

## Folder purpose

Holds the archived GUIDE resource **`hb_sampler.fig`** for the **Hierarchical Bayesian Sampler** plugin. The live Inverse-tools path does **not** load this file: menu callback `hb_sampler` builds the window programmatically via `zef_open_mcmc` → **`zef_mcmc_window`**. Keep this folder only as historical layout reference while the MCMC Gibbs sampler remains the in-menu Monte Carlo inverse tool.

## Main contents

| File | Role |
|------|------|
| `hb_sampler.fig` | Leftover GUIDE figure (not opened by current start) |
| `README.md` | This documentation |

Live UI construction and solver wiring live under `../m/` (`hb_sampler`, `zef_open_mcmc`, `zef_mcmc_window`, `zef_mcmc`, `zef_update_mcmc`, `zef_gibbs_sampler_step`).

## Code functionality

Parent plugin runs hierarchical Bayes MCMC / Gibbs sampling on source variances (same gamma / inverse-gamma family as IAS, but posterior samples instead of a MAP point). Live Start (set in `zef_open_mcmc`) runs:

```matlab
zef_update_mcmc; [zef.reconstruction, zef.reconstruction_information] = zef_mcmc(zef);
```

Window title (live): **ZEFFIRO Interface: Hierarchical Bayesian MCMC sampler**. Tag written into `reconstruction_information`: `MCMC`. The saved Start string inside `hb_sampler.fig` (`mcmc_sampler`) is stale and must not be treated as the live callback.

## Workflow context

Parent plugin: `tools/plugins/HBSampler`. INI callback in every default/asteroid profile: Inverse tools → **Hierarchical Bayesian Sampler** → `hb_sampler`. Needs `zef.L` and `zef.measurements`. There is no `inverse.*Inverter`; registry ids `legacy_hb` / `legacy_mcmc` dispatch `zef_mcmc`.

## Usage instructions

Do **not** `open('hb_sampler.fig')` for normal use. Launch the live tool:

```matlab
zef = hb_sampler(zef);   % → zef_tool_start(..., 'zef_open_mcmc', ...) → zef_mcmc_window
```

Or use Inverse tools → Hierarchical Bayesian Sampler. Set sample size, burn-in, SNR, and parallel processes, then Start.

## Important notes

- Real figure file in this folder: **`hb_sampler.fig`** (leftover).
- Start scripts users should know: **`hb_sampler`** (menu) and **`zef_mcmc_window`** (actual window builder via `zef_open_mcmc`).
- Parent plugin purpose: Monte Carlo hierarchical Bayesian reconstruction into `zef.reconstruction`.
- Burn-in is compared to the outer parallel-loop index; keep `inv_number_of_frames` and `number_of_frames` consistent.
- Deleting `hb_sampler.fig` would not break the live menu path, but archive it until a deliberate cleanup.

## Developer guidance

- Preserve INI callback `hb_sampler`, Start override in `zef_open_mcmc`, and tag `MCMC`.
- If porting to App Designer, replace `zef_mcmc_window` construction — do not revive GUIDE edits to this `.fig`.
- Do not re-wire Start to the stale `mcmc_sampler` string stored in the leftover figure.
