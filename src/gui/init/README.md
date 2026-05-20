# src/gui/init

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_init_init_profile.m` — **for zef_i = 1 : size(zef**: For zef i = 1 : size(zef.
- `zef_init_parameter_profile.m` — **for zef_i = 1 : size(zef**: For zef i = 1 : size(zef.
- `zef_init_sensors_parameter_profile.m` — **for zef_j = 1 : size(zef**: For zef j = 1 : size(zef.
- `zef_init_butterfly_plot.m` — **if not(isfield(zef,'bf_sampling_frequency'))**: If not(isfield(zef,'bf sampling frequency')).
- `zef_init_gaussian_prior_options.m` — **if not(isfield(zef,'inv_hyperprior_tail_length_db'));**: If not(isfield(zef,'inv hyperprior tail length db'));.
- `zef_init_parcellation.m` — **if not(isfield(zef,'parcellation_name'));**: If not(isfield(zef,'parcellation name'));.
- `zef_init_forward_and_inverse_options.m` — **if not(isfield(zef,'smoothing_steps_ele'));**: If not(isfield(zef,'smoothing steps ele'));.
- `zef_init_graphics_options.m` — **if not(isfield(zef,'streamline_draw'))**: If not(isfield(zef,'streamline draw')).
- `zef_init_options.m` — **if not(isfield(zef,'streamline_draw'))**: If not(isfield(zef,'streamline draw')).
- `zef_init_find_synthetic_eit_data.m` — **set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef**: Set(zef.h inv roi sphere 1 ,'string',num2str(zef.
- `zef_init_sensor_parameters.m` — **zef**: Zef.
- `zef_init_sensors.m` — **zef**: Zef.
- `zef_init_sensors_table.m` — **zef**: Zef.
- `zef_init_transform.m` — **zef**: Zef.
- `zef_init_transform_parameters.m` — **zef**: Zef.
- `zef_init_compartments.m` — **zef.h_compartment_table**: Zef.h compartment table.
- `zef_init_fields_compartment_table.m` — **zef.h_compartment_table.ColumnName(1:zef**: Zef.h compartment table.Column Name(1:zef.
- `zef_init_profile_table_selection.m` — **zef_init_profile_table_selection**: Initializes GUI widgets and default `zef` fields for profile_table_selection.
- `zef_init_sensors_name_table.m` — **zef_init_sensors_name_table**: Initializes GUI widgets and default `zef` fields for sensors_name_table.
- `zef_init_fields_compartment_table_profile.m` — **zef_n = 0;**: Zef n = 0;.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_init_profile_table_selection**: GUI callback or dialog (`zef_init_profile_table_selection`).
- **zef_init_sensors_name_table**: GUI callback or dialog (`zef_init_sensors_name_table`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `for zef_i = 1 : size(zef` from MATLAB with the project root on the path.`
- `Call `for zef_i = 1 : size(zef` from MATLAB with the project root on the path.`
- `Call `for zef_j = 1 : size(zef` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'bf_sampling_frequency'))` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'inv_hyperprior_tail_length_db'));` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'parcellation_name'));` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'smoothing_steps_ele'));` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'streamline_draw'))` from MATLAB with the project root on the path.`

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
