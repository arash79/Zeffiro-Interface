# Kalman Filter Plugin for EEG/MEG Source Localization

Zeffiro Interface plugin implementing Kalman-filter-based inverse solvers for electromagnetic source imaging, with optional DTI-informed structural priors.

## Overview

This plugin provides a family of Bayesian state-space estimators for EEG/MEG source localization. The time series of scalp measurements is modeled as a linear observation of an evolving source current distribution:

```
x(t) = A * x(t-1) + w(t),    w(t) ~ N(0, Q)    (state evolution)
y(t) = L * x(t)   + v(t),    v(t) ~ N(0, R)    (observation)
```

where `x` is the source current vector, `y` is the measurement vector, `L` is the lead field matrix, `A` is the state transition (identity by default), `Q` is the process noise covariance, and `R` is the measurement noise covariance.

### Key Features

- **9 filter types**: Standard Kalman, Ensemble Kalman (EnKF), sLORETA-standardized variants, and multi-block (double/triple) state-space filters
- **4 smoothing modes**: None, Rauch-Tung-Striebel (RTS), 2-block RTS, 3-block RTS
- **DTI structural priors**: FA-based and tractography-based structural covariance matrices that replace the standard diagonal Q with white-matter-informed spatial coupling
- **sLORETA standardization**: Resolution-matrix-based standardization with configurable exponents
- **Cluster computing**: Batch processing scripts for MATLAB Parallel Server
- **GUI**: MATLAB App Designer interface for interactive parameter configuration

## Directory Structure

```
plugins/Kalman/
├── README.md                  ← This file
├── m/                         ← Core algorithms and DTI integration
│   ├── README.md
│   ├── zef_KF.m              ← Main entry point
│   ├── kalman_filter.m        ← Standard Kalman filter loop
│   ├── EnKF.m                 ← Ensemble Kalman filter
│   ├── kf_predict.m           ← Prediction step
│   ├── kf_update.m            ← Update step
│   ├── RTS_smoother.m         ← RTS backward smoother
│   ├── zef_dti_structural_Q.m ← DTI structural Q builder (bridge)
│   ├── zef_dti_fa_covariance.m
│   ├── zef_dti_tractography_covariance.m
│   ├── zef_dti_interpolate_to_sources.m
│   └── ...                    ← Additional filter/smoother variants
├── Scripts/                   ← Analysis and test scripts
│   ├── README.md
│   ├── test_dti_structural_covariance.m
│   └── ...                    ← Visualization scripts
├── clusterScripts/            ← HPC batch processing
│   ├── README.md
│   └── ...
└── mlapp/                     ← GUI
    ├── README.md
    └── zef_kf_app.mlapp
```

## Quick Start

### Basic Usage (diagonal Q)

```matlab
% Standard Kalman filter with default diagonal Q
zef.filter_type = 1;        % 1=KF, 2=EnKF, 3=sLORETA, ...
zef.kf_smoothing = 2;       % 1=none, 2=RTS, 3=2-block, 4=3-block
zef = zef_KF(zef);
```

### With DTI Structural Priors

```matlab
% 1. Load DTI data (see m/forward_simulation/dti/ or DTIConductivityTool)
[zef.freesurfer_fa_data, zef.freesurfer_fa_info] = zef_freesurfer_load_fa(fa_file);
[zef.freesurfer_v1_data, ~] = zef_freesurfer_load_v1(v1_file);
zef.freesurfer_register_transform = zef_freesurfer_read_register_dat(register_file);
ref_geom = zef_freesurfer_read_volume_geometry(ref_mri_file);
zef.dti_ref_vox2ras     = ref_geom.vox2ras;
zef.dti_ref_vox2ras_tkr = ref_geom.vox2ras_tkr;
zef.dti_ref_center      = ref_geom.center_ras;
zef.dti_ref_geometry    = ref_geom;

% 2. Enable structural Q
zef.kf_structural_Q_type = 1;   % 1=FA-based, 2=Tractography-based
zef = zef_KF(zef);

% 3. Revert to standard diagonal Q
zef.kf_structural_Q_type = 0;
zef = zef_KF(zef);
```

