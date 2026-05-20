# tools/plugins/RAMUSInversion/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_ramus_app.m` — **h1 = figure(...**: H1 = figure(....
- `zef_init_ramus_inversion_tool.m` — **if not(isfield(zef,'ramus_multires_dec'));**: If not(isfield(zef,'ramus multires dec'));.
- `zef_update_ramus_inversion_tool.m` — **zef.ramus_multires_n_levels = str2num(get(zef**: Zef.ramus multires n levels = str2num(get(zef.
- `zef_ramus_inversion_tool.m` — **zef_ramus_inversion_tool**: Zef ramus inversion tool.
- `zef_ramus_iteration.m` — **zef_ramus_iteration**: Zef ramus iteration.
- `zef_ramus_window.m` — **zef_ramus_window**: Zef ramus window.

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
- `Call `if not(isfield(zef,'ramus_multires_dec'));` from MATLAB with the project root on the path.`
- `Call `zef.ramus_multires_n_levels = str2num(get(zef` from MATLAB with the project root on the path.`
- ``[zef] = zef_ramus_inversion_tool(zef)` with project root and `src` on the path.`
- ``[[z, reconstruction_information]] = zef_ramus_iteration(zef)` with project root and `src` on the path.`
- ``[zef] = zef_ramus_window(zef)` with project root and `src` on the path.`

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
