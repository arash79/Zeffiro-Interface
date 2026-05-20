# +examples/+meshing

## Purpose of this folder

Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.

## Contents

MATLAB sources:
- `zef_meshing_example_thalamus_refinement.m` — **examples.meshing.project_struct**: Example or study script demonstrating project_struct.
- `zef_meshing_example.m` — **examples.meshing.zef_meshing_example**: Example or study script demonstrating zef_meshing_example.

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
- `Call `examples.meshing.project_struct` from MATLAB with the project root on the path.`
- ``[project_struct] = examples.meshing.zef_meshing_example(kwargs)` with project root and `src` on the path.`

## Examples

Run scripts directly after startup, e.g. `run('+examples/+meshing/zef_meshing_example.m')`.
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
