# GMMClustering (JL) — AdvancedGMM helpers

## Folder purpose

**Advanced Gaussian-mixture fitting** used when the JL GMM app’s advanced options are enabled. Entry point `zef_AdvGMModeling` plus vendor-style EM helpers. Clusters an existing reconstruction; does not invert `L`.

## Main contents

| File | Role |
|------|------|
| `zef_AdvGMModeling.m` | First-party entry: read `zef.GMM.parameters`, fit, return model / dipoles / amplitudes / time vars |
| `FitAdvGMM.m` | Weighted / advanced GMM fit driver |
| `AdvGMModeling4Rec.m` | Core EM loop for reconstruction-weighted samples |
| `estep.m`, `EstepWeight.m` | E-step (standard / weighted) |
| `WeightedCondDensity.m` | Component conditional densities |

Parallel API for class inverters: `+plugins/+ClassGMM` (not always called from this GUI).

## Code functionality

Reads `zef.reconstruction`, `zef.source_positions`, and GMM parameter cells from base. Uses MATLAB `statset` / mixture fitting. Progress via MATLAB `waitbar` (not `zef_waitbar`).

**Outputs:** `GMModel`, dipole positions, amplitudes, optional time metadata from `reconstruction_information`.

## Workflow context

```
GMModelApp Start (advanced on) → zef_AdvGMModeling → stores into zef.GMM
```

Basic path uses `BasicGMM/zef_GMModeling_K.m` / `fitgmdist` instead.

## Usage instructions

Prefer the JL app UI. Programmatic:

```matlab
[GMModel, dips, amps, tvar] = zef_AdvGMModeling;
```

Requires reconstruction already in base `zef`.

## Important notes

- Vendor helpers are not public Zeffiro APIs — treat as internal.
- Duplicates concepts from `plugins.ClassGMM` — risk of drift.
- Decision-making studies often use **GMModel (SP)** `zef_cluster_reconstruction` instead.

## Developer guidance

- Consolidate with `+plugins/+ClassGMM` before large feature work.
- Switch waitbar to `zef_waitbar` for consistent logging when touching this code.
- Document `zef.GMM.parameters.Values` cell indices when adding options.
