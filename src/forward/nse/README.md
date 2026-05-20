# src/forward/nse

## Purpose of this folder

Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.

## Contents

MATLAB sources:
- `zef_nse_run_solver.m` — **if zef.nse_field**: If zef.nse field.
- `zef_KDMD.m` — **zef_KDMD**: Zef KDMD.
- `zef_QinvMQ.m` — **zef_QinvMQ**: Zef Qinv MQ.
- `zef_averaging_matrix.m` — **zef_averaging_matrix**: Zef averaging matrix.
- `zef_get_submesh.m` — **zef_get_submesh**: Zef get submesh.
- `zef_nse_iteration.m` — **zef_nse_iteration**: Zef nse iteration.
- `zef_p_iteration.m` — **zef_nse_iteration**: Zef nse iteration.
- `zef_nse_matrices.m` — **zef_nse_matrices**: Zef nse matrices.
- `zef_nse_plot_pulse.m` — **zef_nse_plot_pulse**: Zef nse plot pulse.
- `zef_nse_poisson.m` — **zef_nse_poisson**: Zef nse poisson.
- `zef_nse_poisson_dynamic.m` — **zef_nse_poisson_dynamic**: Zef nse poisson dynamic.
- `zef_nse_reconstruction.m` — **zef_nse_reconstruction**: Zef nse reconstruction.
- `zef_nse_sigma.m` — **zef_nse_sigma**: Zef nse sigma.
- `zef_nse_signal_pulse.m` — **zef_nse_signal_pulse**: Zef nse signal pulse.
- `zef_nse_threshold_distribution.m` — **zef_nse_threshold_distribution**: Zef nse threshold distribution.
- `zef_set_nse_source_space.m` — **zef_set_nse_source_space**: Zef set nse source space.
- `zef_smooth_nse_field.m` — **zef_smooth_nse_field**: Zef smooth nse field.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `if zef.nse_field` from MATLAB with the project root on the path.`
- ``[x] = zef_KDMD(x, K, M, D, …)` with project root and `src` on the path.`
- ``[x] = zef_QinvMQ(x, Q_1, Q_2, Q_3, …)` with project root and `src` on the path.`
- ``[M] = zef_averaging_matrix(nodes, tetra, I)` with project root and `src` on the path.`
- ``[[nodes, simplexes, J]] = zef_get_submesh(nodes, simplexes, I)` with project root and `src` on the path.`
- ``[zef] = zef_nse_iteration(zef)` with project root and `src` on the path.`
- ``[zef] = zef_nse_iteration(zef)` with project root and `src` on the path.`
- ``[nse_mat] = zef_nse_matrices(nodes, tetra, rho, mu)` with project root and `src` on the path.`

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
