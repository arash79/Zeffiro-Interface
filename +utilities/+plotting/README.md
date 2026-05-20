# +utilities/+plotting

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

MATLAB sources:
- `colorbar_from_figtool_fn.m` — **utilities.plotting.colorbar_from_figtool_fn**: Colorbar from figtool fn.
- `figure_without_colorbar_fn.m` — **utilities.plotting.figure_without_colorbar_fn**: Figure without colorbar fn.
- `figures_from_folder_without_colorbars.m` — **utilities.plotting.figures_from_folder_without_colorbars**: Figures from folder without colorbars.
- `box_plots_with_differing_whiskers_fn.m` — **utilities.plotting.function [fig, ax] = box_plots_with_differing_whiskers_fn( ...**: Function [fig, ax] = box plots with differing whiskers fn( ....

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
- ``utilities.plotting.colorbar_from_figtool_fn(figtool, filename_without_suffix, filetypes, kwargs)` with project root and `src` on the path.`
- ``utilities.plotting.figure_without_colorbar_fn(figtool, filename, filetypes, resolution)` with project root and `src` on the path.`
- ``utilities.plotting.figures_from_folder_without_colorbars(folder, filetypes, resolution)` with project root and `src` on the path.`
- ``utilities.plotting.function [fig, ax] = box_plots_with_differing_whiskers_fn( ...(data_cells, outlier_limits, x_tick_labels, x_label, …)` with project root and `src` on the path.`

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
