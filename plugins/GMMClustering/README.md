## Folder purpose

Gaussian-mixture clustering of an **existing** reconstruction (JL app). Same job as GMModel (SP): fit components, optional plot/export. Not an inverse solver.

## Main contents

- Start: `GMModeling App (JL)/m/BasicGMM/GMModelApp_start.m`
- Solvers: `zef_GMModeling_K.m`, `zef_AdvGMModeling.m`
- Layout: `GMModeling App (JL)/mlapp/GMModelApp.mlapp`

## Code functionality

**StartButton** `ButtonPushedFcn`:

```matlab
if ~strcmp(zef.GMM.parameters.Values{zef.GMM.meta{1}+1},'1') || ~strcmp(zef.GMM.parameters.Values{zef.GMM.meta{1}+2},'1')
    [zef.GMM.model,zef.GMM.dipoles,zef.GMM.amplitudes,zef.GMM.time_variables] = zef_AdvGMModeling;
else
    [zef.GMM.model,zef.GMM.dipoles,zef.GMM.amplitudes,zef.GMM.time_variables] = zef_GMModeling_K;
end
```

**PlotModelButton** / **PlotAmpButton** call `zef_PlotGMModel` / `zef_plot_GMM_amplitudes` after `zef_update_GMMPlotOpts`. They do not fit a new model.

Weighted EM for the advanced Start path is `inverse.gmm.FitAdvGMM`.

Needs: `zef.reconstruction` (empty reconstruction warns and does nothing useful); `zef.source_positions`; optional parcellation when the **domain** parameter is `'2'` (union of selected `parcellation_interp_ind`). `'1'` uses the full source space. Amplitudes below the threshold are dropped; remaining values are rounded to integer counts so `fitgmdist` sees more samples near peaks. Optional Gaussian spatial smooth (`smooth_std`) runs first. `estim_param` 1 fits `(x,y,z, polar, azimuth)`; 2 fits xyz only. Options in `zef.GMM.parameters` (component count, covariance type, frames, threshold, …). Statistics Toolbox (`fitgmdist` path).

Writes: `zef.GMM.model`, `zef.GMM.dipoles`, `zef.GMM.amplitudes`, `zef.GMM.time_variables`. Does **not** overwrite `zef.reconstruction`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Gaussian Mixture Model (JL)** |
| `_legacy`, `_nse` | Inverse tools → **Gaussian Mixture Model (JL)** |
| asteroid_radar / asteroid_gravity | Inverse tools → **GMM App** |

INI callback: `GMModelApp_start` (script under `GMModeling App (JL)/m/BasicGMM/`). Window title: `ZEFFIRO Interface: Gaussian Mixture Model (JL)`. Advanced Start uses `inverse.gmm.FitAdvGMM`.

## Usage instructions

1. Ensure `zef.reconstruction` is filled.
2. Open Inverse tools → Gaussian Mixture Model (JL) / GMM App.
3. Press Start to fit; use PlotModel / PlotAmp for visualization only.

## Important notes

- Not an inverse solver; does not overwrite `zef.reconstruction`.
- Window title: `ZEFFIRO Interface: Gaussian Mixture Model (JL)`.

## Developer guidance

Preserve callback `GMModelApp_start` and outputs on `zef.GMM.*`. Advanced Start uses `inverse.gmm.FitAdvGMM`.
