# tools/plugins/LFBankTool/m/lead_field_normalization_functions

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_lead_field_no_normalization.m` — **zef_lead_field_no_normalization**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_lead_field_normalize_frobenius.m` — **zef_lead_field_normalize_frobenius**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_lead_field_normalize_maximum_data.m` — **zef_lead_field_normalize_maximum_data**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_lead_field_normalize_mean_data.m` — **zef_lead_field_normalize_mean_data**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_lead_field_scaling.m` — **zef_lead_field_scaling**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_lead_field_whitening.m` — **zef_lead_field_whitening**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_lead_field_whitening_diagonal_identity.m` — **zef_lead_field_whitening_diagonal_identity**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

Open the corresponding tool or plugin from the Zeffiro menu bar (profile-dependent). Widget callbacks in this folder update `zef` and call `zef_update`.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[[L, measurements]] = zef_lead_field_no_normalization(lf_bank_index)` with project root and `src` on the path.`
- ``[[L, measurements]] = zef_lead_field_normalize_frobenius(lf_bank_index)` with project root and `src` on the path.`
- ``[[L, measurements]] = zef_lead_field_normalize_maximum_data(lf_bank_index)` with project root and `src` on the path.`
- ``[[L, measurements]] = zef_lead_field_normalize_mean_data(lf_bank_index)` with project root and `src` on the path.`
- ``[[L, measurements]] = zef_lead_field_scaling(lf_bank_index)` with project root and `src` on the path.`
- ``[[L, measurements]] = zef_lead_field_whitening(lf_bank_index)` with project root and `src` on the path.`
- ``[[L, measurements]] = zef_lead_field_whitening_diagonal_identity(lf_bank_index)` with project root and `src` on the path.`

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
