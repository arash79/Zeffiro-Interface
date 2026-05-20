# src/forward

## Folder purpose

**Forward modeling** for Zeffiro Interface: assemble sensor lead-field matrices (`zef.L`), optional DTI-driven anisotropic conductivity, Navier–Stokes hemodynamic simulation (NSE), and GPU-Torre wave physics. Root-level `pcg_iteration.m` serves NSE/wave solvers; EEG lead fields use `zef_transfer_matrix` (in `src/gui/helpers`) instead.

## Main contents

### Root
| File | Role |
|------|------|
| `pcg_iteration.m` / `pcg_iteration_gpu.m` | Custom preconditioned CG for NSE and wave pipelines |
| `zef_lead_field_interpolation.m` | Dispatch `core.types.ZefSourceModel` → Whitney / H(div) / St. Venant **G** matrix |

### `lead_field/` (~50 files)
| Entry | Role |
|-------|------|
| `zef_*_make_all` | One-shot: mesh → postprocess → modality LF → source interpolation |
| `zef_lead_field_matrix` | Central dispatcher on `zef.lead_field_type` (1–10) → `lead_field_*_fem` |
| `lead_field_eeg_fem.m` | Stiffness → electrodes → PCG transfer → Schur → **L** |
| `lead_field_meg_fem.m` / `lead_field_meg_grad_fem.m` | MEG B-field / gradiometer FEM paths |
| `lead_field_eit_fem.m` / `lead_field_tes_fem.m` | EIT / TES with electrode patterns |
| `zef_source_interpolation` | Map **L** columns to cortical nodes; fill `source_interpolation_ind` |
| `zef_lead_field_filter` | Column quantile filter on **L** |
| `zef_kron_reduction`, `zef_make_multires_dec` | Multiresolution index structures |

### `dti/` (12 files)
FreeSurfer/NIfTI → `zef.sigma` anisotropic columns: `zef_freesurfer_fa_to_conductivity`, `zef_dti_tensor_interpolate_mesh_space`, `zef_dti_apply_to_sigma`, `zef_nii_conductivity_to_sigma`.

### `nse/` (16 files)
Hemodynamic forward on `zef.nse_field`: `zef_nse_run_solver`, `zef_nse_poisson`, `zef_nse_iteration`, barycentric operator assembly via `zef_nse_matrices`.

### `wave/` (~30 files)
GPU-Torre acoustic/EM leap-frog: `create_system.m`, `compute_data_gpu.m`, Born approximation and Jacobian utilities. **Does not** populate `zef.L`.

## Code functionality

**EEG lead-field pipeline:**
```
zef_stiffness_matrix → zef_build_electrodes → zef_transfer_matrix (PCG per electrode)
  → zef_lead_field_interpolation (G) → L = Schur \ (T' * G), mean-zero rows
```

**`zef.lead_field_type`:** 1–5 isotropic EEG/MEG/EIT/TES; 6–10 same modalities with anisotropic `zef.sigma(:,3:8)` from DTI.

**Source model:** `zef_lead_field_matrix` and interpolation call `core.types.ZefSourceModel.from(zef.source_model)` to branch Whitney vs H(div) vs St. Venant.

**Downstream:** `zef.L` + `zef.source_interpolation_ind` → `src/inverse/zef_processLeadfields` → inversion.

## Workflow context

| Stage | Caller |
|-------|--------|
| Mesh tool forward table | `zef_run_forward_simulation` → `eval` of profile script (often `zef_eeg_make_all`) |
| Menu / mesh tool buttons | `zef_create_finite_element_mesh` chain inside `make_all` scripts |
| DTI tool plugin | `tools/plugins/DTIConductivityTool` → `zef_dti_*` → updated `zef.sigma` |
| NSE plugin | `tools/plugins/NSE_tool` → `zef_nse_*` |
| Inverse | Reads `zef.L` only (not NSE/wave outputs) |

## Usage instructions

```matlab
% After mesh and sensors exist
zef.source_model = core.types.ZefSourceModel.Whitney;
zef = zef_lead_field_matrix(zef);
zef = zef_source_interpolation(zef);

% Or full pipeline from profile forward_simulation.ini entry
zef = zef_eeg_make_all(zef);

% Anisotropic (requires DTI sigma)
zef = zef_eeg_lead_field_anisotropic(zef);
```

GUI: **Mesh tool** → forward simulation table → run row defined in `profile/<profile>/zeffiro_forward_simulation.ini`.

## Important notes

- **`zef.L` is required before any inverse** — run source interpolation after lead field.
- Lead-field PCG uses `ichol`/`ssor` in `zef_transfer_matrix`; `+core/+linalg/+preconditioners` is not wired in yet.
- NSE and wave outputs are **parallel forward models** — they do not replace `zef.L` for standard EEG/MEG inverse.
- Gravity lead fields (`zef_gravity_*`) bypass `zef_lead_field_matrix` in some paths.

## Developer guidance

- New modality: add `lead_field_*_fem.m`, extend `zef_lead_field_matrix` switch, add `zef_*_make_all`, register in `zeffiro_forward_simulation.ini`.
- Source model changes: update `zef_lead_field_interpolation.m` and `core.types.ZefSourceModel` together.
- DTI conductivity must yield positive-definite tensors per tetra or `lead_field_eeg_fem` errors.
- Prefer `zef_*_make_all` for GUI table entries so mesh postprocess is never skipped.
