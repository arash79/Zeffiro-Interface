# tools/plugins/GMMClustering/GMModeling App (JL)/m/BasicGMM

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `GMM2amplitude.m` — **GMM2amplitude**: GMM2amplitude.
- `zef_GMModeling.m` — **function [GMModel,GMModelDipoles,GMModelAmplitudes,GMModelTimeVariables] = zef_GMModeling**: Function [GMModel,GMModel Dipoles,GMModel Amplitudes,GMModel Time Variables] = zef GMModeling.
- `zef_GMModeling_K.m` — **function [GMModel,GMModelDipoles,GMModelAmplitudes,GMModelTimeVariables] = zef_GMModeling_K**: Function [GMModel,GMModel Dipoles,GMModel Amplitudes,GMModel Time Variables] = zef GMModeling K.
- `zef_PlotGMModel.m` — **function zef_PlotGMModel**: Function zef Plot GMModel.
- `zef_plot_GMM_amplitudes.m` — **function zef_plot_GMM_amplitudes**: Function zef plot GMM amplitudes.
- `GMModelApp_start.m` — **if isfield(zef,'GMM**: If isfield(zef,'GMM.
- `zef_GMMExport_start.m` — **if isfield(zef.GMM**: If isfield(zef.GMM.
- `zef_GMMPlotOpt.m` — **if isfield(zef.GMM**: If isfield(zef.GMM.
- `zef_GMM_AdvModelingOpt.m` — **if isfield(zef.GMM**: If isfield(zef.GMM.
- `zef_GMM_export.m` — **zef_GMM_export**: Zef GMM export.
- `zef_GMM_subs_time_vars.m` — **zef_GMM_subs_time_vars**: Zef GMM subs time vars.
- `zef_update_GMMPlotOpts.m` — **zef_ind = find(strcmp(zef.GMM.parameters**: Zef ind = find(strcmp(zef.GMM.parameters.
- `zef_load_GMM.m` — **zef_load_GMM**: Loads external data or a saved Zeffiro project into `zef`.
- `zef_GMM_update.m` — **zef_n=0;**: Zef n=0;.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **if isfield(zef,'GMM**: GUI callback or dialog (`if isfield(zef,'GMM`).
- **if isfield(zef.GMM**: GUI callback or dialog (`if isfield(zef.GMM`).
- **if isfield(zef.GMM**: GUI callback or dialog (`if isfield(zef.GMM`).
- **if isfield(zef.GMM**: GUI callback or dialog (`if isfield(zef.GMM`).
- **zef_GMM_export**: GUI callback or dialog (`zef_GMM_export`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[amp] = GMM2amplitude(dipoles, ind, frame, type)` with project root and `src` on the path.`
- `Call `function [GMModel,GMModelDipoles,GMModelAmplitudes,GMModelTimeVariables] = zef_GMModeling` from MATLAB with the project root on the path.`
- `Call `function [GMModel,GMModelDipoles,GMModelAmplitudes,GMModelTimeVariables] = zef_GMModeling_K` from MATLAB with the project root on the path.`
- `Call `function zef_PlotGMModel` from MATLAB with the project root on the path.`
- `Call `function zef_plot_GMM_amplitudes` from MATLAB with the project root on the path.`
- `Call `if isfield(zef,'GMM` from MATLAB with the project root on the path.`
- `Call `if isfield(zef.GMM` from MATLAB with the project root on the path.`
- `Call `if isfield(zef.GMM` from MATLAB with the project root on the path.`

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
