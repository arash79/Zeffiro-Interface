# `+plugins/+ClassGMM` — GMM clustering on reconstructions

Fits a Gaussian mixture to an inverse reconstruction (spatial, optionally orientation). Used after a class inverter has produced `reconstruction`; it is **not** a registry inverse method. Statistics Toolbox (`fitgmdist` / EM internals) is required.

Typical call from a class object that already ran invert:

```matlab
MethodClassObj = plugins.ClassGMM.ClassGMModeling(MethodClassObj, reconstruction, zef, ...
    "number_of_clusters", 3, ...
    "sought_estimate", "Location & orientation", ...
    "model_selection_criterion", "Bayesian information criterion");
% results stored on MethodClassObj.GMM
```

## `ClassGMModeling` name-values

| Name | Default | Meaning |
|------|---------|---------|
| `number_of_clusters` | 3 | `K` or candidate counts |
| `sought_estimate` | `"Location & orientation"` | or `"Location"` |
| `covariance_type` | `"full"` | or `"diagonal"` |
| `MaxIter` | 1000 | EM cap |
| `reconstruction_threshold` | 0.25 | Amplitude cutoff |
| `regularization_parameter` | 1e-2 | Covariance ridge |
| `SharedCovariance` | false | |
| `use_selected_parcellations` | false | Restrict to selected parcels |
| `amplitude_estimation_type` | `"Point density"` | or ML / MAP |
| `model_selection_criterion` | `"Bayesian information criterion"` | or given K / L2 density error |
| `initial_cluster_finding_approach` | `"Maximum component-wise fit"` | or k-means++ / max probability |
| `number_of_replicates` | 1 | |
| `log_posterior_threshold_dB` | 6 | |
| `reconstruction_smoothing_std` | 0 | |
| `mixture_component_probability` | 0.95 | |
| `start_frame` / `stop_frame` | empty | Sub-range of a cell reconstruction |

Needs `zef.source_positions` (and parcellation fields if that flag is on). Opens a waitbar.

## Numerical kernels

| File | Role |
|------|------|
| `FitAdvGMM` | Weighted EM wrapper (`positions`, `weight`, `k`, FITGMDIST-style name-values) |
| `AdvGMModeling4Rec` | Advanced GMM fit used for reconstructions |
| `estep` / `EstepWeight` | E-step posteriors / weighted update |
| `WeightedCondDensity` | Component log-likelihoods |

These are not user-facing inverse ids. Focal-epilepsy study scripts use **legacy** GMM GUI paths, not necessarily this package.
