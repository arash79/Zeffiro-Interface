# `@UKFNMMInverter` — SKF spatial tracking + Jansen–Rit NMM + UKF

## Folder purpose

Class-based inverse method whose **spatial** estimate is a Kalman filter on a per-source SVD-modified lead field, and whose **temporal** model is the Jansen–Rit neural mass model with parameters estimated by an unscented Kalman filter.

This is **not** `inverse.KalmanInverter` and **not** the legacy Inverse-tools Kalman plugin (`tools/plugins/Kalman`, `zef_KF`). Registry ids: `ukfnmm`, `ukf_nmm`.

Author: **Joonas Lahtinen** (introducing commits `462bab2c` / `0b33ef8c`). There is **no dedicated SKF–NMM–UKF publication or DOI** in this repository. The spatial Kalman component was branched from Standardized Kalman filtering (Lahtinen et al., *Clinical Neurophysiology* 168, 2024, DOI [10.1016/j.clinph.2024.09.021](https://doi.org/10.1016/j.clinph.2024.09.021)).

## Main contents

| File | Role |
|------|------|
| `UKFNMMInverter.m` | NMM/UKF parameters, spatial-Kalman priors, RTS flags, filter state |
| `initialize.m` | Reset recursion; `noise_cov`; `theta0`; process noise Q; `modified_L` |
| `invert.m` | One spatial predict-update (`class_kf_predict` + `kf_update` on `modified_L`) |
| `smoother.m` | Optional RTS / Sample RTS, then **one** NMM/UKF stage |
| `UKF_estimate_NMM_parameters.m` | Source selection, Gram clustering, spike times, JR + UKF |

## Code functionality

Lifecycle owned by `utilities.inverse.run_frame_loop` and the inversion drivers:

1. `initialize(L, f_data)`
2. Per frame: `invert(f, L, …)` — spatial Kalman only
3. `smoother(z_inverse, L)` — optional RTS, then NMM/UKF **once**
4. `terminateComputation()` — drop dynamic `evolution_var`

`invert` does **not** detect the last frame and does **not** call `smoother`. That last-frame self-call was in the introducing `invert.m` and would have double-run NMM once the driver also called `smoother`.

`use_smoothing` is **always true** so the current driver gate (`ismethod smoother` and `use_smoothing`) actually invokes this post-frame hook. RTS is selected independently by `smoother_type` (`None` / `RTS` / `Sample RTS`). Setting `use_smoothing` to false is ignored.

### Spatial stage and the SKF vs KF discrepancy

The README written in `462bab2c` says:

> spatial estimation comes from SKF and time evolution from the Jansen-Rit neural mass model. JR parameters are estimated through UKF.

The code committed immediately afterwards (`0b33ef8c`) does **not** call `plugins.ClassKF.kf_sL_update`. It calls ordinary `plugins.ClassKF.kf_update` with `H = modified_L`.

`modified_L` is built by taking each source’s three lead-field columns `L(:, 3n-2:3n)`, computing the thin SVD, and replacing those columns with the left vectors `U` (`n_sensors × 3` when `n_sensors ≥ 3`). That is a **per-source orthonormalisation of the observable dipole subspace**, not sLORETA standardization `z = D x`.

Evidence for keeping ordinary KF + `modified_L`:

- KalmanInverter at the same commit already used `kf_sL_update` for `"Standardized Kalman filter"`. UKFNMM did not call it.
- NMM comments refer to the stored filter mean as the SKF reconstruction, and back-project with the **original** `L`, not `D*x` and not `modified_L`.
- `class_kf_predict` / `kf_update` plus `modified_L` is what was actually executed (once the missing `prev_step_*` state is supplied).

This port therefore **preserves `kf_update` + `modified_L`**. Calling it “SKF” in the user-facing name follows the author’s README; the spatial kernel is ordinary KF on the SVD-modified observation model. That mismatch is documented, not silently “fixed” to `kf_sL_update`.

`modified_L` is used **only** as the spatial Kalman observation model. NMM back-projection uses the original `L` passed into `smoother`, matching the introducing `zef_process_inversion` call (`smoother(z_inverse, L)`). Mixing `modified_L` (filter) with `L` (NMM) is scientifically ambiguous and is preserved.

Requires a 3-component xyz layout (`size(L,2)` divisible by 3) and at least 3 sensors (otherwise thin SVD `U` is not `n_sensors × 3`). `source_direction_mode` 3 is rejected.

### NMM / UKF stage

`UKF_estimate_NMM_parameters`:

1. Source magnitudes from xyz triplets, max-normalised.
2. Keep sources with peak `> score_threshold`.
3. `Corr_matrix = z*z'` — a Gram / unnormalised similarity matrix, **not** Pearson correlation. Clustering uses this matrix as committed.
4. `kmeans(..., number_of_corrclusters+1)` and drop the lowest-score cluster.
5. Heuristic peak-time estimation on the mean SKF time course, with duplicate-cluster reassignment.
6. UKF (`alpha`, `kappa`, `beta`) on 11 Jansen–Rit parameters; observation is cluster-restricted `L x` (“spatial potentials”).
7. Final reconstruction: `contribution_vec .* JR_signal` on the cluster’s dipole indices.

Needs Statistics Toolbox `kmeans`.

## Workflow context

```matlab
[zef, r] = zef_inverse_run(zef, "ukfnmm", "execution", "local", ...
    "MethodParams", struct( ...
        "number_of_corrclusters", 1, ...
        "score_threshold", 0.2, ...
        "smoother_type", "None", ...
        "evolution_prior_model", "Reworked original"));
```

Also valid: `computeInversionWithZI` on an `inverse.UKFNMMInverter` instance. Cluster dispatch uses the same registry ids.

There is **no Inverse-tools GUI** for this class. The current codebase exposes class methods through `utilities.cluster.inverse_method_registry` and `zef_inverse_run`, not through `tools/plugins`. Do not copy the legacy Kalman app.

## Usage instructions

Constructor name-values include:

| Property | Default | Role |
|----------|---------|------|
| `number_of_corrclusters` | 3 | Clusters kept after discarding one extra k-means cluster |
| `score_threshold` | 0.2 | Relative peak gate after max-normalisation |
| `alpha`, `kappa`, `beta` | 5, 0, 0 | UKF weights (`alpha=5` is the committed heuristic) |
| `evolution_prior_model` | `"Sensitivity scaling"` | Spatial Q; `"User supplied Q"` needs `evolution_cov` |
| `smoother_type` | `"None"` | `"RTS"` / `"Sample RTS"` before NMM |
| `number_of_noise_steps` | 4 | Frames used for `theta0` (capped to available T) |

`time_series` after a full run is `n_clusters × T`. `n_temporal_postprocess_runs` must be 1 after `dispatch_inverse` / `zef_process_inversion`.

## Important notes

Definite introducing-commit defects fixed in this port (see also the class comments):

- Spatial filter state is `prev_step_reconstruction` / `prev_step_posterior_cov` so `class_kf_predict` can run (the original class did not define those properties).
- `invert` no longer calls `smoother`; NMM runs once from the driver.
- Posterior covariances stored for RTS are one **filter posterior per frame**, not a leading prior cell (off-by-one).
- Unqualified `number_of_frames` in the RTS loop is `self.number_of_frames`.
- `smoother_type` setter actually stores the value (the Kalman sibling setter does not).
- Warning suppression uses `onCleanup` restoration rather than `warning('on')`.
- Triplet SVD, k-means feasibility, zero reconstruction, empty clusters, short recordings, and non-finite UKF/ODE/interp failures raise `UKFNMMInverter:*` errors instead of MATLAB indexing crashes.

Preserved scientific / heuristic behaviour (not “corrected”):

- Ordinary `kf_update` on `modified_L` despite the SKF README wording.
- NMM observations from original `L`, not `modified_L`.
- `Corr_matrix = z*z'` as a Gram matrix.
- UKF `alpha=5`, `beta=0`.
- Extra k-means cluster discarded by score.
- Duplicate cluster-order reassignment in `estimate_peaks`.
- `s_ind3D = 3*s - [0;1;2]` (z,y,x packing, internally consistent).
- 50 ms Jansen–Rit pulse and peak-time warping of `ode45` output.
- Time-varying Q consumed per frame, but RTS uses the last `evolution_cov` only.

## Developer guidance

Keep this class separate from `KalmanInverter`. New spatial-filter kernels belong in `plugins.ClassKF` only if they are shared; do not fold NMM into Kalman. Tests: `tests.UKFNMMInverterTest`, `tests.UKFNMMDispatchTest`.
