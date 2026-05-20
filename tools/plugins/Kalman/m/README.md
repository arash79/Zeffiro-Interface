# tools/plugins/Kalman/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `Block_RTS_smoother.m` — **Block_RTS_smoother**: Block RTS smoother.
- `EnKF.m` — **EnKF**: En KF.
- `Q_quantities.m` — **Q_quantities**: Q quantities.
- `RTS_smoother.m` — **RTS_smoother**: RTS smoother.
- `RTS_smoother_normal2standardized.m` — **RTS_smoother_normal2standardized**: RTS smoother normal2standardized.
- `RTS_smoother_standardized.m` — **RTS_smoother_standardized**: RTS smoother standardized.
- `connectivity_matrix.m` — **connectivity_matrix**: Connectivity matrix.
- `double_kf_sL.m` — **double_kf_sL**: Double kf s L.
- `ext_sL.m` — **ext_sL**: Ext s L.
- `find_evolution_prior.m` — **find_evolution_prior**: Find evolution prior.
- `kalman_filter.m` — **kalman_filter**: Kalman filter.
- `kalman_filter_sLORETA.m` — **kalman_filter_sLORETA**: Kalman filter s LORETA.
- `kalman_filter_sLORETA_EVO_DIAG_WEIGHT.m` — **kalman_filter_sLORETA_EVO_DIAG_WEIGHT**: Kalman filter s LORETA EVO DIAG WEIGHT.
- `kf_predict.m` — **kf_predict**: Kf predict.
- `kf_sL_update.m` — **kf_sL_update**: Kf s L update.
- `kf_sL_update_approx.m` — **kf_sL_update_approx**: Kf s L update approx.
- `kf_update.m` — **kf_update**: Kf update.
- `sample_RTS_smoother.m` — **sample_RTS_smoother**: Sample RTS smoother.
- `triple_kf_sL.m` — **triple_kf_sL**: Triple kf s L.
- `zef_KF.m` — **zef_KF**: Zef KF.
- `zef_dti_fa_covariance.m` — **zef_dti_fa_covariance**: Zef dti fa covariance.
- `zef_dti_interpolate_to_sources.m` — **zef_dti_interpolate_to_sources**: Zef dti interpolate to sources.
- `zef_dti_structural_Q.m` — **zef_dti_structural_Q**: Zef dti structural Q.
- `zef_dti_tractography_covariance.m` — **zef_dti_tractography_covariance**: Zef dti tractography covariance.
- `zef_kf_open_window.m` — **zef_kf_open_window**: Zef kf open window.
- `zef_kf_start.m` — **zef_kf_start**: Zef kf start.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_kf_open_window**: GUI callback or dialog (`zef_kf_open_window`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[[P_s_store, m_s_store, G_store]] = Block_RTS_smoother(P_store, z_inverse, A, Q, …)` with project root and `src` on the path.`
- ``[z_inverse] = EnKF(m, A, P, Q, …)` with project root and `src` on the path.`
- ``[[sigma, phi, B]] = Q_quantities(P, m, G, y)` with project root and `src` on the path.`
- ``[[P_s_store, m_s_store, G_store]] = RTS_smoother(P_store, z_inverse, A, Q, …)` with project root and `src` on the path.`
- ``[[P_s_store, m_s_store, G_store]] = RTS_smoother_normal2standardized(P_store, z_inverse, A, Q, …)` with project root and `src` on the path.`
- ``[[P_s_store, m_s_store, G_store]] = RTS_smoother_standardized(P_store, D_store, z_inverse, A, …)` with project root and `src` on the path.`
- ``[A] = connectivity_matrix(source_positions, K, weighted_avg)` with project root and `src` on the path.`
- ``[[P_store, z_inverse]] = double_kf_sL(m, P, A, Q, …)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
