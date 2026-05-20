# src/gui/set

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_set_color.m` — **function zef_set_color**: Function zef set color.
- `zef_set_compartment_color.m` — **function zef_set_compartment_color**: Function zef set compartment color.
- `zef_set_sensor_color.m` — **function zef_set_sensor_color**: Function zef set sensor color.
- `zef_set_figure_current_size.m` — **if not(isempty(zef.zeffiro_current_size)); zef.zeffiro_current_size{str2num(get(gcf,'Tag'))} = zef_change_size_function(gcf,zef**: If not(isempty(zef.zeffiro current size)); zef.zeffiro current size{str2num(get(gcf,'Tag'))} = zef change size function(gcf,zef.
- `zef_set_lights.m` — **zef_set_lights**: Zef set lights.
- `zef_set_linear_colorbar_ticks.m` — **zef_set_linear_colorbar_ticks**: Zef set linear colorbar ticks.
- `zef_set_menu_size.m` — **zef_set_menu_size**: Zef set menu size.
- `zef_set_position.m` — **zef_set_position**: Zef set position.
- `zef_set_size_change_function.m` — **zef_set_size_change_function**: Zef set size change function.
- `zef_set_sliders_plot.m` — **zef_set_sliders_plot**: Zef set sliders plot.
- `zef_set_sliders_print.m` — **zef_set_sliders_print**: Zef set sliders print.
- `zef_set_surface_resolution.m` — **zef_set_surface_resolution**: Zef set surface resolution.
- `zef_set_timepointline.m` — **zef_set_timepointline**: Zef set timepointline.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

Open the corresponding tool or plugin from the Zeffiro menu bar (profile-dependent). Widget callbacks in this folder update `zef` and call `zef_update`.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `function zef_set_color` from MATLAB with the project root on the path.`
- `Call `function zef_set_compartment_color` from MATLAB with the project root on the path.`
- `Call `function zef_set_sensor_color` from MATLAB with the project root on the path.`
- `Call `if not(isempty(zef.zeffiro_current_size)); zef.zeffiro_current_size{str2num(get(gcf,'Tag'))} = zef_change_size_function(gcf,zef` from MATLAB with the project root on the path.`
- ``zef_set_lights(lights_vec, varargin)` with project root and `src` on the path.`
- ``zef_set_linear_colorbar_ticks(zef, n_ticks, n_digits, max_val)` with project root and `src` on the path.`
- ``zef_set_menu_size(zef, status)` with project root and `src` on the path.`
- ``[zef] = zef_set_position(zef)` with project root and `src` on the path.`

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
