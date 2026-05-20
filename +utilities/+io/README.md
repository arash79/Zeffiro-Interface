# +utilities/+io

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

MATLAB sources:
- `abspath.m` — **utilities.io.abspath**: Abspath.
- `float_is_int.m` — **utilities.io.float_is_int**: Float is int.
- `is_eof.m` — **utilities.io.is_eof**: Is eof.
- `read_gitmodules.m` — **utilities.io.read_gitmodules**: Read gitmodules.
- `reconstruction_from_edf_fn.m` — **utilities.io.reconstruction_from_edf_fn**: Reconstruction from edf fn.

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
- ``[abspaths] = utilities.io.abspath(files)` with project root and `src` on the path.`
- ``[is_int] = utilities.io.float_is_int(float)` with project root and `src` on the path.`
- ``[out] = utilities.io.is_eof(in)` with project root and `src` on the path.`
- ``[submodule_structs] = utilities.io.read_gitmodules(gitmodules_file, kwargs)` with project root and `src` on the path.`
- ``[[reconstruction, sample_rate, time_step]] = utilities.io.reconstruction_from_edf_fn(path_to_file)` with project root and `src` on the path.`

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
