# src/visualization/graph_bank

## Purpose of this folder

Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.

## Contents

MATLAB sources:
- `zef_histogram.m` — **zef_histogram**: Zef histogram.
- `zef_logarithmic_distribution.m` — **zef_logarithmic_distribution**: Zef logarithmic distribution.
- `zef_logarithmic_histogram.m` — **zef_logarithmic_distribution**: Zef logarithmic distribution.
- `zef_plot_dof_space.m` — **zef_plot_dof_space**: Renders or updates a plot_dof_space figure from current `zef` state.

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
- ``zef_histogram(parameter_vec)` with project root and `src` on the path.`
- ``zef_logarithmic_distribution(parameter_vec)` with project root and `src` on the path.`
- ``zef_logarithmic_distribution(parameter_vec)` with project root and `src` on the path.`
- ``zef_plot_dof_space(void)` with project root and `src` on the path.`

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
