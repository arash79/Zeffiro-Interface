# GMMClustering (JL) — `m/` container

## Folder purpose

Parent folder for the **Gaussian Mixture Model (JL)** app’s MATLAB logic. The Inverse-tools entry **Gaussian Mixture Model (JL)** / **GMM App** clusters an **existing** `zef.reconstruction` into Gaussian components for equivalent-dipole / ellipsoid visualization and export. It does **not** assemble a lead field or invert measurements. Advanced fitting calls `inverse.gmm.FitAdvGMM`.

This `m/` level has **no** loose `.m` files: code is split into `BasicGMM/` (default Start path) and `AdvancedGMM/` (`zef_AdvGMModeling`, which calls `inverse.gmm`). App Designer layouts live in the sibling `../mlapp/` folder.

## Main contents

| Subfolder / item | Role |
|------------------|------|
| `BasicGMM/` | Default path: `GMModelApp_start`, `zef_GMModeling_K`, plot/export/update helpers |
| `BasicGMM/GMModelApp_start.m` | INI callback — constructs `GMModelApp`, seeds `zef.GMM.parameters` |
| `BasicGMM/zef_GMModeling_K.m` | Basic modelling (`fitgmdist`-style) when advanced flags are off |
| `BasicGMM/zef_PlotGMModel.m` / `zef_plot_GMM_amplitudes.m` | Visualization |
| `BasicGMM/zef_GMM_export.m` / `zef_GMMExport_start.m` | Export pipeline |
| `BasicGMM/zef_load_GMM.m` / `GMM2amplitude.m` / time-var helpers | Load / amplitude / frame bookkeeping |
| `AdvancedGMM/` | `zef_AdvGMModeling` (weighted EM via `inverse.gmm.FitAdvGMM`) |
| `README.md` | This documentation |
| `BasicGMM/README.md` / `AdvancedGMM/README.md` | Child package notes |

App layouts: `../mlapp/` (`GMModelApp.mlapp`, modelling / plot / export option apps). Parent plugin overview: `../../README.md` and `../README.md`.

## Code functionality

**Entry.** `GMModelApp_start` closes any existing `zef.GMM.apps.main`, constructs `GMModelApp`, and initializes `zef.GMM.parameters` (max components, regularization, reconstruction threshold, iterations, confidence, covariance options, etc.).

**Start modelling.** Depending on advanced-option flags in `zef.GMM.parameters`, Start runs either:

- `zef_AdvGMModeling` (advanced path), or
- `zef_GMModeling_K` when both advanced flags are `'1'` (basic path — see start-script branch comments).

**Inputs.** Needs Statistics Toolbox (`fitgmdist` and related) and a populated `zef.reconstruction` (post-inverse).

**Outputs.** Results go under **`zef.GMM.*`** (`model`, `dipoles`, `amplitudes`, `time_variables`, apps handles) — **not** into `zef.reconstruction`. Plot/export apps read those fields. Dynamical plot queue banks may overlay JL GMM visuals via `zef_dpq_plot_GMM*` helpers elsewhere in the tree.

## Workflow context

```
Inverse tools → Gaussian Mixture Model (JL) / GMM App
        → GMModelApp_start  (this tree, BasicGMM/)
        → GMModelApp.mlapp  (../mlapp/)
        → zef_GMModeling_K  or  zef_AdvGMModeling
        → zef.GMM.*
```

| Related tool | Distinction |
|--------------|-------------|
| `plugins/GMModel` (SP) | Simpler SP GMM tool; some studies use it instead of JL |
| `inverse.gmm` | Weighted EM used by advanced Start (`FitAdvGMM`) |
| Inverse solvers | Produce `zef.reconstruction`; this app only interprets it |

Asteroid profiles may label the menu **GMM App**; callback name remains `GMModelApp_start`.

## Usage instructions

```matlab
GMModelApp_start;   % or Inverse tools → Gaussian Mixture Model (JL)
```

Typical interactive flow:

1. Run an inverse method so `zef.reconstruction` exists.
2. Open the JL GMM app; set maximum component counts (e.g. `3,3,3,2` for frames).
3. Configure threshold / covariance / confidence; optionally open Advanced modelling options.
4. Start modelling; inspect dipoles/ellipsoids; export if needed via GMM export app.
5. Use Advanced plot options for manual component order and colors (`[1,0,0],…` or `'r','g',…`).

Programmatic plotting helpers (after a fit):

```matlab
zef_PlotGMModel;
zef_plot_GMM_amplitudes;
```

## Important notes

- JL vs SP: do not assume `zef.GMM` and SP `zef.GMModel` overlays share the same struct layout.
- Not an inverse solver — empty or missing reconstruction fails modelling.
- Weighted EM is `inverse.gmm`; do not add a second copy of those helpers under this plugin.
- Closing/reopening should go through `GMModelApp_start` so stale `zef.GMM.apps.main` handles are cleared.
- Requires Statistics and Machine Learning Toolbox for `fitgmdist`.

## Developer guidance

- Keep Basic vs Advanced option flags clearly documented in the ModellingOpt app and in `BasicGMM` READMEs.
- Avoid adding another GMM EM implementation under this plugin.
- Preserve INI callback name **`GMModelApp_start`**.
- Prefer writing results only under `zef.GMM.*` so SP overlays stay distinct.
- Keep EM math in `+inverse/+gmm` so the GUI and class paths stay in sync.
