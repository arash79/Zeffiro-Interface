# tools/plugins/Kalman/Scripts

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `ROIMedianCurves.m` — **ROI_radius = 10;     %radius of the spherical region of interest, initial 2 cm diameter**: ROI radius = 10;     %radius of the spherical region of interest, initial 2 cm diameter.
- `test_dti_structural_covariance.m` — **fa.nii**: Fa.nii.
- `plot_quantiles.m` — **figures';**: Figures';.
- `plot_butterfly.m` — **full_address = 'exportImage';**: Full address = 'export Image';.
- `plot_parcellation.m` — **full_address = 'exportImage';**: Full address = 'export Image';.
- `plot_sources.m` — **full_address = 'exportImage';**: Full address = 'export Image';.
- `plot_cortex_component.m` — **loop_indx = 1;**: Loop indx = 1;.
- `plot_deep_component.m` — **loop_indx = 1;**: Loop indx = 1;.
- `get_rec_from_project.m` — **z_inverse_results = cell(0);**: Z inverse results = cell(0);.
- `mean_rec.m` — **z_inverse_results = cell(0);**: Z inverse results = cell(0);.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **fa.nii**: GUI callback or dialog (`fa.nii`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `ROI_radius = 10;     %radius of the spherical region of interest, initial 2 cm diameter` from MATLAB with the project root on the path.`
- `Call `fa.nii` from MATLAB with the project root on the path.`
- `Call `figures';` from MATLAB with the project root on the path.`
- `Call `full_address = 'exportImage';` from MATLAB with the project root on the path.`
- `Call `full_address = 'exportImage';` from MATLAB with the project root on the path.`
- `Call `full_address = 'exportImage';` from MATLAB with the project root on the path.`
- `Call `loop_indx = 1;` from MATLAB with the project root on the path.`
- `Call `loop_indx = 1;` from MATLAB with the project root on the path.`

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
