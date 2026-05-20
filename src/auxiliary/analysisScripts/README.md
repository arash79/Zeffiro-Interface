# src/auxiliary/analysisScripts

## Purpose of this folder

Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.

## Contents

MATLAB sources:
- `makeReconstructions.m` — **[zef.reconstruction, zef**: [zef.reconstruction, zef.
- `makeReconstructions_forAllData.m` — **allHashes=fieldnames(zef.dataBank**: All Hashes=fieldnames(zef.data Bank.
- `dataBank_delete_x.m` — **dltType='gmm';**: Dlt Type='gmm';.
- `makeGMM.m` — **for gmm_opt=1:3**: For gmm opt=1:3.
- `snrTest.m` — **if ~strcmp(zef.dataBank.app.Entrytype**: If ~strcmp(zef.data Bank.app.Entrytype.
- `p_snr_makeAll.m` — **meg_max=0**: Meg max=0.
- `p_outputNew.m` — **p='p1';**: P='p1';.
- `p_outputNew_subplot.m` — **p='p1';**: P='p1';.
- `snrTestImageP1.m` — **pat='p1';**: Pat='p1';.
- `snrTestImageP2.m` — **pat='p2';**: Pat='p2';.
- `gmm_subplot.m` — **tree.all=zef.dataBank**: Tree.all=zef.data Bank.
- `zef_GMM_resection_volume.m` — **zef_GMM_resection_volume**: Zef GMM resection volume.
- `zef_distance_to_resection.m` — **zef_distance_to_resection**: Zef distance to resection.
- `zef_insideGMM.m` — **zef_insideGMM**: Zef inside GMM.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `[zef.reconstruction, zef` from MATLAB with the project root on the path.`
- `Call `allHashes=fieldnames(zef.dataBank` from MATLAB with the project root on the path.`
- `Call `dltType='gmm';` from MATLAB with the project root on the path.`
- `Call `for gmm_opt=1:3` from MATLAB with the project root on the path.`
- `Call `if ~strcmp(zef.dataBank.app.Entrytype` from MATLAB with the project root on the path.`
- `Call `meg_max=0` from MATLAB with the project root on the path.`
- `Call `p='p1';` from MATLAB with the project root on the path.`
- `Call `p='p1';` from MATLAB with the project root on the path.`

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
