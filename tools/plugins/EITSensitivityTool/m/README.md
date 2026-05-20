# tools/plugins/EITSensitivityTool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_eit_sensitivity_tool_import.m` — **[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef**: [zef.file zef.file path] = uigetfile({'*.mat'},'Import interpolation',zef.
- `zef_eit_sensitivity_tool_import_2.m` — **[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef**: [zef.file zef.file path] = uigetfile({'*.mat'},'Import interpolation',zef.
- `zef_eit_sensitivity_tool_substitute.m` — **if isequal(zef.h_eit_sensitivity_tool_distribution.Value,zef.h_eit_sensitivity_tool_distribution**: If isequal(zef.h eit sensitivity tool distribution.Value,zef.h eit sensitivity tool distribution.
- `zef_eit_sensitivity_tool_volume.m` — **tilavuus_vec**: Tilavuus vec.
- `zef_eit_sensitivity_tool_start.m` — **zef_data = zef_eit_sensitivity_tool;**: Zef data = zef eit sensitivity tool;.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_data = zef_eit_sensitivity_tool;**: GUI callback or dialog (`zef_data = zef_eit_sensitivity_tool;`).
- **if isequal(zef.h_eit_sensitivity_tool_distribution.Value,zef.h_eit_sensitivity_tool_distribution**: GUI callback or dialog (`if isequal(zef.h_eit_sensitivity_tool_distribution.Value,zef.h_eit_sensitivity_tool_distribution`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef` from MATLAB with the project root on the path.`
- `Call `[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef` from MATLAB with the project root on the path.`
- `Call `if isequal(zef.h_eit_sensitivity_tool_distribution.Value,zef.h_eit_sensitivity_tool_distribution` from MATLAB with the project root on the path.`
- `Call `tilavuus_vec` from MATLAB with the project root on the path.`
- `Call `zef_data = zef_eit_sensitivity_tool;` from MATLAB with the project root on the path.`

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
