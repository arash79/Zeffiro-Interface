# Zeffiro Interface +plugins Package

This package contains modular, object-oriented plugin components for the Zeffiro Interface—a finite element method (FEM) based tool for electromagnetic brain imaging and source reconstruction.

## Package Structure

```
+plugins/
├── +ClassGMM/     Gaussian Mixture Model (GMM) clustering for source reconstruction
├── +ClassKF/      Kalman Filter (KF) and Ensemble Kalman Filter for dynamic source estimation
└── README.md      This file
```

## Subpackages

### +ClassGMM — Gaussian Mixture Model Clustering

Provides weighted Gaussian mixture model fitting for identifying discrete source clusters from inverse reconstructions. Supports:

- Weighted EM algorithm for intensity-informed clustering
- Multiple initialization strategies (k-means++, random, partition-based)
- Full or diagonal covariance; shared or component-specific
- Model selection via BIC, L2 density error, or fixed component count
- Location-only or location-and-orientation estimation

**Primary entry point:** `ClassGMModeling(MethodClassObj, reconstruction, zef, args)`

See [+ClassGMM/README.md](+ClassGMM/README.md) for details.

### +ClassKF — Kalman Filter Framework

Provides sequential and ensemble Kalman filtering for dynamic brain source reconstruction from time-series M/EEG data. Supports:

- Standard Kalman filter (filter type 1)
- Ensemble Kalman Filter (EnKF) for high-dimensional state spaces (filter type 2)
- sLORETA-weighted Kalman filter for reduced depth bias (filter type 3)
- RTS (Rauch–Tung–Striebel) backward smoothing
- Spatially adaptive evolution prior computation

**Primary entry points:** `zef_KF(zef)`, `zef_kf_open_window(zef)`

See [+ClassKF/README.md](+ClassKF/README.md) for details.

## Integration with Zeffiro Interface

These plugins are designed to integrate with the Zeffiro Interface via the `inverse.CommonInverseParameters` framework and the `zef` project structure. They can be invoked from the GUI or from batch scripts.

## Dependencies

- MATLAB (with Statistics and Machine Learning Toolbox for GMM)
- Zeffiro Interface core (+core, m/, etc.)
- Functions such as `zef_waitbar`, `zef_processLeadfields`, `zef_getFilteredData`, etc.
