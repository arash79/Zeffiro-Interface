# tools/plugins/GithubPusher/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_github_updater_start.m` — **zef_data = zef_github_updater;**: Zef data = zef github updater;.
- `zef_git_push.m` — **zef_git_push**: Zef git push.
- `zef_github_updater_script.m` — **zef_git_push(zef.h_github_pat.Value,'message',[zef.h_github_author.Value  ': ' char(join(string(zef.h_github_message**: Zef git push(zef.h github pat.Value,'message',[zef.h github author.Value  ': ' char(join(string(zef.h github message.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_data = zef_github_updater;**: GUI callback or dialog (`zef_data = zef_github_updater;`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `zef_data = zef_github_updater;` from MATLAB with the project root on the path.`
- ``zef_git_push(my_key, varargin)` with project root and `src` on the path.`
- `Call `zef_git_push(zef.h_github_pat.Value,'message',[zef.h_github_author.Value  ': ' char(join(string(zef.h_github_message` from MATLAB with the project root on the path.`

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
