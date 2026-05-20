# tools/plugins/SESAME/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `SESAME_inversion.m` — **SESAME_inversion**: SESAME inversion.
- `SESAMEneighbours.m` — **SESAMEneighbours**: SESAMEneighbours.
- `SESAME_core_check.m` — **function SESAME_core_check**: Function SESAME core check.
- `zef_init_SESAME.m` — **if not(isfield(zef,'SESAME_n_sampler'));**: If not(isfield(zef,'SESAME n sampler'));.
- `SESAME_plot_movie.m` — **if size(zef**: If size(zef.
- `inverse_SESAME.m` — **inverse_SESAME**: Inverse SESAME.
- `SESAME_App_run.m` — **zef**: Zef.
- `zef_update_SESAME.m` — **zef.SESAME_snr=str2double(zef.SESAME_App.h_SESAME_snr**: Zef.SESAME snr=str2double(zef.SESAME App.h SESAME snr.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef**: GUI callback or dialog (`zef`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[z] = SESAME_inversion(void)` with project root and `src` on the path.`
- ``[[neighbours, neighboursp]] = SESAMEneighbours(V)` with project root and `src` on the path.`
- `Call `function SESAME_core_check` from MATLAB with the project root on the path.`
- `Call `if not(isfield(zef,'SESAME_n_sampler'));` from MATLAB with the project root on the path.`
- `Call `if size(zef` from MATLAB with the project root on the path.`
- ``[result] = inverse_SESAME(full_data, leadfield, sourcespace, cfg)` with project root and `src` on the path.`
- `Call `zef` from MATLAB with the project root on the path.`
- `Call `zef.SESAME_snr=str2double(zef.SESAME_App.h_SESAME_snr` from MATLAB with the project root on the path.`

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
