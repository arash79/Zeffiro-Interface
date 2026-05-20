# tools/plugins/ZeffiroFilterTool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

Subfolders:
- `filter_bank/`

MATLAB sources:
- `zef_filter_substitute_measurement_data.m` — **[zef**: [zef.
- `zef_filter_substitute_noise_data.m` — **[zef**: [zef.
- `zef_filter_substitute_raw_data.m` — **[zef**: [zef.
- `zef_filter_substitute_raw_data_with_measurement_data.m` — **[zef**: [zef.
- `zef_filter_plot_data.m` — **function zef_filter_plot_data**: Function zef filter plot data.
- `zef_filter_schroll_bar.m` — **if isfield(zef,'h_scroll_bar')**: If isfield(zef,'h scroll bar').
- `zef_filter_load.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_filter_save_as.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_filter_save_processed_data_as.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_import_raw_data.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_load_epoch_points.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_update_filter_tool.m` — **set(zef**: Set(zef.
- `zef_filter_reset.m` — **zef**: Zef.
- `zef_init_filter_tool.m` — **zef**: Zef.
- `zef_move_down_filter_item.m` — **zef.filter_pipeline =  zef.filter_pipeline([setdiff([1:length(zef.filter_pipeline)],zef.filter_pipeline_selected) zef**: Zef.filter pipeline =  zef.filter pipeline([setdiff([1:length(zef.filter pipeline)],zef.filter pipeline selected) zef.
- `zef_move_up_filter_item.m` — **zef.filter_pipeline =  zef.filter_pipeline([zef.filter_pipeline_selected setdiff([1:length(zef.filter_pipeline)],zef**: Zef.filter pipeline =  zef.filter pipeline([zef.filter pipeline selected setdiff([1:length(zef.filter pipeline)],zef.
- `zef_delete_filter_item.m` — **zef.filter_pipeline_selected = get(zef**: Zef.filter pipeline selected = get(zef.
- `zef_filter_tool.m` — **zef_data= zeffiro_interface_filter_tool;**: Zef data= zeffiro interface filter tool;.
- `zef_add_filter_item.m` — **zef_i = length(zef**: Zef i = length(zef.
- `zef_filter_raw_data.m` — **zef_update_filter_tool;**: Syncs GUI control values into `zef` for filter_tool;.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).
- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).
- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).
- **zef_data= zeffiro_interface_filter_tool;**: GUI callback or dialog (`zef_data= zeffiro_interface_filter_tool;`).
- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).
- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `[zef` from MATLAB with the project root on the path.`
- `Call `[zef` from MATLAB with the project root on the path.`
- `Call `[zef` from MATLAB with the project root on the path.`
- `Call `[zef` from MATLAB with the project root on the path.`
- `Call `function zef_filter_plot_data` from MATLAB with the project root on the path.`
- `Call `if isfield(zef,'h_scroll_bar')` from MATLAB with the project root on the path.`
- `Call `if not(isempty(zef.save_file_path)) & not(zef` from MATLAB with the project root on the path.`
- `Call `if not(isempty(zef.save_file_path)) & not(zef` from MATLAB with the project root on the path.`

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