### Visualize Structural Covariance Matrices

Run the test script to load DTI data and compare both approaches:

```matlab
test_dti_structural_covariance
```

## Pipeline Flow

```
                          ┌─────────────────────┐
                          │   zef_KF (entry)     │
                          └──────────┬──────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    ▼                ▼                ▼
           Lead field (L)     Measurements      Prior (theta0)
           zef_processLeadfields  zef_getFilteredData  zef_find_gaussian_prior
                    │                │                │
                    ▼                ▼                ▼
              ┌──────────────────────────────────────────┐
              │         Build Q matrix                   │
              │  ┌─────────────────────────────────┐     │
              │  │ structural_Q_type = 0 (default) │     │
              │  │   Q = q_value * I               │     │
              │  ├─────────────────────────────────┤     │
              │  │ structural_Q_type = 1 (FA)      │     │
              │  │   zef_dti_structural_Q(zef,q,'fa')    │
              │  ├─────────────────────────────────┤     │
              │  │ structural_Q_type = 2 (Tract)   │     │
              │  │   zef_dti_structural_Q(zef,q,   │     │
              │  │       'tractography')            │     │
              │  └─────────────────────────────────┘     │
              └──────────────────┬───────────────────────┘
                                 │
                    ┌────────────┼──────────────┐
                    ▼            ▼              ▼
              Filter type 1  Type 2     Types 3-9
              kalman_filter  EnKF       sLORETA / block
                    │            │              │
                    ▼            ▼              ▼
              ┌──────────────────────────────────┐
              │         Smoothing (optional)      │
              │  RTS / Block_RTS / ext_sL         │
              └──────────────┬───────────────────┘
                             │
                             ▼
                    Post-processing
                    zef_postProcessInverse
                    zef_normalizeInverseReconstruction
```

## DTI Integration

The DTI integration replaces the standard diagonal process noise covariance `Q = q * I` with a structurally informed matrix that encodes white matter connectivity from diffusion tensor imaging.

### How It Works

1. **Interpolation** (`zef_dti_interpolate_to_sources`): Source positions are transformed from Zeffiro mesh display space to FreeSurfer FA voxel space using the full coordinate chain (`zef_dti_get_mesh2voxel`), then FA and v1 values are trilinearly interpolated. v1 directions are rotated back to mesh space.

2. **Covariance construction**: Two methods are available:
   - **FA-based** (`zef_dti_fa_covariance`): Spatial Gaussian kernel weighted by FA product and directional coherence of v1 eigenvectors. Sparse k-nearest-neighbor output.
   - **Tractography-based** (`zef_dti_tractography_covariance`): Deterministic bidirectional streamlines traced through v1 field. Connectivity from co-traversal of source pairs.

3. **Scaling and expansion** (`zef_dti_structural_Q`): The N x N source-level matrix is scaled by `q_value` and expanded to the full state dimension via `kron(Q_source, I_3)` for 3-component Cartesian mode.

### Coordinate Transformation Chain

```
Kalman source positions (mesh display, mm)
    │
    ▼  zef_dti_get_mesh2voxel (0-based output)
    │  + 1 for MATLAB 1-based indexing
    ▼
FA voxel space (1-based for griddedInterpolant)
    │
    ▼  Trilinear interpolation of FA and v1
    │
    ▼  v1 rotated back: v1_mesh = inv(R) * v1_voxel
    │
Structural covariance built in mesh display space
```

### Prerequisites for DTI Integration

The same DTI data required by the conductivity pipeline:
- `fa.nii.gz` — loaded into `zef.freesurfer_fa_data`
- `v1.nii.gz` — loaded into `zef.freesurfer_v1_data` (required for tractography, recommended for FA-based)
- `register.dat` — loaded into `zef.freesurfer_register_transform`
- Reference MRI geometry — stored in `zef.dti_ref_geometry` (or individual fields)

