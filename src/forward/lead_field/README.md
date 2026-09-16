# src/forward/lead_field

## Folder purpose

Assembles the sensor lead-field matrix **`zef.L`** (sources → sensors) for EEG, MEG, EIT, and TES, plus a parallel **gravity** path that does not use `lead_field_type`. Inverse solvers never call these FEM files directly; they consume `zef.L`. Source interpolation (Whitney, H(div), St. Venant) lives here. EEG/TES electrode PCG is `zef_transfer_matrix`; MEG/EIT keep their own copies of those loops.

Mesh-tool **Create FEM mesh** wrappers live in `src/mesh` (`zef_create_finite_element_mesh`). Two Mesh-tool buttons that also touch `L` / interpolation remain here: **Resample field** and **Resample surfaces**.

## Main contents

### Dispatch and Mesh-tool scripts

| File | Role |
|------|------|
| `zef_lead_field_matrix.m` | Central dispatcher for `lead_field_type` 1–10. Scales mm→m, sets `lf_param`, calls FEM cores, optional `zef_source_interpolation`. |
| `zef_session_wants_gpu.m` | GPU gate from `zef.use_gpu` / `zef.gpu_count` on the argument (not `evalin('base')`) |
| `zef_require_meg_cartesian_interpolation.m` | Whitney / H(div) only for cartesian MEG; St. Venant would leave `L=0` |
| `zef_run_forward_simulation.m` | **Script.** Mesh-tool **Run script**: `eval`s column 3 of the selected forward-simulation table row (from `zeffiro_forward_simulation.ini`). |
| `zef_field_downsampling.m` | **Script.** Mesh-tool **Resample field**: random subset of source columns of `zef.L` when `n_sources` is smaller; caches `*_original_field`. |
| `zef_surface_downsampling.m` | **Script.** Mesh-tool **Resample surfaces**: `zef_downsample_surfaces` + `zef_process_meshes` + `zef_source_interpolation`. Distinct from the Create-FEM-mesh “Resample surf.” checkbox. |
| `zef_merge_lead_field.m` | **Script.** **Edit → Merge lead field with...**: vertical concat of an external `L` if column counts match. |

### Iso / aniso wrappers and one-shot mesh+LF

INI Script cells typically name these wrappers. `zef_eeg_lead_field`, `zef_eit_lead_field`, and `zef_tes_lead_field` are aliases of the isotropic wrappers.

| File | Role |
|------|------|
| `zef_*_lead_field_isotropic.m` / `*_anisotropic.m` | Set `lead_field_type`, call `zef_process_meshes` + `zef_attach_sensors_volume` + `zef_lead_field_matrix` + `zef_lead_field_filter`. |
| `zef_eeg_make_all.m`, `zef_eit_make_all.m`, `zef_tes_make_all.m` | One-shot: Create FEM mesh + attach sensors + lead field + interpolation. |

### FEM cores

| File | Modality |
|------|----------|
| `zef_lead_field_eeg_fem.m` | EEG (CEM/PEM) |
| `zef_lead_field_meg_fem.m` | MEG magnetometers |
| `zef_lead_field_meg_grad_fem.m` | MEG gradiometers |
| `zef_lead_field_eit_fem.m` | EIT |
| `zef_lead_field_tes_fem.m` | TES / tES |

**FEM sketch:** stiffness (`zef_stiffness_matrix`) → `zef_pem2cem` on CEM EEG/TES/EIT → electrode coupling (`zef_build_electrodes` for EEG/TES; EIT still inlines the same integrals with opposite `B` sign) → PCG for nodal potentials → interpolation `G` → modality map (EEG Schur, TES current-density gradient, MEG Biot–Savart, EIT conductivity Jacobian). PEM EIT is rejected with `zef_lead_field_eit_fem:PEMNotSupported` (the inherited PEM branch never built a right-hand side).

EEG and TES call `zef_transfer_matrix` for that PCG. MEG and EIT **inline the same loops** (GPU Jacobi `1./diag(A)`; CPU SSOR or `ichol` nofill). They do not call `zef_transfer_matrix`. CPU PCG `parfor` goes through `zef_ensure_parpool` so missing Parallel Computing Toolbox does not abort (loops then run sequentially). CEM electrode counts (`max` of column 1) are coerced to `double` so waitbar ETA `datevec` math does not inherit `uint32` face indices. EIT and TES pass `zef.n_sources` and `zef.dof_decomposition_type` into `zef_decompose_dof_space` so a session that is not in the base workspace still decomposes. Gravity does not use this electrode-transfer PCG. NSE/wave use `src/forward/solvers`.

### Interpolation, DOFs, and dipole stencils

