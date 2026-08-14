# DTI Conductivity Tool

White-matter conductivity in a FEM head model is usually a single scalar per tissue. DTI measures a preferred diffusion direction; this plugin lets you load FreeSurfer `dt_recon` volumes and **Apply to Mesh** so each tetrahedron in selected compartments gets a 6-component σ tensor. Anisotropic EEG/MEG lead fields (types 6–10) then use `zef.sigma(:,3:8)`.

The interpolation and conversion math is in `src/forward/dti/` (`zef_dti_apply_to_sigma`). This folder is only the window and its callbacks.

## How to open it

**Forward tools → DTI Conductivity Tool** (default `multicompartment_head` profile). Callback: `zef_dti_conductivity_open`. Window title: **ZEFFIRO Interface: DTI Conductivity Tool**.

You need a FEM mesh first (Mesh tool **Create FEM mesh**).

## What to load

Panel **FreeSurfer Input Files** (browse buttons + Load):

| File | Role |
|------|------|
| FA (`fa.nii.gz`) | Fractional anisotropy volume from `dt_recon` |
| v1 (`v1.nii.gz`) | Optional principal eigenvector |
| `register.dat` | FA voxel ↔ reference MRI; required by Apply |
| Reference MRI (`orig.mgz`) | Geometry for vox2ras / streamlines |

Coordinate matrices are read from those files; you do not type a 4×4 by hand. **Load** runs `zef_dti_conductivity_load_freesurfer`. **Clear** drops the loaded volumes.

## Apply

1. Choose conversion model. The dropdown `Items` / `ItemsData` in `zef_dti_conductivity_window` are:

| ItemsData | Label on the tool | What `zef_freesurfer_fa_to_conductivity` does |
|-----------|-------------------|-----------------------------------------------|
| 1 | Volume Fraction (Tuch et al.) | Mix extra-/intra-cellular σ, then σ_par = σ_iso(1+2 FA), σ_perp = σ_iso(1−FA) |
| 2 | Effective Medium Theory | Tuch linear map σ = 0.844 (d − 0.124) with d_par = MD(1+2 FA) |
| 3 | Direct Scaling | σ_par = scale(1+2 FA), σ_perp = scale(1−FA) |

   Interpolation: **Nearest Neighbor** / **Radius Average** (`'nearest'` / `'radius_average'`). Fields map to `zef.dti_*` (see `help zef_dti_apply_to_sigma`).
2. Select compartments under **Apply to compartments**.
3. Click **Apply to Mesh** → `zef_dti_conductivity_apply_button_callback` → `zef_dti_apply_to_sigma`.
4. Recompute the lead field with an anisotropic `lead_field_type` (6–10). Apply does not rebuild `zef.L`.

Streamlines: Mesh visualization tool **Visualize DTI streamlines**, not this Apply button.

## Scripting without the window

```matlab
zef.freesurfer_fa_data = zef_freesurfer_load_fa('fa.nii.gz');
zef.freesurfer_register_transform = zef_freesurfer_read_register_dat('register.dat');
zef = zef_dti_apply_to_sigma(zef);
```

## Files here

Start `zef_dti_conductivity_open.m`, window `zef_dti_conductivity_window.m`, browse/load/clear/update/apply callbacks, `zef_dti_empty_geometry_struct.m`. Algorithm: `src/forward/dti/README.md`.
