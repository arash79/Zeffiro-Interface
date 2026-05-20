# src/auxiliary

## Purpose of this folder

Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.

## Contents

Subfolders:
- `analysisScripts/`
- `mesh_averaging/`
- `mri/`
- `plotting/`

MATLAB sources:
- `calc_diffs.m` — **ary_model**: Ary model.
- `calculate_differences.m` — **ary_model**: Ary model.
- `eccentricity_diff_fig_fn.m` — **function [mag_fig, rdm_fig] = eccentricity_diff_fig_fn( ...**: Function [mag fig, rdm fig] = eccentricity diff fig fn( ....
- `getElectrodePositions.m` — **getElectrodePositions**: Get Electrode Positions.
- `getMagnetometerPositions.m` — **getMagnetometerPositions**: Get Magnetometer Positions.
- `mag_fn.m` — **mag_fn**: Mag fn.
- `comparison_all_eccentricities.m` — **n_intervals = 15;**: N intervals = 15;.
- `comparison_high_eccentricity.m` — **n_intervals = 5;**: N intervals = 5;.
- `rdm_fn.m` — **rdm_fn**: Rdm fn.
- `zef_distance_to_mesh.m` — **zef_distance_to_mesh**: Zef distance to mesh.
- `zef_distance_to_resection.m` — **zef_distance_to_resection**: Zef distance to resection.
- `zef_lead_field_eeg_multilayer_sphere.m` — **zef_lead_field_eeg_multilayer_sphere**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.

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
- `Call `ary_model` from MATLAB with the project root on the path.`
- `Call `ary_model` from MATLAB with the project root on the path.`
- ``function [mag_fig, rdm_fig] = eccentricity_diff_fig_fn( ...(source_points, mags, rdms, legend_labels, …)` with project root and `src` on the path.`
- ``[[pos, label]] = getElectrodePositions(data, OptionalNameforElectrodeFile, OptionalNameForLabelFile, OptionalSaveToFile0or1)` with project root and `src` on the path.`
- ``[[posOri, magnetometerLabel, gradiometerLabel]] = getMagnetometerPositions(MEGdata, OptionalName, OptionalPlace, OptionalSave1or0)` with project root and `src` on the path.`
- ``[mag] = mag_fn(La, Lfem)` with project root and `src` on the path.`
- `Call `n_intervals = 15;` from MATLAB with the project root on the path.`
- `Call `n_intervals = 5;` from MATLAB with the project root on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.
Programmatic: populate mesh and sensors, then `zef_lead_field_matrix(zef, ...)` or modality-specific `zef_*_make_all`.

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
