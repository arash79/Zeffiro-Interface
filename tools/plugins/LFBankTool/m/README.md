# tools/plugins/LFBankTool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

Subfolders:
- `lead_field_normalization_functions/`

MATLAB sources:
- `zef_lf_bank_update_noise_data.m` — **for zef_i = 1:length(zef**: For zef i = 1:length(zef.
- `zef_update_lf_bank_tool.m` — **if isfield(zef,'h_lf_bank_tool')**: If isfield(zef,'h lf bank tool').
- `zef_add_lf_item.m` — **if not(isempty(zef**: If not(isempty(zef.
- `zef_init_lf_bank_tool.m` — **if not(isfield(zef,'lf_bank_scaling_factor'));**: If not(isfield(zef,'lf bank scaling factor'));.
- `zef_combine_lead_fields.m` — **zef.lf_item_selected = get(zef**: Zef.lf item selected = get(zef.
- `zef_delete_lf_item.m` — **zef.lf_item_selected = get(zef**: Zef.lf item selected = get(zef.
- `zef_lf_bank_compute_lead_fields.m` — **zef.lf_item_selected = get(zef**: Zef.lf item selected = get(zef.
- `zef_lf_bank_update_measurements.m` — **zef.lf_item_selected = get(zef**: Zef.lf item selected = get(zef.
- `zef_lf_bank_tool.m` — **zef_data = zeffiro_interface_lf_bank_tool;**: Zef data = zeffiro interface lf bank tool;.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_data = zeffiro_interface_lf_bank_tool;**: GUI callback or dialog (`zef_data = zeffiro_interface_lf_bank_tool;`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `for zef_i = 1:length(zef` from MATLAB with the project root on the path.`
- `Call `if isfield(zef,'h_lf_bank_tool')` from MATLAB with the project root on the path.`
- `Call `if not(isempty(zef` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'lf_bank_scaling_factor'));` from MATLAB with the project root on the path.`
- `Call `zef.lf_item_selected = get(zef` from MATLAB with the project root on the path.`
- `Call `zef.lf_item_selected = get(zef` from MATLAB with the project root on the path.`
- `Call `zef.lf_item_selected = get(zef` from MATLAB with the project root on the path.`
- `Call `zef.lf_item_selected = get(zef` from MATLAB with the project root on the path.`

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
