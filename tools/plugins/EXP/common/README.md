# tools/plugins/EXP/common

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `EM_Lasso.m` — **EM_Lasso**: EM Lasso.
- `L1_optimization.m` — **L1_optimization**: L1 optimization.
- `LG_optimization.m` — **LG_optimization**: LG optimization.
- `exp_iteration.m` — **exp_iteration**: Exp iteration.
- `exp_make_multires_dec.m` — **function [exp_multires_dec, exp_multires_ind, exp_multires_count] = exp_make_multires_dec**: Function [exp multires dec, exp multires ind, exp multires count] = exp make multires dec.
- `zef_exp_app_launch.m` — **zef_exp_app_launch**: Zef exp app launch.
- `zef_exp_app_start.m` — **zef_exp_app_start**: Zef exp app start.

Other files:
- `exp_app.mlapp`

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_exp_app_start**: GUI callback or dialog (`zef_exp_app_start`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[x] = EM_Lasso(L, sigma, y, gamma, …)` with project root and `src` on the path.`
- ``[x] = L1_optimization(A, sigma, y, gamma, …)` with project root and `src` on the path.`
- ``[x] = LG_optimization(A, sigma, y, gamma, …)` with project root and `src` on the path.`
- ``[[z, reconstruction_information]] = exp_iteration(zef)` with project root and `src` on the path.`
- `Call `function [exp_multires_dec, exp_multires_ind, exp_multires_count] = exp_make_multires_dec` from MATLAB with the project root on the path.`
- ``[zef] = zef_exp_app_launch(zef)` with project root and `src` on the path.`
- ``[zef] = zef_exp_app_start(zef)` with project root and `src` on the path.`

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
