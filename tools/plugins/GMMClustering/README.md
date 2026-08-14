# GMMClustering

Gaussian-mixture clustering of an **existing** reconstruction (JL app). Same job as GMModel (SP): fit components, optional plot/export. Not an inverse solver.

`plugins.ClassGMM` is unused from this GUI.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Gaussian Mixture Model (JL)** |
| `_legacy`, `_nse` | Inverse tools → **Gaussian Mixture Model (JL)** |
| asteroid_radar / asteroid_gravity | Inverse tools → **GMM App** |

INI callback: `GMModelApp_start` (script under `GMModeling App (JL)/m/BasicGMM/`).

Window title: `ZEFFIRO Interface: Gaussian Mixature Model`.

`GMMclustering_app.mlapp` and `zef_GMMcluster.m` at the plugin root are **not** referenced by any `zeffiro_plugins.ini`. Call `zef_GMMcluster` from MATLAB if you need that older entry.

## Run clustering

**StartButton** `ButtonPushedFcn`:

```matlab
if ~strcmp(zef.GMM.parameters.Values{zef.GMM.meta{1}+1},'1') || ~strcmp(zef.GMM.parameters.Values{zef.GMM.meta{1}+2},'1')
    [zef.GMM.model,zef.GMM.dipoles,zef.GMM.amplitudes,zef.GMM.time_variables] = zef_AdvGMModeling;
else
    [zef.GMM.model,zef.GMM.dipoles,zef.GMM.amplitudes,zef.GMM.time_variables] = zef_GMModeling_K;
end
```

**PlotModelButton** / **PlotAmpButton** call `zef_PlotGMModel` / `zef_plot_GMM_amplitudes` after `zef_update_GMMPlotOpts`. They do not fit a new model.

Vendor MathWorks helpers under `m/AdvancedGMM/` (`estep`, `FitAdvGMM`, `EstepWeight`, …) are not first-party solvers; do not treat them as Zeffiro APIs.

## Needs

- `zef.reconstruction` (empty reconstruction warns and does nothing useful)
- `zef.source_positions`; optional parcellation when domain parameter is 2
- Options in `zef.GMM.parameters` (component count, covariance type, frames, threshold, …)
- Statistics Toolbox (`fitgmdist` path)

## Writes

- `zef.GMM.model`, `zef.GMM.dipoles`, `zef.GMM.amplitudes`, `zef.GMM.time_variables`
- Does **not** overwrite `zef.reconstruction`

## Files

- Start: `GMModeling App (JL)/m/BasicGMM/GMModelApp_start.m`
- Solvers: `zef_GMModeling_K.m`, `zef_AdvGMModeling.m`
- Layout: `GMModeling App (JL)/mlapp/GMModelApp.mlapp`
