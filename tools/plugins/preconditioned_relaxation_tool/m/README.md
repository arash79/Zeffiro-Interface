# tools/plugins/preconditioned_relaxation_tool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_relax_find_preconditioner.m` — **function [relax_preconditioner, relax_preconditioner_permutation] = zef_relax_find_preconditioner**: Function [relax preconditioner, relax preconditioner permutation] = zef relax find preconditioner.
- `zef_init_relax_inversion_tool.m` — **if not(isfield(zef,'relax_preconditioner'));**: If not(isfield(zef,'relax preconditioner'));.
- `zef_update_relax_inversion_tool.m` — **zef.relax_iteration_type = get(zef**: Zef.relax iteration type = get(zef.
- `zef_block_diagonal_preconditioner.m` — **zef_block_diagonal_preconditioner**: Zef block diagonal preconditioner.
- `zef_block_diagonal_preconditioner_uniform_prior.m` — **zef_block_diagonal_preconditioner_uniform_prior**: Zef block diagonal preconditioner uniform prior.
- `zef_relax_inversion_tool.m` — **zef_data = zef_relax;**: Zef data = zef relax;.
- `zef_diagonal_preconditioner_uniform_prior.m` — **zef_diagonal_preconditioner_uniform_prior**: Zef diagonal preconditioner uniform prior.
- `zef_make_multigrid_dec.m` — **zef_make_multigrid_dec**: Zef make multigrid dec.
- `zef_relax_iteration.m` — **zef_relax_iteration**: Zef relax iteration.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_data = zef_relax;**: GUI callback or dialog (`zef_data = zef_relax;`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `function [relax_preconditioner, relax_preconditioner_permutation] = zef_relax_find_preconditioner` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'relax_preconditioner'));` from MATLAB with the project root on the path.`
- `Call `zef.relax_iteration_type = get(zef` from MATLAB with the project root on the path.`
- ``[[M, multigrid_perm_output]] = zef_block_diagonal_preconditioner(L, multigrid_dec, multigrid_ind, multigrid_perm, …)` with project root and `src` on the path.`
- ``[[M, multigrid_perm_output]] = zef_block_diagonal_preconditioner_uniform_prior(L, multigrid_dec, multigrid_perm)` with project root and `src` on the path.`
- `Call `zef_data = zef_relax;` from MATLAB with the project root on the path.`
- ``[[M, multigrid_perm_output]] = zef_diagonal_preconditioner_uniform_prior(L, multigrid_dec, multigrid_perm)` with project root and `src` on the path.`
- ``[[multigrid_dec, multigrid_ind, multigrid_perm]] = zef_make_multigrid_dec(center_points, n_subset, n_decs, n_levels)` with project root and `src` on the path.`

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
