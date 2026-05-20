# tools/plugins/StripTool

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_create_strip.m` — **zef_create_strip**: Zef create strip.
- `zef_get_strip_contacts.m` — **zef_get_strip_contacts**: Zef get strip contacts.
- `zef_get_strip_parameters.m` — **zef_get_strip_parameters**: Zef get strip parameters.
- `zef_simple_cylinder_generator.m` — **zef_simple_cylinder_generator**: Zef simple cylinder generator.
- `zef_strip_coordinate_transform.m` — **zef_strip_coordinate_transform**: Zef strip coordinate transform.
- `zef_strip_tool_add.m` — **zef_strip_tool_add**: Zef strip tool add.
- `zef_strip_tool_add_contacts.m` — **zef_strip_tool_add_contacts**: Zef strip tool add contacts.
- `zef_strip_tool_delete.m` — **zef_strip_tool_delete**: Zef strip tool delete.
- `zef_strip_tool_embed.m` — **zef_strip_tool_embed**: Zef strip tool embed.
- `zef_strip_tool_init.m` — **zef_strip_tool_init**: Zef strip tool init.
- `zef_strip_tool_open.m` — **zef_strip_tool_open**: Zef strip tool open.
- `zef_strip_tool_plot.m` — **zef_strip_tool_plot**: Zef strip tool plot.
- `zef_strip_tool_start.m` — **zef_strip_tool_start**: Zef strip tool start.
- `zef_strip_tool_update.m` — **zef_strip_tool_update**: Zef strip tool update.
- `zef_strip_tool_window.m` — **zef_strip_tool_window**: Zef strip tool window.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_strip_tool_delete**: GUI callback or dialog (`zef_strip_tool_delete`).
- **zef_strip_tool_window**: GUI callback or dialog (`zef_strip_tool_window`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[strip_struct] = zef_create_strip(strip_struct)` with project root and `src` on the path.`
- ``[[contacts, sensor_info, triangle_ind]] = zef_get_strip_contacts(contact_index, strip_struct, zef, domain_type, …)` with project root and `src` on the path.`
- ``[strip_struct] = zef_get_strip_parameters(strip_struct)` with project root and `src` on the path.`
- ``[[T, P]] = zef_simple_cylinder_generator(R, N, L)` with project root and `src` on the path.`
- ``[points] = zef_strip_coordinate_transform(strip_struct, transform_type, points)` with project root and `src` on the path.`
- ``[zef] = zef_strip_tool_add(zef)` with project root and `src` on the path.`
- ``[zef] = zef_strip_tool_add_contacts(zef)` with project root and `src` on the path.`
- ``[zef] = zef_strip_tool_delete(zef)` with project root and `src` on the path.`

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
