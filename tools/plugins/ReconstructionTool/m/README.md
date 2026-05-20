# tools/plugins/ReconstructionTool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

Subfolders:
- `apply_functions/`

MATLAB sources:
- `zef_reconstructionTool_replace.m` — **[~, indexOfMinimumTrueElement]=max(cell2mat( zef.reconstructionTool**: [~, index Of Minimum True Element]=max(cell2mat( zef.reconstruction Tool.
- `zef_reconstructionTool_import.m` — **function [reconstruction,reconstruction_information] = zef_reconstructionTool_import**: Function [reconstruction,reconstruction information] = zef reconstruction Tool import.
- `zef_reconstructionTool_apply.m` — **trueDex=cell2mat( zef.reconstructionTool**: True Dex=cell2mat( zef.reconstruction Tool.
- `zef_reconstructionTool_refresh.m` — **zef.reconstructionTool**: Zef.reconstruction Tool.
- `zef_reconstructionTool_delete.m` — **zef.reconstructionTool.bankReconstruction = zef.reconstructionTool.bankReconstruction(~cell2mat( zef.reconstructionTool**: Zef.reconstruction Tool.bank Reconstruction = zef.reconstruction Tool.bank Reconstruction(~cell2mat( zef.reconstruction Tool.
- `zef_reconstructionTool_addCurrent2bank.m` — **zef.reconstructionTool.bankSize=zef.reconstructionTool**: Zef.reconstruction Tool.bank Size=zef.reconstruction Tool.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **function [reconstruction,reconstruction_information] = zef_reconstructionTool_import**: GUI callback or dialog (`function [reconstruction,reconstruction_information] = zef_reconstructionTool_import`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `[~, indexOfMinimumTrueElement]=max(cell2mat( zef.reconstructionTool` from MATLAB with the project root on the path.`
- `Call `function [reconstruction,reconstruction_information] = zef_reconstructionTool_import` from MATLAB with the project root on the path.`
- `Call `trueDex=cell2mat( zef.reconstructionTool` from MATLAB with the project root on the path.`
- `Call `zef.reconstructionTool` from MATLAB with the project root on the path.`
- `Call `zef.reconstructionTool.bankReconstruction = zef.reconstructionTool.bankReconstruction(~cell2mat( zef.reconstructionTool` from MATLAB with the project root on the path.`
- `Call `zef.reconstructionTool.bankSize=zef.reconstructionTool` from MATLAB with the project root on the path.`

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
