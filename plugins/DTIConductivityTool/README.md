## Folder purpose

White-matter conductivity in a FEM head model is usually a single scalar per tissue. DTI measures a preferred diffusion direction; this plugin lets you load FreeSurfer `dt_recon` volumes and **Apply to Mesh** so each tetrahedron in selected compartments gets a 6-component σ tensor. Anisotropic EEG/MEG lead fields (types 6–10) then use `zef.sigma(:,3:8)`.

The interpolation and conversion math is in `src/forward/dti/` (`zef_dti_apply_to_sigma`). This folder is only the window and its callbacks.

## Main contents

| File | Role |
|------|------|
| `zef_dti_conductivity_open.m` | Menu start: create/show the window |
| `zef_dti_conductivity_window.m` | GUIDE/uicontrol layout (conversion ItemsData 1–3) |
| `zef_dti_conductivity_init.m` | Field defaults (`zef.dti_*`) |
| `zef_dti_conductivity_update.m` | Widget → `zef` sync |
| `zef_dti_conductivity_update_model.m` / `_conversion_model.m` / `_interpolation_model.m` / `_compartments.m` | Dropdown / list sync |
| `zef_dti_conductivity_browse_fa.m` / `_v1.m` / `_register.m` / `_ref.m` | File pickers for FA, v1, `register.dat`, reference MRI |
| `zef_dti_conductivity_load_freesurfer.m` | **Load**: read volumes into `zef.freesurfer_*` |
| `zef_dti_conductivity_clear.m` | Drop loaded volumes |
| `zef_dti_conductivity_apply_button_callback.m` | **Apply to Mesh** → `zef_dti_apply_to_sigma` |
| `zef_dti_empty_geometry_struct.m` | Empty geometry placeholder |
| Algorithm | `src/forward/dti/` (`zef_dti_apply_to_sigma` and loaders) |

## Code functionality

Need a FEM mesh first (Mesh tool **Create FEM mesh**).

Panel **FreeSurfer Input Files** (browse buttons + Load):

| File | Role |
|------|------|
| FA (`fa.nii.gz`) | Fractional anisotropy volume from `dt_recon` |
| v1 (`v1.nii.gz`) | Optional principal eigenvector |
| `register.dat` | FA voxel ↔ reference MRI; required by Apply |
| Reference MRI (`orig.mgz`) | Geometry for vox2ras / streamlines |

Coordinate matrices are read from those files; you do not type a 4×4 by hand. **Load** runs `zef_dti_conductivity_load_freesurfer`. **Clear** drops the loaded volumes.

Apply steps:

1. Choose conversion model. The dropdown `Items` / `ItemsData` in `zef_dti_conductivity_window` are:

| ItemsData | Label on the tool | What `zef_freesurfer_fa_to_conductivity` does |
|-----------|-------------------|-----------------------------------------------|
| 1 | Volume Fraction (Tuch et al.) | Mix extra-/intra-cellular σ, then σ_par = σ_iso(1+2 α), σ_perp = σ_iso(1−α) with α = Westin C_L(FA), not FA itself |
| 2 | Effective Medium Theory | Tuch linear map σ = 0.844 (d − 0.124) with d_par = MD(1+2 α), d_perp = MD(1−α), α = C_L |
| 3 | Direct Scaling | σ_par = scale(1+2 α), σ_perp = scale(1−α), α = C_L |

   Interpolation: **Nearest Neighbor** / **Trilinear** (stored id `'radius_average'`; 8-voxel `griddedInterpolant`, not a ball mean). The Radius spinner is unused.
2. Select compartments under **Apply to compartments**.
3. Click **Apply to Mesh** → `zef_dti_conductivity_apply_button_callback` → `zef_dti_apply_to_sigma`.
4. Recompute the lead field with an anisotropic `lead_field_type` (6–10). Apply does not rebuild `zef.L`.

Streamlines: Mesh visualization tool **Visualize DTI streamlines**, not this Apply button.

## Workflow context

**Forward tools → DTI Conductivity Tool** (default `multicompartment_head` profile). Callback: `zef_dti_conductivity_open`. Window title: **ZEFFIRO Interface: DTI Conductivity Tool**.

## Usage instructions

```matlab
zef.freesurfer_fa_data = zef_freesurfer_load_fa('fa.nii.gz');
zef.freesurfer_register_transform = zef_freesurfer_read_register_dat('register.dat');
zef = zef_dti_apply_to_sigma(zef);
```

1. Create FEM mesh; open Forward tools → DTI Conductivity Tool.
2. Load FA, register.dat, reference MRI (optional v1).
3. Choose conversion model and compartments; Apply to Mesh; recompute anisotropic lead field.

## Important notes

- Apply does not rebuild `zef.L`; use lead_field_type 6–10 afterward.
- `register.dat` is required for Apply.
- Streamline visualization is in Mesh visualization tool, not this window.

## Developer guidance

Preserve callback `zef_dti_conductivity_open` and conversion ItemsData 1–3. Keep algorithm documentation in `src/forward/dti/`; this plugin is UI-only.

FA/v1 volumes loaded here can also feed **Kalman plugin structural Q** (`zef_dti_structural_Q`) — that path does not call Apply-to-sigma. Do not merge the two pipelines without separate tests.
