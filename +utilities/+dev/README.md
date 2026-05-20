# +utilities/+dev

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

MATLAB sources:
- `copy_dependencies_to_folder.m` — **utilities.dev.copy_dependencies_to_folder**: Copy dependencies to folder.
- `get_mfile_paths.m` — **utilities.dev.get_mfile_paths**: Get mfile paths.
- `indent_mfile.m` — **utilities.dev.indent_mfile**: Indent mfile.
- `indent_mfiles.m` — **utilities.dev.indent_mfiles**: Indent mfiles.
- `lint_mfiles.m` — **utilities.dev.lint_mfiles**: Lint mfiles.

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
- ``[messages] = utilities.dev.copy_dependencies_to_folder(file, target_folder, kwargs)` with project root and `src` on the path.`
- ``[mfiles] = utilities.dev.get_mfile_paths(folder)` with project root and `src` on the path.`
- ``utilities.dev.indent_mfile(filename)` with project root and `src` on the path.`
- ``utilities.dev.indent_mfiles(folder)` with project root and `src` on the path.`
- ``utilities.dev.lint_mfiles(folder, kwargs)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
