# src/gui/apps

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_menu_tool_app_exported.m` — **zef_menu_tool_app_exported**: Zef menu tool app exported.
- `zef_mesh_tool_app_exported.m` — **zef_mesh_tool_app_exported**: Zef mesh tool app exported.
- `zef_mesh_visualization_tool_app_exported.m` — **zef_mesh_visualization_tool_app_exported**: Zef mesh visualization tool app exported.
- `zef_segmentation_tool_app_exported.m` — **zef_segmentation_tool_app_exported**: Zef segmentation tool app exported.

Other files:
- `zef_additional_options_app.mlapp`
- `zef_forward_and_inverse_processing_options.mlapp`
- `zef_forward_and_inverse_processing_options_2.mlapp`
- `zef_forward_simulation_tool.mlapp`
- `zef_gaussian_prior_options.mlapp`
- `zef_graphics_processing_options.mlapp`
- `zef_init_profile.mlapp`
- `zef_menu_tool_app.mlapp`
- `zef_mesh_tool_app.mlapp`
- `zef_mesh_visualization_tool_app.mlapp`
- `zef_nse_app.mlapp`
- `zef_nse_tool_app.mlapp`
- `zef_parameter_profile.mlapp`
- `zef_plugin_settings.mlapp`
- `zef_segmentation_profile.mlapp`
- `zef_segmentation_tool_app.mlapp`
- `zef_system_settings.mlapp`

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
- ``zef_menu_tool_app_exported(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.`
- ``zef_mesh_tool_app_exported(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.`
- ``zef_mesh_visualization_tool_app_exported(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.`
- ``zef_segmentation_tool_app_exported(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.`

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
