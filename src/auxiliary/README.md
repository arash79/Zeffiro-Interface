# Auxiliary scripts (`src/auxiliary`)

One-off analysis, sphere-model lead fields, MRI affine helpers, and mesh-distance utilities that are **not** on the main Zeffiro menus. Nothing here is opened by `zef_start`. Use them from the MATLAB prompt or from study scripts under `+examples`.

## Lead-field and error metrics (root of this folder)

| File | Kind | Role |
|------|------|------|
| `zef_lead_field_eeg_multilayer_sphere.m` | function | Analytic EEG lead field for a Berg–Scherg multilayer sphere (`sphere_model.lambda_berg`, `mu_berg`, `sigma`). Empty `source_directions` expands to 3 Cartesian dipoles per position. |
| `rdm_fn.m` | function | Relative difference measure: column-normalize `La` and `Lfem`, then RMS of the difference (one value per column). |
| `mag_fn.m` | function | MAG (magnitude) error between analytic and FEM lead-field columns. |
| `calc_diffs.m` | **script** plus local functions | Builds MAG/RDM vs eccentricity figures; local copies of `mag_fn`/`rdm_fn`. |
| `calculate_differences.m` | similar study driver | Same family. |
| `eccentricity_diff_fig_fn.m` | function | `[mag_fig, rdm_fig] = …(source_points, mags, rdms, legend_labels, …)` |
| `comparison_all_eccentricities.m` / `comparison_high_eccentricity.m` | **scripts** | Fixed `n_intervals` (15 / 5); not a GUI entry. |

## Distances

| File | Role |
|------|------|
| `zef_distance_to_mesh.m` | Distance from points `p` to a triangle mesh `(nodes, triangles)` |
| `zef_distance_to_resection.m` | Distance from points to a resection surface |
| `mesh_averaging/zef_find_distance_to_mesh.m` | **script** wrapper around the same idea |
| `mesh_averaging/zef_distance_to_mesh.m` | Duplicate of the root function |

## Mesh averaging / source-space split

| File | Role |
|------|------|
| `mesh_averaging/zef_average_lead_field.m` | **script** — average `L` over a decomposition |
| `mesh_averaging/zef_decompose_soure_space.m` | Split source positions into `source_count` groups (filename spelling `soure`) |
| `mesh_averaging/zef_get_surface_triangles.m` | Faces of one `domain_labels` compartment |
| `mesh_averaging/zef_plot_surface_triangles.m` | **script** — plot those faces |

## Sensors from vendor structs

`getElectrodePositions.m` / `getMagnetometerPositions.m` — pull EEG/MEG coordinates (and optional labels) out of a data struct and optionally write DAT files. Not wired to **Import → Import electrodes**.

## MRI

`mri/myAffine3d.m` — apply a 4×4 affine to points. `mri/scriptForAlignment.m` — **script** for a one-off alignment. See `mri/README.md`.

## Analysis scripts (`analysisScripts/`)

GMM / SNR / reconstruction batch helpers used by older papers (`makeGMM`, `snrTest`, `zef_insideGMM`, `zef_GMM_resection_volume`, …). They are **scripts or functions with local `zef` assumptions**, not session API. See that folder’s README.

## Plotting

`plotting/zef_get_reconstruction_field.m` is an unfinished leftover (undeclared `type`, unused `intersect_ind`). Not a supported API. Live volume drawing is `src/gui/plot/zef_plot_volume.m`. See `plotting/README.md`.

## Scripting

```matlab
rdm = rdm_fn(L_analytic, zef.L);
Lsph = zef_lead_field_eeg_multilayer_sphere(electrodes, src_pos, [], sphere_model);
```

These do not call `zef_update`. Sphere geometry is independent of the FEM mesh.

## Developer notes

- Prefer `src/forward/lead_field` for production EEG/MEG; the multilayer sphere is a comparison / test field.
- Duplicated `zef_distance_to_mesh` / `zef_distance_to_resection` exist under `analysisScripts/` and `mesh_averaging/` — same names, keep behaviour in sync if you edit one.
