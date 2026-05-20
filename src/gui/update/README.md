# src/gui/update

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_update_options.m` — **if zef**: If zef.
- `zef_update_parameters.m` — **zef.aux_field_1 = zef.h_parameters_table**: Zef.aux field 1 = zef.h parameters table.
- `zef_update_transform_parameters.m` — **zef.aux_field_1 = zef.h_parameters_table**: Zef.aux field 1 = zef.h parameters table.
- `zef_update_sensors_name_table.m` — **zef.aux_field_1 = zef.h_sensors_name_table**: Zef.aux field 1 = zef.h sensors name table.
- `zef_update_butterfly_plot.m` — **zef.bf_sampling_frequency = str2num(get(zef**: Zef.bf sampling frequency = str2num(get(zef.
- `zef_update_gaussian_prior_options.m` — **zef.inv_hyperprior_weight = str2num(get(zef**: Zef.inv hyperprior weight = str2num(get(zef.
- `zef_update_find_synthetic_eit_data.m` — **zef.inv_roi_sphere(:,1) = str2num(get(zef**: Zef.inv roi sphere(:,1) = str2num(get(zef.
- `zef_update_forward_and_inverse_options.m` — **zef.preconditioner = get(zef**: Zef.preconditioner = get(zef.
- `zef_update_graphics_options.m` — **zef.use_gpu_graphic = get(zef**: Zef.use gpu graphic = get(zef.
- `zef_update_ambience.m` — **zef_update_ambience**: Syncs GUI control values into `zef` for ambience.
- `zef_update_brightness.m` — **zef_update_brightness**: Syncs GUI control values into `zef` for brightness.
- `zef_update_colormap.m` — **zef_update_colormap**: Syncs GUI control values into `zef` for colormap.
- `zef_update_colorscale.m` — **zef_update_colorscale**: Syncs GUI control values into `zef` for colorscale.
- `zef_update_colorscale_max.m` — **zef_update_colorscale_max**: Syncs GUI control values into `zef` for colorscale_max.
- `zef_update_colorscale_min.m` — **zef_update_colorscale_min**: Syncs GUI control values into `zef` for colorscale_min.
- `zef_update_compartment_table_data.m` — **zef_update_compartment_table_data**: Syncs GUI control values into `zef` for compartment_table_data.
- `zef_update_contour.m` — **zef_update_contour**: Syncs GUI control values into `zef` for contour.
- `zef_update_contrast.m` — **zef_update_contrast**: Syncs GUI control values into `zef` for contrast.
- `zef_update_contrast_and_brightness.m` — **zef_update_contrast**: Syncs GUI control values into `zef` for contrast.
- `zef_update_diffusion.m` — **zef_update_diffusion**: Syncs GUI control values into `zef` for diffusion.
- `zef_update_fig_details.m` — **zef_update_fig_details**: Syncs GUI control values into `zef` for fig_details.
- `zef_update_labeling_priority.m` — **zef_update_labeling_priority**: Syncs GUI control values into `zef` for labeling_priority.
- `zef_update_lead_field_id.m` — **zef_update_lead_field_id**: Syncs GUI control values into `zef` for lead_field_id.
- `zef_update_lights.m` — **zef_update_lights**: Syncs GUI control values into `zef` for lights.
- `zef_update_parameter_distributions.m` — **zef_update_parameter_distributions**: Syncs GUI control values into `zef` for parameter_distributions.
- `zef_update_parcellation.m` — **zef_update_parcellation**: Syncs GUI control values into `zef` for parcellation.
- `zef_update_source_positions.m` — **zef_update_source_positions**: Syncs GUI control values into `zef` for source_positions.
- `zef_update_specular.m` — **zef_update_specular**: Syncs GUI control values into `zef` for specular.
- `zef_update_transform.m` — **zef_update_transform**: Syncs GUI control values into `zef` for transform.
- `zef_update_transparency_additional.m` — **zef_update_transparency_additional**: Syncs GUI control values into `zef` for transparency_additional.
- `zef_update_transparency_cones.m` — **zef_update_transparency_cones**: Syncs GUI control values into `zef` for transparency_cones.
- `zef_update_transparency_reconstruction.m` — **zef_update_transparency_reconstruction**: Syncs GUI control values into `zef` for transparency_reconstruction.
- `zef_update_transparency_sensor.m` — **zef_update_transparency_sensor**: Syncs GUI control values into `zef` for transparency_sensor.
- `zef_update_transparency_surface.m` — **zef_update_transparency_surface**: Syncs GUI control values into `zef` for transparency_surface.
- `zef_update_zoom.m` — **zef_update_zoom**: Syncs GUI control values into `zef` for zoom.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_update_compartment_table_data**: GUI callback or dialog (`zef_update_compartment_table_data`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `if zef` from MATLAB with the project root on the path.`
- `Call `zef.aux_field_1 = zef.h_parameters_table` from MATLAB with the project root on the path.`
- `Call `zef.aux_field_1 = zef.h_parameters_table` from MATLAB with the project root on the path.`
- `Call `zef.aux_field_1 = zef.h_sensors_name_table` from MATLAB with the project root on the path.`
- `Call `zef.bf_sampling_frequency = str2num(get(zef` from MATLAB with the project root on the path.`
- `Call `zef.inv_hyperprior_weight = str2num(get(zef` from MATLAB with the project root on the path.`
- `Call `zef.inv_roi_sphere(:,1) = str2num(get(zef` from MATLAB with the project root on the path.`
- `Call `zef.preconditioner = get(zef` from MATLAB with the project root on the path.`

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
