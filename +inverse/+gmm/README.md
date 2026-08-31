# `inverse.gmm` — GMM on reconstructions

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

GUI advanced Start calls `inverse.gmm.FitAdvGMM` from `zef_AdvGMModeling`.

## Code functionality

Typical call from a class object that already ran invert:

```matlab
MethodClassObj = inverse.gmm.ClassGMModeling(MethodClassObj, reconstruction, zef, ...
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

`computeGMM` is the class wrapper around `ClassGMModeling`. GUI clustering still uses the GMModel / GMMClustering plugins (`zef_cluster_reconstruction` on the SP path; `inverse.gmm.FitAdvGMM` on the JL advanced Start path).

## Usage instructions

```matlab
inv = inverse.ELORETAInverter();
[zef, inv] = inv.computeInversionWithZI(zef);
inv = inv.computeGMM("reconstruction", zef.reconstruction, "zef", zef);
```

## Important notes

- Not listed in `inverse_method_registry` as an inverse id.
- JL GUI advanced Start calls `inverse.gmm.FitAdvGMM`.
- Thresholding and smoothing parameters strongly affect cluster count stability.

## Developer guidance

- Keep EM math in this package; the JL GUI advanced path calls `FitAdvGMM` here.
- Add a unit test with synthetic multi-blob reconstructions when changing EM.
- Keep `MethodClassObj.GMM` schema documented for export tools.
