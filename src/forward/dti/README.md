# src/forward/dti

## Purpose of this folder

Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.

## Contents

MATLAB sources:
- `zef_dti_tensor_interpolate_mesh_space.m` — **tensor_array**: Tensor array.
- `zef_dti_apply_to_sigma.m` — **zef_dti_apply_to_sigma**: Zef dti apply to sigma.
- `zef_dti_get_mesh2voxel.m` — **zef_dti_get_mesh2voxel**: Zef dti get mesh2voxel.
- `zef_dti_print_anisotropy_report.m` — **zef_dti_print_anisotropy_report**: Zef dti print anisotropy report.
- `zef_dti_streamlines.m` — **zef_dti_streamlines**: Zef dti streamlines.
- `zef_freesurfer_fa_to_conductivity.m` — **zef_freesurfer_fa_to_conductivity**: Zef freesurfer fa to conductivity.
- `zef_freesurfer_load_fa.m` — **zef_freesurfer_load_fa**: Zef freesurfer load fa.
- `zef_freesurfer_load_v1.m` — **zef_freesurfer_load_v1**: Zef freesurfer load v1.
- `zef_freesurfer_read_register_dat.m` — **zef_freesurfer_read_register_dat**: Zef freesurfer read register dat.
- `zef_freesurfer_read_volume_geometry.m` — **zef_freesurfer_read_volume_geometry**: Zef freesurfer read volume geometry.
- `zef_nii_conductivity_to_sigma.m` — **zef_nii_conductivity_to_sigma**: Zef nii conductivity to sigma.
- `zef_visualize_nii_slices.m` — **zef_visualize_nii_slices**: Renders or updates a visualize_nii_slices figure from current `zef` state.

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
- `Call `tensor_array` from MATLAB with the project root on the path.`
- ``[zef] = zef_dti_apply_to_sigma(zef, varargin)` with project root and `src` on the path.`
- ``[[T_mesh2voxel, info]] = zef_dti_get_mesh2voxel(zef)` with project root and `src` on the path.`
- ``zef_dti_print_anisotropy_report(zef, opts)` with project root and `src` on the path.`
- ``[dti_streamlines] = zef_dti_streamlines(dti_directions, dti_anisotropy, seed_point, roi_radius, …)` with project root and `src` on the path.`
- ``[conductivity_tensor] = zef_freesurfer_fa_to_conductivity(fa_data, model_type, varargin)` with project root and `src` on the path.`
- ``[[fa_data, fa_info]] = zef_freesurfer_load_fa(fa_file)` with project root and `src` on the path.`
- ``[[v1_data, v1_info]] = zef_freesurfer_load_v1(v1_file)` with project root and `src` on the path.`

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
