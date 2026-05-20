# src/auxiliary/mesh_averaging

## Purpose of this folder

Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.

## Contents

MATLAB sources:
- `zef_average_lead_field.m` — **L_1 = zef**: L 1 = zef.
- `zef_find_distance_to_mesh.m` — **number_of_points = 10000;**: Number of points = 10000;.
- `zef_plot_surface_triangles.m` — **number_of_points = 10;**: Number of points = 10;.
- `zef_decompose_soure_space.m` — **zef_decompose_soure_space**: Zef decompose soure space.
- `zef_distance_to_mesh.m` — **zef_distance_to_mesh**: Zef distance to mesh.
- `zef_get_surface_triangles.m` — **zef_get_surface_triangles**: Zef get surface triangles.

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
- `Call `L_1 = zef` from MATLAB with the project root on the path.`
- `Call `number_of_points = 10000;` from MATLAB with the project root on the path.`
- `Call `number_of_points = 10;` from MATLAB with the project root on the path.`
- ``[[decomposition_ind, decomposition_count, dof_positions]] = zef_decompose_soure_space(source_count, center_points)` with project root and `src` on the path.`
- ``[distance_vec] = zef_distance_to_mesh(p, nodes, triangles)` with project root and `src` on the path.`
- ``[surface_triangles] = zef_get_surface_triangles(tetra, labels, compartment_ind)` with project root and `src` on the path.`

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
