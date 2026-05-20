# Kalman Plugin — Core Algorithms (`m/`)

Core computation library for Kalman-filter-based EEG/MEG source localization. Contains the filter implementations, smoother variants, and the DTI structural covariance bridge.

## File Reference

### Main Entry Point

| File | Function | Description |
|------|----------|-------------|
| `zef_KF.m` | `zef_KF` | **Primary entry point.** Reads parameters from `zef`, computes the lead field, builds the process noise covariance Q (diagonal or DTI-structural), selects among 9 filter types, applies optional smoothing, and stores the reconstruction in `zef.reconstruction`. |

### Prediction and Update

| File | Function | Description |
|------|----------|-------------|
| `kf_predict.m` | `kf_predict` | Kalman prediction step. Fast path when A is identity: `P = P + Q`. General path: `m = A*m`, `P = A*P*A' + Q`. |
| `kf_update.m` | `kf_update` | Kalman update step. Computes innovation `v = y - H*m`, innovation covariance `S = H*P*H' + R`, Kalman gain `K = P*H'/S`, and updates `m` and `P`. |
| `kf_sL_update.m` | `kf_sL_update` | sLORETA-standardized update. Returns the standardization matrix D alongside the updated state. |
| `kf_sL_update_approx.m` | `kf_sL_update_approx` | Approximate sLORETA update for computational efficiency. |

### Filter Loops

| File | Function | Description |
|------|----------|-------------|
| `kalman_filter.m` | `kalman_filter` | Standard Kalman filter loop over time frames. Calls `kf_predict` and `kf_update` at each step. Optionally stores P for RTS smoothing. |
| `kalman_filter_sLORETA.m` | `kalman_filter_sLORETA` | sLORETA-standardized Kalman filter. Uses `kf_sL_update` for resolution-matrix-based standardization. |
| `kalman_filter_sLORETA_EVO_DIAG_WEIGHT.m` | `kalman_filter_sLORETA_EVO_DIAG_WEIGHT` | Variant with diagonal evolution weighting. |
| `EnKF.m` | `EnKF` | Ensemble Kalman filter. Represents the state covariance through an ensemble of samples. Supports correlation localization. Handles sparse Q from DTI structural priors via automatic conversion to full for `mvnrnd`. |
| `double_kf_sL.m` | `double_kf_sL` | Double-block state space filter (position + velocity). Expands state, A, P, Q, and L to 2-block form. |
| `triple_kf_sL.m` | `triple_kf_sL` | Triple-block state space filter (position + velocity + acceleration). |
| `ext_sL.m` | `ext_sL` | Extended sLORETA standardization applied after smoothing. |

### Smoothers

| File | Function | Description |
|------|----------|-------------|
| `RTS_smoother.m` | `RTS_smoother` | Rauch-Tung-Striebel backward smoother. Uses stored P and filtered estimates to compute smoothed states. |
| `Block_RTS_smoother.m` | `Block_RTS_smoother` | Block-structured RTS smoother for double/triple block filters. |
| `RTS_smoother_standardized.m` | `RTS_smoother_standardized` | Standardized RTS smoother variant. |
| `RTS_smoother_nonstandardized.m` | `RTS_smoother_nonstandardized` | Non-standardized RTS smoother variant. |
| `RTS_smoother_normal2standardized.m` | `RTS_smoother_normal2standardized` | Converts normal RTS output to standardized form. |
| `sample_RTS_smoother.m` | `sample_RTS_smoother` | Sample-based RTS smoother. |

### Prior Construction

| File | Function | Description |
|------|----------|-------------|
| `find_evolution_prior.m` | `find_evolution_prior` | Computes the scalar process noise scale `q` from the evolution prior in dB, the number of frames, and the initial prior variance `theta0`. |
| `Q_quantities.m` | `Q_quantities` | Computes sufficient statistics (sigma, phi, B, C, D) from filtered states for EM-style Q estimation. |
| `connectivity_matrix.m` | `connectivity_matrix` | Builds a k-nearest-neighbor spatial connectivity matrix from source positions. Expands to 3-component form via `kron(A, eye(3))`. (Available but not used in the default pipeline.) |

### DTI Structural Covariance Bridge

