# tools/plugins/ZeffiroTopography/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_topography_app.m` — **h1 = figure(...**: H1 = figure(....
- `zef_init_topography.m` — **if not(isfield(zef,'top_regularization_parameter'));**: If not(isfield(zef,'top regularization parameter'));.
- `zef_update_topography.m` — **zef.top_regularization_parameter = str2num(get(zef**: Zef.top regularization parameter = str2num(get(zef.
- `zef_evaluate_topography.m` — **zef_evaluate_topography**: Zef evaluate topography.
- `zef_topography.m` — **zef_topography**: Zef topography.

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
- `Call `h1 = figure(...` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'top_regularization_parameter'));` from MATLAB with the project root on the path.`
- `Call `zef.top_regularization_parameter = str2num(get(zef` from MATLAB with the project root on the path.`
- ``[z] = zef_evaluate_topography(zef)` with project root and `src` on the path.`
- ``[zef] = zef_topography(zef)` with project root and `src` on the path.`

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
