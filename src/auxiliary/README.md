## Folder purpose

One-off analysis, sphere-model lead fields, MRI affine helpers, and mesh-distance utilities that are **not** on the main Zeffiro menus. Nothing here is opened by `zef_start`. Use from the MATLAB prompt or from study scripts under `+examples`.

## Main contents

| Area | Files |
|------|--------|
| Lead-field / error metrics | `zef_lead_field_eeg_multilayer_sphere.m`, `rdm_fn.m`, `mag_fn.m`, `calc_diffs.m`, `calculate_differences.m`, `eccentricity_diff_fig_fn.m`, `comparison_all_eccentricities.m`, `comparison_high_eccentricity.m` |
| Distances | `zef_distance_to_mesh.m`, `zef_distance_to_resection.m`; duplicates under `mesh_averaging/` |
| Mesh averaging | `zef_average_lead_field.m`, `zef_decompose_soure_space.m` (filename spelling `soure`), surface triangle helpers |
| Vendor sensors | `getElectrodePositions.m`, `getMagnetometerPositions.m` (not Import electrodes) |
| MRI | `mri/myAffine3d.m`, `mri/scriptForAlignment.m` |
| Analysis | `analysisScripts/` — GMM / SNR / reconstruction batch helpers |
| Plotting | `plotting/zef_get_reconstruction_field.m` — unfinished leftover; live drawing is `src/gui/plot` |

## Code functionality

`zef_lead_field_eeg_multilayer_sphere` — analytic EEG lead field for a Berg–Scherg multilayer sphere (`sphere_model.lambda_berg`, `mu_berg`, `sigma`). Empty `source_directions` expands to 3 Cartesian dipoles per position.

`rdm_fn` — column-normalize `La` and `Lfem`, then RMS of the difference per column. `mag_fn` — MAG error between analytic and FEM columns. Comparison scripts build MAG/RDM vs eccentricity figures (fixed interval counts).

Distance helpers measure points to a triangle mesh or resection surface. Mesh-averaging scripts average `L` over a decomposition and split source positions into groups.

## Workflow context

Not session API. Analysis scripts under `analysisScripts/` assume local `zef` conventions from older papers. See child READMEs in `mri/`, `plotting/`, `analysisScripts/`, `mesh_averaging/`.

## Usage instructions

```matlab
rdm = rdm_fn(L_analytic, zef.L);
Lsph = zef_lead_field_eeg_multilayer_sphere(electrodes, src_pos, [], sphere_model);
```

These do not call `zef_update`. Sphere geometry is independent of the FEM mesh.

## Important notes

- Prefer `src/forward/lead_field` for production EEG/MEG; the multilayer sphere is a comparison / test field.
- Duplicated `zef_distance_to_mesh` / `zef_distance_to_resection` exist under `analysisScripts/` and `mesh_averaging/`.

## Developer guidance

Keep duplicated distance helpers in sync if you edit one. Do not treat `plotting/zef_get_reconstruction_field.m` as a supported API.
