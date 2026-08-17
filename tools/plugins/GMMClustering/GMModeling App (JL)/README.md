# GMMClustering / GMModeling App (JL)

## Folder purpose

**Gaussian Mixture Model (JL)** Inverse-tools entry. Clusters an **existing** `zef.reconstruction` into Gaussian components for equivalent-dipole / ellipsoid plotting. Does **not** assemble `L` or invert. INI callback: `GMModelApp_start` in `m/BasicGMM/` (asteroid profiles may label it **GMM App**).

## Main contents

| Subfolder | Role |
|-----------|------|
| `m/BasicGMM/` | Start script, `zef_GMModeling_K`, plot/export |
| `m/AdvancedGMM/` | `zef_AdvGMModeling` plus vendor MathWorks GMM helpers (not Zeffiro APIs) |
| `mlapp/` | `GMModelApp.mlapp` and option/plot/export apps (`GMM_ModelingOpt`, `GMM_PlotOpt`, `GMMExport`) |

Legacy notes file `README` (no `.md`) documents v2.0 syntax for max components and plot colors.

## Code functionality

- **Start** (`GMModelApp_start`) calls `zef_AdvGMModeling` unless both advanced-option flags in `zef.GMM.parameters` are `'1'`, then `zef_GMModeling_K`.
- Needs Statistics Toolbox (`fitgmdist`).
- Outputs go to `zef.GMM.model` / `.dipoles` / `.amplitudes` / `.time_variables` — **not** `zef.reconstruction`.
- `plugins.ClassGMM` is unused from this GUI.

## Workflow context

Post-inverse clustering / visualization. Dual-GMM profiles also ship an SP-tool path; Dynamical plot queue bank has matching JL overlays (`zef_dpq_plot_GMM*`). Menu/parameters: [`../README.md`](../README.md).

## Usage instructions

1. Inverse tools → Gaussian Mixture Model (JL) / GMM App (profile-dependent label).
2. Set maximum component counts (time series: `3,3,3,2` or `3;3;3;2` or spaces).
3. Run modeling; use Advanced plot options for manual dipole/ellipsoid component order and colors (`[1,0,0],[0,1,0],…` or `'r','g',…`).

## Important notes

- Does not replace the reconstruction — it interprets an existing one.
- AdvancedGMM vendor helpers are not public Zeffiro APIs.

## Developer guidance

Keep INI callback `GMModelApp_start` stable. Document edit-field syntax in the legacy `README` when adding parsers. Prefer writing results only under `zef.GMM.*` so SP `zef.GMModel` overlays stay distinct.