All of these can be loaded via the DTI Conductivity Tool GUI or programmatically (see `m/forward_simulation/dti/README.md`).

## Filter Types

| `filter_type` | Name | Description | Smoothing |
|---|---|---|---|
| 1 | Standard KF | Classical Kalman filter | up to RTS |
| 2 | EnKF | Ensemble Kalman filter (sample-based) | none |
| 3 | sLORETA KF | Spatiotemporal sLORETA standardization | up to RTS |
| 4 | Spatial sLORETA | Spatial-only sLORETA (static resolution matrix) | up to RTS |
| 5 | Double-block sL1 | 2-block state space, sLORETA type 1 | up to block RTS |
| 6 | Double-block sL2 | 2-block state space, sLORETA type 2 | up to block RTS |
| 7 | Triple-block sL1 | 3-block state space, sLORETA type 1 | up to block RTS |
| 8 | Triple-block sL2 | 3-block state space, sLORETA type 2 | up to block RTS |
| 9 | Triple-block sL3 | 3-block state space, sLORETA type 3 | up to block RTS |

## Key Parameters (`zef` fields)

| Field | Type | Description |
|---|---|---|
| `inv_snr` | scalar (dB) | Signal-to-noise ratio |
| `inv_prior_over_measurement_db` | scalar (dB) | Prior-to-measurement ratio |
| `inv_amplitude_db` | scalar (dB) | Amplitude scaling |
| `inv_evolution_prior` | scalar (dB) | Evolution prior strength |
| `number_of_frames` | integer | Number of time frames |
| `source_direction_mode` | 1, 2, or 3 | 1=Cartesian, 2=Normal, 3=Face-based |
| `filter_type` | 1–9 | Filter variant (see table) |
| `kf_smoothing` | 1–4 | 1=none, 2=RTS, 3=2-block, 4=3-block |
| `kf_burn_in` | integer | Burn-in frames for block filters |
| `standardization_exponent` | scalar | sLORETA exponent (0.5, 1, 1.25, ...) |
| `kf_structural_Q_type` | 0, 1, or 2 | 0=diagonal, 1=FA-based, 2=Tractography |

## Memory Considerations

The standard Kalman filter maintains a dense state covariance P of size `[N_state x N_state]`. After the first update step, P becomes fully dense regardless of Q's sparsity. For large source counts in 3-component mode (N_state = 3 * N_sources), memory usage is:

| N_sources | Mode | P size | Memory |
|---|---|---|---|
| 5,000 | Cartesian (3) | 15,000 x 15,000 | ~1.8 GB |
| 10,000 | Cartesian (3) | 30,000 x 30,000 | ~7.2 GB |
| 5,000 | Normal (1) | 5,000 x 5,000 | ~200 MB |

For large problems, the **Ensemble Kalman Filter** (filter_type=2) is recommended as it represents P through ensemble samples rather than a full matrix.

## Dependencies

- Core library: `m/forward_simulation/dti/` (coordinate transforms, DTI loading)
- Inverse utilities: `zef_processLeadfields`, `zef_getFilteredData`, `zef_find_gaussian_prior`
- Plugin: `plugins/DTIConductivityTool/` (GUI for DTI data loading, optional)

## References

- Kalman, R.E. (1960). A new approach to linear filtering and prediction problems. *J. Basic Eng.* 82(1):35-45.
- Rauch, H.E., Tung, F., Striebel, C.T. (1965). Maximum likelihood estimates of linear dynamic systems. *AIAA J.* 3(8):1445-1450.
- Evensen, G. (1994). Sequential data assimilation with a nonlinear quasi-geostrophic model. *J. Geophys. Res.* 99(C5):10143-10162.
- Tuch, D.S. et al. (2002). Conductivity tensor mapping of the human brain using diffusion tensor MRI. *PNAS* 99(10):6667-6672.
