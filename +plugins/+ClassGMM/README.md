# `plugins.ClassGMM` — GMM on reconstructions

## Folder purpose

**Gaussian-mixture clustering** of an existing inverse reconstruction (spatial, optionally orientation). Used after a class inverter has produced sources; **not** a registry inverse method. Requires Statistics Toolbox (`fitgmdist` / EM).

## Main contents

| File | Role |
|------|------|
| `ClassGMModeling.m` | Public entry: fit GMM, model selection, store on `MethodClassObj.GMM` |
| `FitAdvGMM.m` | Weighted EM driver |
| `AdvGMModeling4Rec.m` | Core reconstruction-weighted EM loop |
| `estep.m` / `EstepWeight.m` | E-step variants |
| `WeightedCondDensity.m` | Component densities |

GUI parallel copies exist under `tools/plugins/GMMClustering/.../AdvancedGMM` and may drift.

## Code functionality

Typical call from a class object that already ran invert:

```matlab
MethodClassObj = plugins.ClassGMM.ClassGMModeling(MethodClassObj, reconstruction, zef, ...
    "number_of_clusters", 3, ...
    "sought_estimate", "Location & orientation", ...
    "model_selection_criterion", "Bayesian information criterion");
```

**Name-values (defaults):** `number_of_clusters=3`, `sought_estimate="Location & orientation"`, `covariance_type="full"`, `MaxIter=1000`, `reconstruction_threshold=0.25`, `regularization_parameter=1e-2`, BIC or fixed-K selection, optional parcellation restriction, frame sub-range.

Needs `zef.source_positions` (and parcellation fields if enabled). Opens a waitbar.

## Workflow context

```
inverse.*Inverter → reconstruction → CommonInverseParameters.computeGMM → ClassGMModeling
```

`computeGMM` exists on the base class but may have few live GUI callers today. Studies often use legacy `zef_cluster_reconstruction` (GMModel SP) instead.

## Usage instructions

```matlab
inv = inverse.ELORETAInverter();
[zef, inv] = inv.computeInversionWithZI(zef);
inv = inv.computeGMM(zef);   % if wired on your branch
% or call ClassGMModeling directly as above
```

## Important notes

- Not listed in `inverse_method_registry` as an inverse id.
- JL GUI advanced path duplicates these helpers under the plugin tree.
- Thresholding and smoothing parameters strongly affect cluster count stability.

## Developer guidance

- Consolidate plugin AdvancedGMM with this package before feature work.
- Add a unit test with synthetic multi-blob reconstructions when changing EM.
- Keep `MethodClassObj.GMM` schema documented for export tools.
