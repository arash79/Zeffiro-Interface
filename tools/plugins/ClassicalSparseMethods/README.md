# tools/plugins/ClassicalSparseMethods

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_CSM_iteration.m` — **function [z,reconstruction_information] = zef_CSM_iteration**: Function [z,reconstruction information] = zef CSM iteration.
- `CSM_app_start.m` — **zef**: Zef.

Other files:
- `CSM_app.mlapp`
- `README`

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef**: GUI callback or dialog (`zef`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `function [z,reconstruction_information] = zef_CSM_iteration` from MATLAB with the project root on the path.`
- `Call `zef` from MATLAB with the project root on the path.`

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
