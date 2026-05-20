# tools/plugins/ZeffiroFilterTool/m/filter_bank

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_constant_epoching.m` — **zef_constant_epoching**: Zef constant epoching.
- `zef_define_time_interval.m` — **zef_define_time_interval**: Zef define time interval.
- `zef_electrode_reference.m` — **zef_electrode_reference**: Zef electrode reference.
- `zef_ellip_band_stop_filter.m` — **zef_ellip_band_stop_filter**: Zef ellip band stop filter.
- `zef_ellip_high_pass_filter.m` — **zef_ellip_high_pass_filter**: Zef ellip high pass filter.
- `zef_ellip_low_pass_filter.m` — **zef_ellip_low_pass_filter**: Zef ellip low pass filter.
- `zef_exclude_channels.m` — **zef_exclude_channels**: Zef exclude channels.
- `zef_manual_epoching.m` — **zef_manual_epoching**: Zef manual epoching.
- `zef_select_channels.m` — **zef_select_channels**: Zef select channels.
- `zef_simple_downsampling_filter.m` — **zef_simple_downsampling_filter**: Zef simple downsampling filter.
- `zef_simple_ica_cleaning.m` — **zef_simple_ica_cleaning**: Zef simple ica cleaning.
- `zef_threshold_epoching.m` — **zef_threshold_epoching**: Zef threshold epoching.
- `zef_zero_reference.m` — **zef_zero_reference**: Zef zero reference.

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
- ``[processed_data] = zef_constant_epoching(f, first_epoch_point, epoch_step, number_of_epochs, …)` with project root and `src` on the path.`
- ``[processed_data] = zef_define_time_interval(f, start_time, end_time, sampling_frequency)` with project root and `src` on the path.`
- ``[processed_data] = zef_electrode_reference(f, electrode_index)` with project root and `src` on the path.`
- ``[processed_data] = zef_ellip_band_stop_filter(f, filter_order, ripple, attenuation, …)` with project root and `src` on the path.`
- ``[processed_data] = zef_ellip_high_pass_filter(f, filter_order, ripple, attenuation, …)` with project root and `src` on the path.`
- ``[processed_data] = zef_ellip_low_pass_filter(f, filter_order, ripple, attenuation, …)` with project root and `src` on the path.`
- ``[processed_data] = zef_exclude_channels(f, exclude_channels)` with project root and `src` on the path.`
- ``[processed_data] = zef_manual_epoching(f, epoch_points, start_time, end_time, …)` with project root and `src` on the path.`

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
