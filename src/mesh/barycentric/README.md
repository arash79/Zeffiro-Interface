# src/mesh/barycentric

## Purpose of this folder

FEM mesh generation, surface processing, refinement, and barycentric operators.

## Contents

MATLAB sources:
- `zef_3by3_solver.m` — **zef_3by3_solver**: Zef 3by3 solver.
- `zef_barycentric_weighting.m` — **zef_barycentric_weighting**: Zef barycentric weighting.
- `zef_surface_scalar_matrix.m` — **zef_surface_scalar_matrix**: Zef surface scalar matrix.
- `zef_surface_scalar_matrix_D.m` — **zef_surface_scalar_matrix_D**: Zef surface scalar matrix D.
- `zef_surface_scalar_matrix_DD.m` — **zef_surface_scalar_matrix_DD**: Zef surface scalar matrix DD.
- `zef_surface_scalar_matrix_Dn.m` — **zef_surface_scalar_matrix_Dn**: Zef surface scalar matrix Dn.
- `zef_surface_scalar_matrix_FF.m` — **zef_surface_scalar_matrix_FF**: Zef surface scalar matrix FF.
- `zef_surface_scalar_matrix_FFn.m` — **zef_surface_scalar_matrix_FFn**: Zef surface scalar matrix FFn.
- `zef_surface_scalar_matrix_FG.m` — **zef_surface_scalar_matrix_FG**: Zef surface scalar matrix FG.
- `zef_surface_scalar_matrix_FGn.m` — **zef_surface_scalar_matrix_FGn**: Zef surface scalar matrix FGn.
- `zef_surface_scalar_matrix_n.m` — **zef_surface_scalar_matrix_n**: Zef surface scalar matrix n.
- `zef_surface_scalar_vector_F.m` — **zef_surface_scalar_vector_F**: Zef surface scalar vector F.
- `zef_surface_scalar_vector_Fn.m` — **zef_surface_scalar_vector_Fn**: Zef surface scalar vector Fn.
- `zef_volume_barycentric.m` — **zef_volume_barycentric**: Zef volume barycentric.
- `zef_volume_scalar_diagonal_matrix.m` — **zef_volume_scalar_diagonal_matrix**: Zef volume scalar diagonal matrix.
- `zef_volume_scalar_diagonal_matrix_FF.m` — **zef_volume_scalar_diagonal_matrix_FF**: Zef volume scalar diagonal matrix FF.
- `zef_volume_scalar_matrix.m` — **zef_volume_scalar_matrix**: Zef volume scalar matrix.
- `zef_volume_scalar_matrix_CC.m` — **zef_volume_scalar_matrix_CC**: Zef volume scalar matrix CC.
- `zef_volume_scalar_matrix_D.m` — **zef_volume_scalar_matrix_D**: Zef volume scalar matrix D.
- `zef_volume_scalar_matrix_DD.m` — **zef_volume_scalar_matrix_DD**: Zef volume scalar matrix DD.
- `zef_volume_scalar_matrix_FF.m` — **zef_volume_scalar_matrix_FF**: Zef volume scalar matrix FF.
- `zef_volume_scalar_matrix_FFG.m` — **zef_volume_scalar_matrix_FFG**: Zef volume scalar matrix FFG.
- `zef_volume_scalar_matrix_FG.m` — **zef_volume_scalar_matrix_FG**: Zef volume scalar matrix FG.
- `zef_volume_scalar_matrix_GCC.m` — **zef_volume_scalar_matrix_GCC**: Zef volume scalar matrix GCC.
- `zef_volume_scalar_matrix_GFu.m` — **zef_volume_scalar_matrix_GFu**: Zef volume scalar matrix GFu.
- `zef_volume_scalar_matrix_GG.m` — **zef_volume_scalar_matrix_GG**: Zef volume scalar matrix GG.
- `zef_volume_scalar_matrix_Kx.m` — **zef_volume_scalar_matrix_Kx**: Zef volume scalar matrix Kx.
- `zef_volume_scalar_matrix_uFG.m` — **zef_volume_scalar_matrix_uFG**: Zef volume scalar matrix u FG.
- `zef_volume_scalar_vector.m` — **zef_volume_scalar_vector**: Zef volume scalar vector.
- `zef_volume_scalar_vector_F.m` — **zef_volume_scalar_vector_F**: Zef volume scalar vector F.

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
- ``[[x, y, z]] = zef_3by3_solver(a, b, c, d, …)` with project root and `src` on the path.`
- ``[weighting] = zef_barycentric_weighting(weighting_type)` with project root and `src` on the path.`
- ``[M] = zef_surface_scalar_matrix(nodes, tetra, scalar_field, weighting)` with project root and `src` on the path.`
- ``[M] = zef_surface_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, …)` with project root and `src` on the path.`
- ``[M] = zef_surface_scalar_matrix_DD(nodes, tetra, g_i_ind, g_j_ind, …)` with project root and `src` on the path.`
- ``[M] = zef_surface_scalar_matrix_Dn(nodes, tetra, g_i_ind, n_ind, …)` with project root and `src` on the path.`
- ``[M] = zef_surface_scalar_matrix_FF(nodes, tetra, scalar_field)` with project root and `src` on the path.`
- ``[M] = zef_surface_scalar_matrix_FFn(nodes, tetra, n_ind, scalar_field)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
