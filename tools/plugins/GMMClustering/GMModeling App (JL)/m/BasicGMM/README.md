# BasicGMM (GMMClustering JL app)

## Folder purpose

Core MATLAB for the **Gaussian Mixture Model (JL)** App Designer plugin: fit GMMs to an existing `zef.reconstruction`, plot dipoles/ellipsoids, export/load `.mat`. Inverse tools → Gaussian Mixture Model (JL). Not an L-inverse solver and not `plugins.ClassGMM`.

## Main contents

| File | Role |
|------|------|
| `GMModelApp_start.m` | INI entry; constructs `GMModelApp`, defaults, Start |
| `zef_GMModeling_K.m` | Basic `fitgmdist` path |
| `zef_GMModeling.m` | Alternate/full fit path |
| `GMM2amplitude.m` | Component amplitudes from `zef.L` |
| `zef_PlotGMModel.m` / `zef_plot_GMM_amplitudes.m` | Visualization |
| `zef_GMMPlotOpt.m` / `zef_update_GMMPlotOpts.m` | Plot options app |
| `zef_GMM_AdvModelingOpt.m` | Advanced modeling options |
| `zef_GMMExport_start.m` / `zef_GMM_export.m` / `zef_load_GMM.m` | I/O |
| `zef_GMM_update.m` / `zef_GMM_subs_time_vars.m` | Parameter sync / time vars |

## Code functionality

- StartButton (in `GMModelApp_start`): if advanced criterion/init ≠ defaults → `zef_AdvGMModeling`, else `zef_GMModeling_K`; results → `zef.GMM.model`, `.dipoles`, `.amplitudes`, `.time_variables`.
- Parameters live in `zef.GMM.parameters` (table Tags/Values); `meta{1}` / `meta{2}` mark modeling vs plot option offsets.
- Fit uses reconstruction threshold, K, covariance type/identity, optional parcellation domain (`domain` tag `'2'`), `GMM2amplitude` for strengths.
- Plot reads `zef.GMM.model` / `.dipoles` and may call `zef_visualize_surfaces`.

## Workflow context

Run after any inverse that fills `zef.reconstruction` and `zef.source_positions`. Optional: parcellation selection for domain restriction. Overlay via Dynamical plot queue bank scripts that read `zef.GMM`.

## Usage instructions

1. Have a reconstruction on `zef`.
2. Open GMM (JL) → `GMModelApp_start`.
3. Set K, threshold, frames, covariance options; optional ModelingOpt / PlotOpt.
4. Start; Plot Model / amplitudes; Export selected components via Export app.

## Important notes

- Requires Statistics Toolbox (`fitgmdist`) and often Optimization Toolbox (`lsqlin` in amplitude type 1).
- Advanced Start depends on `zef_AdvGMModeling` living outside this BasicGMM folder.
- Closing/reopening main app is handled at start if `zef.GMM.apps.main` is valid.

## Developer guidance

Keep Tag order consistent with uilabel/widget walks in `zef_GMM_update`. New options should extend `parameters.Tags` and `meta` indices carefully. Prefer writing results only under `zef.GMM.*`; do not overwrite `zef.reconstruction` unless export/load explicitly requests it.