These functions bridge the DTI conductivity pipeline (`m/forward_simulation/dti/`) with the Kalman filter, enabling white-matter-informed process noise covariance.

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_structural_Q.m` | `zef_dti_structural_Q` | **Top-level bridge.** Orchestrates DTI interpolation, covariance construction, q-value scaling, and state dimension expansion. Called from `zef_KF` when `zef.kf_structural_Q_type > 0`. |
| `zef_dti_interpolate_to_sources.m` | `zef_dti_interpolate_to_sources` | Transforms source positions from mesh display space to FA voxel space via `zef_dti_get_mesh2voxel` (+1 for MATLAB indexing), interpolates FA and v1 using `griddedInterpolant`, and rotates v1 back to mesh space. |
| `zef_dti_fa_covariance.m` | `zef_dti_fa_covariance` | Builds a sparse FA-based structural covariance. Entry `C(i,j) = FA_i * FA_j * exp(-d²/2σ²) * dir_weight`. Uses k-nearest neighbors for sparsity. Directional weighting from v1 alignment. |
| `zef_dti_tractography_covariance.m` | `zef_dti_tractography_covariance` | Builds a sparse tractography-based structural covariance. Traces bidirectional streamlines from source positions through the v1 field. Connectivity from co-traversal along streamlines. Three-phase: trace → batch KNN → build sparse matrix. |

### Plugin Startup

| File | Function | Description |
|------|----------|-------------|
| `zef_kf_start.m` | `zef_kf_start` | Plugin startup function. Registers the Kalman filter in the Zeffiro inverse solver menu. |
| `zef_kf_open_window.m` | `zef_kf_open_window` | Opens the Kalman filter parameter GUI (App Designer). |
| `zef_kf_sLORETA_OLD.m` | `zef_kf_sLORETA_OLD` | Legacy sLORETA implementation (kept for backward compatibility). |

### Class-Based Implementation

| File | Function | Description |
|------|----------|-------------|
| `ClassImplementationFuns/class_kf_predict.m` | `class_kf_predict` | Class-based prediction step (for object-oriented interface). |

## DTI Structural Covariance — Detailed Flow

When `zef.kf_structural_Q_type = 1` (FA-based) or `2` (tractography-based), `zef_KF` calls `zef_dti_structural_Q` instead of building a diagonal Q. The internal flow is:

```
zef_dti_structural_Q(zef, q_value, method)
    │
    ├─ zef_dti_interpolate_to_sources(zef, source_positions)
    │      │
    │      ├─ zef_dti_get_mesh2voxel(zef)     ← from m/forward_simulation/dti/
    │      │      Computes mesh_display → FA_voxel (0-based)
    │      │
    │      ├─ griddedInterpolant(FA)           ← trilinear interpolation
    │      ├─ griddedInterpolant(v1 × 3)      ← per-component
    │      └─ inv(R) * v1_voxel → v1_mesh     ← rotate directions to mesh frame
    │
    ├─ zef_dti_fa_covariance(...)              ← if method = 'fa'
    │      OR
    ├─ zef_dti_tractography_covariance(...)    ← if method = 'tractography'
    │
    ├─ Q_source = q_value * Q_source           ← scale
    │
    └─ Q = kron(Q_source, I_3)                ← expand for 3-component mode
           OR Q = Q_source                     ← for 1-component mode
```

### Coordinate Convention

- Source positions (`zef.source_positions`): mesh display space, in mm
- `zef_dti_get_mesh2voxel` output: 0-based FA voxel indices (FreeSurfer convention)
- MATLAB arrays: 1-based, so +1 is added before `griddedInterpolant`
- v1 directions: interpolated in voxel frame, rotated to mesh frame via `inv(R)`

### FA-Based Covariance (`zef_dti_fa_covariance`)

For each source pair (i, j) within k nearest neighbors:

```
C(i,j) = FA_i × FA_j × exp(-d²_ij / 2σ²) × |v1_i · r̂_ij| × |v1_j · r̂_ij| × |v1_i · v1_j|
```

- `FA_i, FA_j`: fractional anisotropy at sources (0 to 1)
- `d_ij`: Euclidean distance (mm)
- `σ`: length scale parameter (default 10 mm)
- `r̂_ij`: unit direction from source i to j
- `v1_i, v1_j`: principal eigenvectors (mesh space, unit)
- The three cosine terms enforce: fiber-aligned separation (2 terms) + fiber parallelism (1 term)

### Tractography-Based Covariance (`zef_dti_tractography_covariance`)

1. For each source with FA ≥ threshold, trace one bidirectional streamline through v1
2. At each streamline step, snap to nearest source (batch KNN, proximity radius)
3. All pairs of sources visited by the same streamline receive a connection count
4. Normalize to unit diagonal

## Sparse vs Dense Q

Both structural covariance methods produce **sparse** Q matrices (k-NN or streamline connectivity). In the Kalman filter:

- `kf_predict`: `P = P + Q` — sparse Q + dense P → dense P (MATLAB auto-promotes)
- `kf_update`: `P = P - K*S*K'` — P stays dense after first update regardless
- `EnKF`: `mvnrnd(0, Q)` — Q is auto-converted to full for sampling

The sparse structure saves storage of Q itself, but does not reduce the per-frame computation cost of the standard KF (since P becomes dense). For large problems, use the EnKF (filter_type=2) which avoids storing P explicitly.
