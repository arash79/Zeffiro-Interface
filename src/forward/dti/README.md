# DTI → anisotropic conductivity (`src/forward/dti`)

## Folder purpose

Map FreeSurfer **FA / v1 / register.dat** volumes onto the FEM mesh as anisotropic conductivity tensors for `lead_field_type` **6–10**. Writes `zef.sigma_anisotropy` / folds into `zef.sigma(:,3:8)`. **Does not assemble `zef.L`.** UI: `tools/plugins/DTIConductivityTool`.

## Main contents

| File | Role |
|------|------|
| `zef_dti_apply_to_sigma.m` | Main Apply path |
| `zef_freesurfer_load_fa.m` | `fa.nii.gz` → `fa_data`, `fa_info` |
| `zef_freesurfer_load_v1.m` | `v1.nii.gz` [nx ny nz 3], unit-normalized |
| `zef_freesurfer_read_register_dat.m` | → `freesurfer_register_transform` (**required** by Apply) |
| `zef_freesurfer_read_volume_geometry.m` | `mri_info` → vox2ras / tkr / center |
| `zef_freesurfer_fa_to_conductivity.m` | FA→[nx ny nz 6] tensor (models 1–3) |
| `zef_dti_tensor_interpolate_mesh_space.m` | Tet centroids → SPD [M×6] |
| `zef_dti_get_mesh2voxel.m` | Mesh→FA-voxel 4×4 (also reused by Kalman structural Q / streamlines) |
| `zef_nii_conductivity_to_sigma.m` | Skip FA; isotropic NIfTI → diagonal σ columns |
| `zef_dti_streamlines.m` | Voxel-space streamline QA |
| `zef_visualize_nii_slices.m` | Slice visualization |
| `zef_dti_print_anisotropy_report.m` | Post-Apply FA/anisotropy stats |

**Kalman structural Q helpers are not here** — they live under `tools/plugins/Kalman/m/` (`zef_dti_structural_Q`, FA/tractography covariance) and reuse `zef_dti_get_mesh2voxel` + FA/`v1` fields. `inverse.KalmanInverter` does **not** call those helpers.

## Code functionality

Apply path (plugin button → `zef_dti_apply_to_sigma`):

1. Validate FA data, register transform, `nodes`/`tetra`.
2. Read model / interpolation / compartment tags from `zef.dti_*`.
3. `zef_freesurfer_fa_to_conductivity` (1 volume-fraction, 2 Tuch EMT, 3 direct scaling; low FA → isotropic).
4. Interpolate at tet centroids (`nearest` or `radius_average` / kdtree trilinear).
5. Mask by `dti_apply_to_compartments` (empty → all tets).
6. Write `zef.sigma_anisotropy` as `[σ11 σ22 σ33 σ12 σ13 σ23]`; later `zef_sigma` packs `sigma(:,3:8)`.

## Workflow context

```
DTI Conductivity Tool → Load FA/v1/register → Apply
  → this folder → anisotropic σ
  → recompute lead field types 6–10 (src/forward/lead_field)
Optional: same FA/v1 → Kalman plugin structural Q (separate pipeline)
```

## Usage instructions

```matlab
% GUI: Forward tools → DTI Conductivity Tool → Load → Apply to Mesh
% Then recompute anisotropic LF, e.g.:
zef.lead_field_type = 6;
zef = zef_eeg_lead_field_anisotropic(zef);
```

## Important notes

- Apply does **not** rebuild `zef.L`.
- Tensors must stay SPD or FEM stiffness can fail.
- Without `v1`, eigenframe defaults toward +x.
- `register.dat` is required for Apply.
- Streamline visualization is Mesh-visualization tool, not the Apply button.
- `roi_radius` may be an unused API leftover in some interpolate modes.

## Developer guidance

- Keep tensor math here; keep UI in DTIConductivityTool.
- Do not merge structural-Q and Apply-to-sigma without separate tests.
- Pitfall: applying DTI then comparing results with isotropic `lead_field_type` 1–5.
