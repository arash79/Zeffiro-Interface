# DTI conductivity (`src/forward/dti`)

White-matter conductivity is anisotropic: current prefers to flow along axons. Diffusion tensor imaging (DTI) measures that preferred direction as a fractional anisotropy (FA) volume and a principal eigenvector (`v1`). This folder turns those FreeSurfer/`dt_recon` volumes into the 6-component conductivity tensor that EEG/MEG lead fields of type **6–10** read from `zef.sigma(:,3:8)`.

It does **not** assemble a lead field. After you Apply, re-run Mesh tool **Run script** (or `zef_eeg_make_all` with an anisotropic type) so `zef.L` uses the new σ.

## Where this sits

```
FreeSurfer dt_recon  (fa.nii.gz, v1, register.dat, orig.mgz)
        │
        ▼
Forward tools → DTI Conductivity Tool     tools/plugins/DTIConductivityTool
        │                                 (browse / load / Apply)
        ▼
zef_dti_apply_to_sigma                    this folder
        │
        ▼
zef.sigma_anisotropy  (n_tet × 6)         [σ11 σ22 σ33 σ12 σ13 σ23]
zef.sigma(:,3:8)                          concatenated by zef_sigma
        │
        ▼
lead_field_type 6–10                      src/forward/lead_field
```

Isotropic types 1–5 ignore columns 3–8. Streamline visualization is separate: Mesh visualization tool **Visualize DTI streamlines** → `zef_visualize_dti_streamlines` (uses FA/`v1` in voxel space, not the FEM tensor).

## GUI

Menu **Forward tools → DTI Conductivity Tool** (`zef_dti_conductivity_open` in the default `multicompartment_head` profile). Typical use:

1. Build a FEM mesh (Mesh tool **Create FEM mesh**).
2. In the DTI tool: Browse FA (`fa.nii.gz`), optional `v1`, `register.dat`, and a reference MRI (`orig.mgz`). Load.
3. Choose conversion model (dropdown **Volume Fraction (Tuch et al.)** = 1, **Effective Medium Theory** = 2, **Direct Scaling** = 3), interpolation (**Nearest Neighbor** / **Radius Average**), and which compartments to apply to.
4. **Apply** → `zef_dti_conductivity_apply_button_callback` → `zef_dti_apply_to_sigma`.
5. Recompute the lead field with an anisotropic type.

## Scripting

```matlab
zef.freesurfer_fa_data = zef_freesurfer_load_fa('path/to/fa.nii.gz');
zef.freesurfer_register_transform = zef_freesurfer_read_register_dat('path/to/register.dat');
% optional: v1, reference geometry
zef = zef_dti_apply_to_sigma(zef, ...
    'dti_conductivity_model', 1, ...
    'dti_interpolation_mode', 'radius_average', ...
    'dti_interpolation_radius', 2);
```

`zef_dti_apply_to_sigma` errors if FA, `register.dat`, or `zef.tetra` is missing.

## Conversion models (from the implementation)

`dti_conductivity_model`:

| Value | GUI label | Meaning |
|-------|-----------|---------|
| 1 | Volume Fraction (Tuch et al.) | Mix extra-/intra-cellular conductivities with `dti_volume_fraction` (default 0.7), then FA-scale parallel/perpendicular (Tuch-style eigenvectors). |
| 2 | Effective Medium Theory | Tuch linear map σ = 0.844 (d − 0.124) S/m with `dti_mean_diffusivity` (default 0.7 μm²/ms). |
| 3 | Direct Scaling | Scale the FA-shaped tensor by `dti_conductivity_scale` (default 0.33 S/m isotropic fallback). |

FA below `dti_anisotropy_threshold` (default 0.2) is treated as isotropic. Interpolation: `'radius_average'` (default, radius in mm) or `'nearest'`. Voxel↔mesh mapping is `zef_dti_get_mesh2voxel` / `zef_dti_tensor_interpolate_mesh_space`.

Units: FA is dimensionless; conductivity Siemens/metre; mesh coordinates typically millimetres. The interpolation radius is millimetres.

## Files

| File | Role |
|------|------|
| `zef_dti_apply_to_sigma.m` | FA (+ optional v1) → `zef.sigma_anisotropy` |
| `zef_dti_tensor_interpolate_mesh_space.m` | Voxel tensor → tetra centroids |
| `zef_dti_get_mesh2voxel.m` | Affine mesh → FA voxel indices |
| `zef_freesurfer_load_fa.m` / `zef_freesurfer_load_v1.m` | NIfTI readers |
| `zef_freesurfer_read_register_dat.m` | FreeSurfer `register.dat` 4×4 |
| `zef_freesurfer_read_volume_geometry.m` | `orig.mgz` geometry |
| `zef_freesurfer_fa_to_conductivity.m` | FA (+ direction) → 3×3 σ at a voxel |
| `zef_nii_conductivity_to_sigma.m` | Already-converted NIfTI conductivity volume |
| `zef_dti_streamlines.m` | Integrate tracts from FA/`v1` (visualization) |
| `zef_dti_print_anisotropy_report.m` | Text summary of applied tensors |
| `zef_visualize_nii_slices.m` | Slice viewer for a NIfTI volume |

Plugin UI (browse buttons, Apply): `tools/plugins/DTIConductivityTool/`. Do not confuse that folder with this one; the PDE/interpolation lives here.

## See also

- Anisotropic lead fields: `src/forward/lead_field/README.md` (types 6–10)
- Plugin window: `tools/plugins/DTIConductivityTool/README.md`
- Kalman DTI process-noise Q is **legacy `zef_KF` only**, not this Apply path