| File | Role |
|------|------|
| `zef_source_interpolation.m` | Build interpolant from tetra DOFs onto `source_positions`. |
| `zef_lead_field_interpolation.m` | Interpolation matrix **G** construction. |
| `zef_whitney_interpolation.m` | Whitney (edge) interpolation; uses PBO/MPO. |
| `zef_hdiv_interpolation.m` | H(div) (face-interior) interpolation. |
| `zef_nearest_neighbour_groups.m` | Invert nearest-source labels for Whitney / H(div). |
| `zef_average_tes_dof_current.m` | Average TES current-density triplets per DOF. |
| `zef_fi_dipoles.m` | Face-interior dipole stencils for H(div). |
| `zef_fi_shared_faces.m` | Brain tet pairs that share exactly one face (`zef_fi_dipoles`). |
| `zef_st_venant_interpolation.m` | St. Venant interpolation. |
| `zef_pbo_system.m` | Position-based optimization weights for one source. |
| `zef_mpo_system.m` | Mean position/orientation weights for one source. |
| `zef_L2_norm.m` | Euclidean row (or whole-array) norm used by PBO/MPO/St. Venant. |
| `zef_ew_dipoles.m` | Edge-Whitney dipole stencils. |
| `zef_decompose_dof_space.m` | Map brain tets to a reduced source lattice (`dof_decomposition_type` 1–3). Missing `n_sources` / type fall back to `zef_init` defaults when the session is not in base. |
| `zef_lead_field_filter.m` | Drop columns whose column-norm exceeds a quantile (after every EEG/MEG/EIT/TES wrapper). |
| `zef_transfer_matrix.m` | EEG/TES electrode PCG. GPU Jacobi; CPU SSOR or `ichol` nofill. MEG/EIT do not call this file. CPU `parfor` uses `zef_ensure_parpool`. |

### Gravity (asteroid profiles)

Does **not** use `lead_field_type`. Density `zef.rho`. `gravity_field_type` 1–4 → scalar/vector gravity or gradient FEM.

| File | Role |
|------|------|
| `zef_lead_field_matrix_gravity.m` | Gravity dispatcher. |
| `zef_lead_field_gravity.m` / `_gravity_grad.m` | Gravity FEM cores. |
| `zef_gravity_lead_field_scalar.m` / `_vector.m` | Profile wrappers. |
| `zef_gravity_gradient_lead_field_scalar.m` / `_vector.m` | Gradient wrappers. |
| `zef_make_gravity_dec.m` | Gravity DOF decimation helper. |

### EIT synthetic data and inverse/RAMUS helpers

| File | Role |
|------|------|
| `zef_compute_eit_data.m` | Synthetic EIT voltages with ROI conductivity bumps. |
| `zef_synthetic_eit_data.m` | **Script.** Find synthetic EIT data → **Compute**. |
| `zef_make_eit_dec.m` | EIT decimation helper (feeds inverse, does not assemble `L`). |
| `zef_make_multires_dec.m` | Multiresolution decimation for RAMUS (does not assemble `L`). |

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

Unknown type → warning `zef_lead_field_matrix:UnknownType`; `zef.L` left unchanged. Impedances for CEM (types 1, 4, 5, 6, 9, 10) when `size(sensors,2)==6`.

Source model: `core.types.ZefSourceModel.from(zef.source_model)`. Direction mode 1/2/3 → cartesian/normal/face_based. CPU `preconditioner` 1/2 → ichol nofill / SSOR; GPU ignores it (Jacobi). `preconditioner_tolerance` is copied to `cholinc_tol` and not read. Coordinates: copies `nodes`/`sensors` to `*_aux` and divides millimetre **xyz** by 1000 before FEM. CEM EEG/EIT/TES instead pass `sensors_attached_volume` as a 4-column **index** table and do not scale it. Session `zef.sensors` stays `N×3` or `N×6`. Full layout: [docs/conventions.md](../../../docs/conventions.md).

EEG and TES pass **opposite** Schur-complement signs into `zef_transfer_matrix` (EEG: `B'*x - C`; TES: `C - B'*x`). Do not “unify” those handles without checking `L` and `S_tes`.

## Workflow context

```
Mesh tool Create FEM mesh → zef_create_finite_element_mesh (src/mesh)
  → src/mesh create/postprocess
Mesh tool Run script → zef_run_forward_simulation → INI Script cell
  → iso/aniso wrapper → zef_lead_field_matrix → zef.L
  → Inverse plugins / +inverse
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
- PCG residual is `zef.solver_tolerance` → `lf_param.pcg_tol`. The “preconditioner tolerance” widget does not affect the live `ichol`.
- MEG/EIT duplicate the transfer PCG in-file. Changing `zef_transfer_matrix` does not change those modalities until the copies are updated together.
- `pcg_iteration` under `src/forward/solvers` serves NSE/wave — not EEG/MEG/EIT/TES.
- `filter_quantile=1` (example default) removes nothing in `zef_lead_field_filter`.

## Developer guidance

- New modality: add FEM core + dispatcher case + iso/aniso wrappers + optional `*_make_all`; document the type number here.
- Keep mesh creation logic in `src/mesh`; only LF-touching Mesh-tool scripts belong here.
- Pitfall: forgetting anisotropic `lead_field_type` after DTI Apply and comparing isotropic `L` to anisotropic σ.
- Pitfall: calling `zef_lead_field_matrix` without `zef_attach_sensors_volume` — CEM/PEM coupling will be wrong.
- Pitfall: passing `zef.sensors` (`N×6`) into a FEM core. Four columns means CEM attachment indices; six columns is treated as PEM.
