# tools/plugins/LeadFieldProcessingTool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_LeadfieldProcessingTool_loadTra.m` — **', 'select tra file', '***: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_BankTableLabelUpdate.m` — **for zef_LeadFieldProcessingTool_TableUpdate_index2=1:size(zef.LeadFieldProcessingTool.app.BankTable**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_aux2current.m` — **for zef_LeadFieldProcessingTool_index=1:zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_mag2Grad.m` — **for zef_LeadFieldProcessingTool_index=1:zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_combine.m` — **zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_combinebla.m` — **zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_refresh.m` — **zef.LeadFieldProcessingTool.app.currentLeadfield.Data={zef.lf_tag, zef.imaging_method_cell{zef.imaging_method}, size(zef.sensors, 1), size(zef.source_positions, 1), zef**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadFieldProcessingTool_add.m` — **zef.LeadFieldProcessingTool.auxData.source_interpolation_ind = zef**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadFieldProcessingTool_addCurrentData2bank.m` — **zef.LeadFieldProcessingTool.auxData.source_interpolation_ind = zef**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_bank2aux_bank2auxIndex.m` — **zef.LeadFieldProcessingTool.auxData=zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_delete.m` — **zef.LeadFieldProcessingTool.bank=zef.LeadFieldProcessingTool.bank(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadFieldProcessingTool_aux2bank_new.m` — **zef.LeadFieldProcessingTool.bankPosition=zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadFieldProcessingTool_aux2bank_bankPosition.m` — **zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bankPosition}=zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_LeadfieldProcessingTool_updateTable.m` — **zef_LeadFieldProcessingTool_TableUpdate_index=zef.LeadFieldProcessingTool**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_LeadFieldProcessingTool_TableUpdate_index=zef.LeadFieldProcessingTool**: GUI callback or dialog (`zef_LeadFieldProcessingTool_TableUpdate_index=zef.LeadFieldProcessingTool`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `', 'select tra file', '*` from MATLAB with the project root on the path.`
- `Call `for zef_LeadFieldProcessingTool_TableUpdate_index2=1:size(zef.LeadFieldProcessingTool.app.BankTable` from MATLAB with the project root on the path.`
- `Call `for zef_LeadFieldProcessingTool_index=1:zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.`
- `Call `for zef_LeadFieldProcessingTool_index=1:zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.`
- `Call `zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.`
- `Call `zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.`
- `Call `zef.LeadFieldProcessingTool.app.currentLeadfield.Data={zef.lf_tag, zef.imaging_method_cell{zef.imaging_method}, size(zef.sensors, 1), size(zef.source_positions, 1), zef` from MATLAB with the project root on the path.`
- `Call `zef.LeadFieldProcessingTool.auxData.source_interpolation_ind = zef` from MATLAB with the project root on the path.`

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
