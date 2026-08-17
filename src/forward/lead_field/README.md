# src/forward/lead_field

## Folder purpose

Assembles the sensor lead-field matrix **`zef.L`** (sources → sensors) for EEG, MEG, EIT, and TES, plus a parallel **gravity** path that does not use `lead_field_type`. Inverse solvers never call these FEM files directly; they consume `zef.L`. Mesh-tool wrappers for Create FEM mesh / source interpolation also live here for historical path reasons.

## Main contents

| Group | Files |
|-------|--------|
| Dispatch / run | `zef_lead_field_matrix`, `zef_run_forward_simulation` |
| Iso / aniso wrappers | `zef_*_lead_field_isotropic`, `*_anisotropic`, generics `zef_eeg_lead_field`, `zef_meg_*`, `zef_eit_lead_field`, `zef_tes_lead_field` |
| One-shot mesh+LF | `zef_eeg_make_all`, `zef_meg_*_make_all`, `zef_eit_make_all`, `zef_tes_make_all` |
| FEM cores | `zef_lead_field_eeg_fem`, `_meg_fem`, `_meg_grad_fem`, `_eit_fem`, `_tes_fem` |
| Post-LF / DOFs | `zef_source_interpolation`, `zef_lead_field_filter`, `zef_kron_reduction`, `zef_set_lead_field_zero_potential`, `zef_fi_dipoles`, `zef_ew_dipoles`, `zef_make_eit_dec`, `zef_make_multires_dec` |
| Gravity | `zef_lead_field_matrix_gravity`, `zef_lead_field_gravity`, `_gravity_grad`, profile wrappers `zef_gravity_*`, `zef_compute_gravity_data`, `zef_make_gravity_dec` |
| Mesh-tool wrappers | `zef_create_finite_element_mesh`, `zef_postprocess_finite_element_mesh`, `zef_apply_transform`, `zef_field_downsampling`, `zef_surface_downsampling` |

Interpolation matrix **G** construction: `zef_lead_field_interpolation` in parent `src/forward/`. EEG PCG transfer: `zef_transfer_matrix` in `src/gui/helpers/`.

## Code functionality

### `lead_field_type` (dispatcher `zef_lead_field_matrix`)

| Type | Modality | σ columns | FEM |
|------|----------|-----------|-----|
| 1 | EEG | `sigma(:,1)` | `zef_lead_field_eeg_fem` |
| 2 | MEG magnetometers | `sigma(:,1)` | `zef_lead_field_meg_fem` |
| 3 | MEG gradiometers | `sigma(:,1)` | `zef_lead_field_meg_grad_fem` |
| 4 | EIT | `sigma(:,1)` | `zef_lead_field_eit_fem` |
| 5 | TES / tES | `sigma(:,1)` | `zef_lead_field_tes_fem` |
| 6–10 | Anisotropic twins of 1–5 | `sigma(:,3:8)` | same FEM backends |

Unknown type → **no error**; `zef.L` left unchanged. Impedances for CEM (types 1,4,5,6,9,10) when `size(sensors,2)==6`.

**FEM sketch:** stiffness (`src/mesh/operators`) → `zef_build_electrodes` → `zef_transfer_matrix` (PCG) → `zef_lead_field_interpolation` → modality-specific Schur / Biot–Savart → optional `zef_source_interpolation`.

**Gravity:** `gravity_field_type` 1–4 → scalar/vector gravity or gradient FEM; density `zef.rho` — parallel to types 1–10.

## Workflow context

```
Mesh tool Create FEM mesh → zef_create_finite_element_mesh (wrapper here)
  → src/mesh create/postprocess
Forward table Run script → zef_run_forward_simulation → zef_lead_field_matrix
  → zef.L → Inverse plugins / +inverse
DTI Apply → anisotropic σ → types 6–10
Asteroid gravity profiles → gravity_* path (not EEG types)
```

## Usage instructions

```matlab
% Typical GUI: Mesh tool forward-simulation table → Run script
% Programmatic:
zef.lead_field_type = 1;
zef = zef_eeg_lead_field(zef);           % or zef_lead_field_matrix(zef)
% One-shot (mesh + LF + interpolation):
zef_eeg_make_all;
```

## Important notes

- Some files still declare historical internal names (`lead_field_*_fem`); call the `zef_*` public filenames.
- `zef_make_multires_dec` / EIT dec helpers feed inverse/RAMUS — they do not assemble `L`.
- PCG settings live in `zef.lf_param` / `zef.preconditioner*` via `zef_transfer_matrix`, not duplicated inside every FEM file.
- `pcg_iteration` under `src/forward/` serves NSE/wave — not the EEG transfer path.

## Developer guidance

- New modality: add FEM core + dispatcher case + iso/aniso wrappers + optional `*_make_all`; document type number here and in `utilities.leadfield.lf_tag_from_lf_type` if tagging.
- Keep mesh creation logic in `src/mesh`; only thin wrappers belong here.
- Pitfall: forgetting anisotropic `lead_field_type` after DTI Apply and comparing isotropic `L` to anisotropic σ.
