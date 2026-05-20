# tools/plugins/WireframeTool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `wireframe.m` — **wireframe**: Wireframe.
- `zef_wireframe_creator_start.m` — **zef_data = zef_wireframe_creator_app;**: Zef data = zef wireframe creator app;.
- `zef_wireframe_filling_vec.m` — **zef_wireframe_filling_vec**: Zef wireframe filling vec.
- `zef_wireframe_permittivity_vec.m` — **zef_wireframe_permittivity_vec**: Zef wireframe permittivity vec.
- `zef_wireframe_plot.m` — **zef_wireframe_plot**: Zef wireframe plot.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_data = zef_wireframe_creator_app;**: GUI callback or dialog (`zef_data = zef_wireframe_creator_app;`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[[m_triangles, m_nodes, filling_vec]] = wireframe(tetra, nodes, domain_labels, filling_vec, …)` with project root and `src` on the path.`
- `Call `zef_data = zef_wireframe_creator_app;` from MATLAB with the project root on the path.`
- ``[filling_vec] = zef_wireframe_filling_vec(eps_vec_1, eps_vec_2)` with project root and `src` on the path.`
- ``[p_vec] = zef_wireframe_permittivity_vec(f_vec, p_val)` with project root and `src` on the path.`
- ``zef_wireframe_plot(w_t, w_n)` with project root and `src` on the path.`

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
