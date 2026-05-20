# tools/plugins/MNETool/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_init_mne.m` — **if not(isfield(zef,'mne_prior'));**: If not(isfield(zef,'mne prior'));.
- `zef_update_mne.m` — **zef.mne_prior = get(zef**: Zef.mne prior = get(zef.
- `zef_find_mne_reconstruction.m` — **zef_find_mne_reconstruction**: Zef find mne reconstruction.
- `zef_minimum_norm_estimation.m` — **zef_minimum_norm_estimation**: Zef minimum norm estimation.
- `zef_mne_tool_export.m` — **zef_mne_tool_export**: Zef mne tool export.
- `zef_mne_tool_start.m` — **zef_mne_tool_start**: Zef mne tool start.
- `zef_mne_tool_window.m` — **zef_mne_tool_window**: Zef mne tool window.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_mne_tool_export**: GUI callback or dialog (`zef_mne_tool_export`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `if not(isfield(zef,'mne_prior'));` from MATLAB with the project root on the path.`
- `Call `zef.mne_prior = get(zef` from MATLAB with the project root on the path.`
- ``[[z, info]] = zef_find_mne_reconstruction(zef, data_mode)` with project root and `src` on the path.`
- ``[zef] = zef_minimum_norm_estimation(zef)` with project root and `src` on the path.`
- `Call `zef_mne_tool_export` from MATLAB with the project root on the path.`
- ``[zef] = zef_mne_tool_start(zef)` with project root and `src` on the path.`
- ``[zef] = zef_mne_tool_window(zef)` with project root and `src` on the path.`

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
