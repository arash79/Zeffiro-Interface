# src/gui/open

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_open_init_profile.m` — **zef_data = zef_init_profile;**: Zef data = zef init profile;.
- `zef_open_parameter_profile.m` — **zef_data = zef_parameter_profile;**: Zef data = zef parameter profile;.
- `zef_open_plugin_settings.m` — **zef_data = zef_plugin_settings;**: Zef data = zef plugin settings;.
- `zef_open_segmentation_profile.m` — **zef_data = zef_segmentation_profile;**: Zef data = zef segmentation profile;.
- `zef_open_system_settings.m` — **zef_data = zef_system_settings;**: Zef data = zef system settings;.
- `zef_open_forward_and_inverse_options.m` — **zef_init_forward_and_inverse_options;**: Initializes GUI widgets and default `zef` fields for forward_and_inverse_options;.
- `zef_open_gaussian_prior_options.m` — **zef_init_gaussian_prior_options;**: Initializes GUI widgets and default `zef` fields for gaussian_prior_options;.
- `zef_open_graphics_options.m` — **zef_init_graphics_options;**: Initializes GUI widgets and default `zef` fields for graphics_options;.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_init_forward_and_inverse_options;**: GUI callback or dialog (`zef_init_forward_and_inverse_options;`).
- **zef_init_gaussian_prior_options;**: GUI callback or dialog (`zef_init_gaussian_prior_options;`).
- **zef_init_graphics_options;**: GUI callback or dialog (`zef_init_graphics_options;`).
- **zef_data = zef_init_profile;**: GUI callback or dialog (`zef_data = zef_init_profile;`).
- **zef_data = zef_parameter_profile;**: GUI callback or dialog (`zef_data = zef_parameter_profile;`).
- **zef_data = zef_plugin_settings;**: GUI callback or dialog (`zef_data = zef_plugin_settings;`).
- **zef_data = zef_segmentation_profile;**: GUI callback or dialog (`zef_data = zef_segmentation_profile;`).
- **zef_data = zef_system_settings;**: GUI callback or dialog (`zef_data = zef_system_settings;`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `zef_data = zef_init_profile;` from MATLAB with the project root on the path.`
- `Call `zef_data = zef_parameter_profile;` from MATLAB with the project root on the path.`
- `Call `zef_data = zef_plugin_settings;` from MATLAB with the project root on the path.`
- `Call `zef_data = zef_segmentation_profile;` from MATLAB with the project root on the path.`
- `Call `zef_data = zef_system_settings;` from MATLAB with the project root on the path.`
- `Call `zef_init_forward_and_inverse_options;` from MATLAB with the project root on the path.`
- `Call `zef_init_gaussian_prior_options;` from MATLAB with the project root on the path.`
- `Call `zef_init_graphics_options;` from MATLAB with the project root on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
