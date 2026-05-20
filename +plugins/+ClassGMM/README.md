# +ClassGMM — Gaussian Mixture Model Clustering for Source Reconstruction

This package implements a **weighted Gaussian mixture model (GMM)** framework for clustering brain source reconstructions into discrete, interpretable dipolar sources. It extends standard GMM fitting to use observation weights (e.g., current density magnitudes), making it suitable for inverse solutions.

## Overview

Given a spatial reconstruction (or a time series of reconstructions), the GMM models the active source space as a mixture of K Gaussian components. Each component represents a cluster of sources with:

- **Mean (μ):** Spatial location and optionally orientation (spherical angles)
- **Covariance (Σ):** Spatial (and orientational) spread
- **Mixing proportion (π):** Relative contribution of the cluster

The fit is performed via the **Expectation-Maximization (EM)** algorithm with a weighted likelihood to account for source intensity.

## Files

| File | Description |
|------|-------------|
| `ClassGMModeling.m` | Main entry point: fits GMM to reconstruction, handles time frames, model selection, amplitude estimation |
| `AdvGMModeling4Rec.m` | Core weighted GMM fitting engine with multiple initialization methods and replicate handling |
| `FitAdvGMM.m` | Wrapper around AdvGMModeling4Rec; parses options and returns a GMM object compatible with gmdistribution interface |
| `estep.m` | E-step: computes posterior probabilities and log-likelihood |
| `EstepWeight.m` | Updates observation weights for weighted GMM (optimizes exponent α) |
| `WeightedCondDensity.m` | Computes log component-conditional densities and Mahalanobis distances |

## Key Parameters (via `ClassGMModeling` args)

- `number_of_clusters` — Number of GMM components K
- `sought_estimate` — `"Location & orientation"` or `"Location"`
- `covariance_type` — `"full"` or `"diagonal"`
- `SharedCovariance` — Whether all components share one covariance
- `initial_cluster_finding_approach` — `"k-means ++"`, `"Maximum probability"`, or `"Maximum component-wise fit"`
- `model_selection_criterion` — `"Given number of components"`, `"Bayesian information criterion"`, or `"L2 density error"`
- `reconstruction_threshold` — Minimum normalized intensity for inclusion
- `regularization_parameter` — Added to covariances for numerical stability

## Usage Example

```matlab
MethodClassObj.GMM = [];
MethodClassObj = ClassGMModeling(MethodClassObj, reconstruction, zef, ...
    'number_of_clusters', 3, ...
    'covariance_type', 'full', ...
    'model_selection_criterion', 'Bayesian information criterion');
% Results in MethodClassObj.GMM.Model, MethodClassObj.GMM.Dipoles, etc.
```

## Algorithm Summary

1. Extract source positions and current density magnitudes from the reconstruction.
2. Threshold and optionally smooth the activity map.
3. Define the estimation space (positions and optionally directions).
4. For each candidate K, fit GMM using `FitAdvGMM` with chosen initialization.
5. Select best K via BIC, L2 error, or fixed count.
6. Convert GMM parameters to dipoles (locations, directions, amplitudes).

## Notes

- Requires `GMM2amplitude` (from the GMMClustering plugin) for amplitude estimation when using maximal likelihood or MAP options.
- Compatible with both single-frame and multi-frame (cell) reconstructions.
- Supports restriction to selected parcellation regions via `use_selected_parcellations`.
