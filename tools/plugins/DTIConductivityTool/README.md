# tools/plugins/DTIConductivityTool

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_dti_conductivity_browse_fa.m` — **function zef_dti_conductivity_browse_fa**: Function zef dti conductivity browse fa.
- `zef_dti_conductivity_browse_ref.m` — **function zef_dti_conductivity_browse_ref**: Function zef dti conductivity browse ref.
- `zef_dti_conductivity_browse_register.m` — **function zef_dti_conductivity_browse_register**: Function zef dti conductivity browse register.
- `zef_dti_conductivity_browse_v1.m` — **function zef_dti_conductivity_browse_v1**: Function zef dti conductivity browse v1.
- `zef_dti_conductivity_clear.m` — **function zef_dti_conductivity_clear**: Function zef dti conductivity clear.
- `zef_dti_conductivity_init.m` — **function zef_dti_conductivity_init**: Function zef dti conductivity init.
- `zef_dti_conductivity_update_compartments.m` — **function zef_dti_conductivity_update_compartments**: Function zef dti conductivity update compartments.
- `zef_dti_conductivity_update_model.m` — **function zef_dti_conductivity_update_model**: Function zef dti conductivity update model.
- `zef_dti_conductivity_apply_button_callback.m` — **zef_dti_conductivity_apply_button_callback**: GUI callback for dti_conductivity_apply_button actions.
- `zef_dti_conductivity_load_freesurfer.m` — **zef_dti_conductivity_load_freesurfer**: Zef dti conductivity load freesurfer.
- `zef_dti_conductivity_open.m` — **zef_dti_conductivity_open**: Zef dti conductivity open.
- `zef_dti_conductivity_update.m` — **zef_dti_conductivity_update**: Zef dti conductivity update.
- `zef_dti_conductivity_update_conversion_model.m` — **zef_dti_conductivity_update_conversion_model**: Zef dti conductivity update conversion model.
- `zef_dti_conductivity_update_interpolation_model.m` — **zef_dti_conductivity_update_interpolation_model**: Zef dti conductivity update interpolation model.
- `zef_dti_conductivity_window.m` — **zef_dti_conductivity_window**: Zef dti conductivity window.
- `zef_dti_empty_geometry_struct.m` — **zef_dti_empty_geometry_struct**: Zef dti empty geometry struct.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_dti_conductivity_apply_button_callback**: GUI callback or dialog (`zef_dti_conductivity_apply_button_callback`).
- **function zef_dti_conductivity_browse_fa**: GUI callback or dialog (`function zef_dti_conductivity_browse_fa`).
- **function zef_dti_conductivity_browse_ref**: GUI callback or dialog (`function zef_dti_conductivity_browse_ref`).
- **function zef_dti_conductivity_browse_register**: GUI callback or dialog (`function zef_dti_conductivity_browse_register`).
- **function zef_dti_conductivity_browse_v1**: GUI callback or dialog (`function zef_dti_conductivity_browse_v1`).
- **zef_dti_conductivity_window**: GUI callback or dialog (`zef_dti_conductivity_window`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `function zef_dti_conductivity_browse_fa` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_browse_ref` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_browse_register` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_browse_v1` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_clear` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_init` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_update_compartments` from MATLAB with the project root on the path.`
- `Call `function zef_dti_conductivity_update_model` from MATLAB with the project root on the path.`

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
