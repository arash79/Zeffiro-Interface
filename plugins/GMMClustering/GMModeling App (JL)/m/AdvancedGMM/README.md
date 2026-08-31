# GMMClustering (JL) — advanced modelling entry

## Folder purpose

Advanced Gaussian-mixture fitting used when the JL GMM app’s **advanced options** are on. Entry point `zef_AdvGMModeling` clusters an **existing** reconstruction; it does not invert `L`. Weighted EM is `inverse.gmm.FitAdvGMM` → `AdvGMModeling4Rec`. Progress uses MATLAB `waitbar` (not `zef_waitbar`).

## Main contents

| File | Role |
|------|------|
| `zef_AdvGMModeling.m` | Read `zef.GMM.parameters.Values` / `.Tags` from base, threshold and (optionally) parcel-restrict sources, call `inverse.gmm.FitAdvGMM`, return model / dipole positions / amplitudes / time vars |

## Code functionality

**Inputs (base `zef`):** `reconstruction`, `source_positions`, `GMM.parameters.Values` (cell of strings), optional `reconstruction_information` time stamps, optional parcellation fields when domain mode is 2.

**`FitAdvGMM` contract** (this file’s call): `positions` (N×D), per-row `weight`, component count `K`, plus name-values `Start`, `Replicates`, `CovarianceType` (`'full'`/`'diagonal'`), `SharedCovariance`, `RegularizationValue`, `Options` (`statset MaxIter`), `ProbabilityTolerance`. Too few points vs dimension raises a threshold/activity error from `FitAdvGMM`.

**Parameter cell indices used here** (strings in `zef.GMM.parameters.Values`; keep in sync with `zef_GMM_AdvModelingOpt`):

| Index / tag | Meaning |
|-------------|---------|
| `{1}` | `K` (scalar or vector of component counts) |
| `{2}` | `MaxIter` |
| `{3}` | `'1'` → full covariance, else diagonal |
| `{4}` | `'1'` → unshared covariances |
| `{5}` | Reconstruction amplitude threshold |
| `{15}` | Regularization value |
| `{17}` `{18}` | Time start / window length `T` when reconstructing a time series |
| `{21}` | Amplitude estimate type |
| `{22}` | Location vs location+orientation (`estim_param`) |
| Tag `'domain'` | `'2'` restricts to selected parcels via `parcellation_interp_ind` |
| `meta1+1`…`+6` | Model-selection criterion, initial mode, replicates, log-pdf threshold (dB), χ² `r_squared`, smooth std |

**Outputs:** `GMModel`, dipole positions, amplitudes, optional `GMModelTimeVariables` from `reconstruction_information`. Does not overwrite `zef.reconstruction`.

## Workflow context

```
GMModelApp Start (advanced on) → zef_AdvGMModeling → inverse.gmm.FitAdvGMM → zef.GMM
```

Basic path uses `../BasicGMM/zef_GMModeling_K.m` / `fitgmdist` instead. Decision-making studies often use **GMModel (SP)** `zef_cluster_reconstruction`, not this file.

## Usage instructions

Prefer the JL app UI. Programmatic (session in base):

```matlab
[GMModel, dips, amps, tvar] = zef_AdvGMModeling;
```

Requires reconstruction already in base `zef`.

## Important notes

- EM helpers are `inverse.gmm.*`, not files in this folder.
- Domain mode 2 needs a populated parcellation interpolant.
- `K` as a column is transposed to a row before fitting.

## Developer guidance

- Change EM math in `+inverse/+gmm`, not here.
- When adding options, update `zef.GMM.parameters.Values` **and** the index/tag table above in the same change as `zef_GMM_AdvModelingOpt`.
- Pitfall: treating this as an inverse solver — it never reads `zef.L`.
