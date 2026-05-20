# tools/plugins/GMModel

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_GMModel_init.m` — **if not(isfield(zef,'GMModel'))**: If not(isfield(zef,'GMModel')).
- `zef_GMModel_open.m` — **zef_GMModel_open**: Zef GMModel open.
- `zef_GMModel_start.m` — **zef_GMModel_start**: Zef GMModel start.
- `zef_GMModel_update.m` — **zef_GMModel_update**: Zef GMModel update.
- `zef_GMModel_window.m` — **zef_GMModel_window**: Zef GMModel window.
- `zef_cluster_reconstruction.m` — **zef_cluster_reconstruction**: Zef cluster reconstruction.
- `zef_find_clusters.m` — **zef_find_clusters**: Zef find clusters.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

Open the corresponding tool or plugin from the Zeffiro menu bar (profile-dependent). Widget callbacks in this folder update `zef` and call `zef_update`.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `if not(isfield(zef,'GMModel'))` from MATLAB with the project root on the path.`
- ``[zef] = zef_GMModel_open(zef)` with project root and `src` on the path.`
- ``[zef] = zef_GMModel_start(zef)` with project root and `src` on the path.`
- ``[zef] = zef_GMModel_update(zef)` with project root and `src` on the path.`
- ``[zef] = zef_GMModel_window(zef)` with project root and `src` on the path.`
- ``[[cluster_centres, dipole_moments, index_vec]] = zef_cluster_reconstruction(zef)` with project root and `src` on the path.`
- ``[[index_vec, MahalanobisD, GMModel]] = zef_find_clusters(n_clusters, rec_points, reg_val, cred_val, …)` with project root and `src` on the path.`

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
