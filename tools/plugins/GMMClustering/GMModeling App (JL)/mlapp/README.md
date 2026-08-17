# tools/plugins/GMMClustering/GMModeling App (JL)/mlapp

## Folder purpose

App Designer fronts for the JL **GMM Modeling** cluster of the GMMClustering plugin (model options, plot options, export, main app).

## Main contents

| File | Role |
|------|------|
| `GMModelApp.mlapp` | Main GMM modeling UI |
| `GMM_ModelingOpt.mlapp` | Modeling options |
| `GMM_PlotOpt.mlapp` | Plot options |
| `GMMExport.mlapp` | Export dialog |

Algorithms / bank code: sibling `../m` (BasicGMM / AdvancedGMM).

## Code functionality

Apps collect GMM hyperparameters and plot/export choices; MATLAB code under `m/` fits models and writes into Data Bank / `zef` GMM fields when wired by the plugin start scripts.

## Workflow context

Often used after an inverse reconstruction to cluster activity; may integrate with Data Bank entry type `gmm`. Profile menus vary.

## Usage instructions

Open via the GMMClustering / GMModeling start entry registered in the active profile (see parent plugin README). Do not expect these `.mlapp` files to run standalone without the plugin path and `zef`.

## Important notes

- JL app tree is one of possibly several GMM UIs in the plugin.
- Large fits can be memory-heavy.

## Developer guidance

- Keep option field names aligned with `m/` readers.
- Pitfall: exporting without checking coordinate units vs the mesh.
