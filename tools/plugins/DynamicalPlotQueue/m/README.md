# tools/plugins/DynamicalPlotQueue/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

Subfolders:
- `dynamical_plot_queue_bank/`

MATLAB sources:
- `zef_dpq_add.m` — **zef_dpq_add**: Zef dpq add.
- `zef_dpq_delete.m` — **zef_dpq_delete**: Zef dpq delete.
- `zef_dpq_selection.m` — **zef_dpq_selection**: Zef dpq selection.
- `zeffiro_interface_dynamical_plot_queue.m` — **zef_dpq_start**: Zef dpq start.
- `zef_dpq_window.m` — **zef_dpq_window**: Zef dpq window.
- `zef_plot_dpq.m` — **zef_plot_dpq**: Renders or updates a plot_dpq figure from current `zef` state.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_dpq_delete**: GUI callback or dialog (`zef_dpq_delete`).
- **zef_dpq_selection**: GUI callback or dialog (`zef_dpq_selection`).
- **zef_dpq_window**: GUI callback or dialog (`zef_dpq_window`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[data_table] = zef_dpq_add(zef)` with project root and `src` on the path.`
- ``[data_table] = zef_dpq_delete(zef)` with project root and `src` on the path.`
- ``zef_dpq_selection(hObject, eventdata, handles)` with project root and `src` on the path.`
- ``[zef] = zef_dpq_start(zef)` with project root and `src` on the path.`
- ``[zef] = zef_dpq_window(zef)` with project root and `src` on the path.`
- ``zef_plot_dpq(type, zef)` with project root and `src` on the path.`

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
