# +ClassKF — Kalman Filter Framework for Dynamic Source Reconstruction

This package implements **Kalman filtering** and related methods for dynamic brain source reconstruction from time-series M/EEG measurements. It provides sequential Bayesian estimation of source activity over time, with support for multiple filter types and optional RTS smoothing.

## Overview

The state-space model is:

- **State:** Source current distribution (3N × 1 for N sources with x,y,z components)
- **Observation:** Measurements = lead field × state + noise
- **Dynamics:** State transition (default: identity, i.e., random walk)

The Kalman filter recursively updates the posterior mean and covariance as new measurements arrive.

## Files

### Main Pipeline

| File | Description |
|------|-------------|
| `zef_KF.m` | Main entry point: runs full reconstruction pipeline (lead field, filtering, smoothing, postprocessing) |
| `zef_kf_start.m` | Startup script for KF app; registers in Zeffiro Interface |
| `zef_kf_open_window.m` | Opens the KF configuration UI and syncs with ZEF parameters |
| `zef_kf_sLORETA_OLD.m` | Legacy sLORETA-based prior initialization |

### Filter Core

| File | Description |
|------|-------------|
| `kalman_filter.m` | Standard Kalman filter (predict + update) over multiple frames |
| `kalman_filter_sLORETA.m` | Kalman filter with sLORETA resolution weighting (reduces depth bias) |
| `EnKF.m` | Ensemble Kalman filter; Monte Carlo approximation for high-dimensional states |
| `kf_predict.m` | Prediction step: m_pred = A*m, P_pred = A*P*A' + Q |
| `kf_update.m` | Update step: Kalman gain, innovation, posterior mean and covariance |
| `kf_sL_update.m` | Update step with sLORETA resolution matrix D (sqrtm or SVD-based) |
| `kf_sL_update_approx.m` | Update step with approximated resolution matrix (Newton-Schulz iterations) |

### Utilities

| File | Description |
|------|-------------|
| `find_evolution_prior.m` | Computes process noise covariance Q from lead field and data |
| `connectivity_matrix.m` | Builds K-NN spatial smoothing matrix for state transition |
| `RTS_smoother.m` | Rauch–Tung–Striebel backward smoother |
| `Q_quantities.m` | Auxiliary quantities for EM-based Q estimation |
| `class_kf_predict.m` | Prediction step (object-oriented interface) |

## Filter Types (`zef.filter_type`)

| Value | Type | Description |
|-------|------|-------------|
| 1 | Standard Kalman | Basic predict-update; output = posterior mean |
| 2 | EnKF | Ensemble Kalman filter; suitable for large state dimensions |
| 3 | sLORETA Kalman | Resolution-weighted output D*m; reduces depth bias |
| 4 | Alternative sLORETA | Variant using theta0-based initialization |

## Key Parameters (from `zef`)

- `inv_snr` — Signal-to-noise ratio (dB) for measurement noise
- `inv_sampling_frequency` — Sampling rate
- `inv_low_cut_frequency`, `inv_high_cut_frequency` — Bandpass filter
- `number_of_frames` — Number of time frames
- `kf_smoothing` — 2 for RTS smoothing, else filtering only
- `kf_evolution_prior_mode` — Method for computing Q (see `find_evolution_prior`)
- `number_of_ensembles` — Ensemble size for EnKF (filter type 2)

## Usage

From the Zeffiro Interface GUI: open the KF tool via the plugin menu, configure parameters, and run.

From code:

```matlab
zef = zef_KF(zef);  % Uses zef parameters
% Or with explicit Q:
zef = zef_KF(zef, q_value);  % q_value: scalar, vector, or matrix
```

## Algorithm Flow

1. Load lead field and project structure (`zef_processLeadfields`, `zef_getFilteredData`).
2. Set initial prior (m, P) and process noise Q (via `find_evolution_prior` or user-supplied).
3. For each time frame: predict, then update with measurement.
4. If smoothing enabled: run RTS backward pass.
5. Postprocess and normalize reconstruction (`zef_postProcessInverse`, `zef_normalizeInverseReconstruction`).

## Evolution Prior Modes (`find_evolution_prior`)

- **1:** Spatially adaptive, sensitivity-weighted
- **2:** Spatially averaged sensitivity
- **3:** SVD-based (full matrix Q; may be numerically unstable)
- **4:** Averaged signal-space contribution
- **5:** Time-step scaled
