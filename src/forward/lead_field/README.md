# Sensor lead fields (`src/forward/lead_field`)

This folder assembles the sensor lead-field matrix **`zef.L`** for EEG, MEG, EIT, TES (tES), and gravity. Parent [`src/forward/README.md`](../README.md) explains what a lead field is, why you compute one, Mesh-tool **Run script**, and types 1–10. This page is the FEM and interpolation detail.

If you are new to Zeffiro: you already have a tetrahedral head (or asteroid) mesh and sensors. Code here answers “what does each sensor see from each source?” Inverse methods then invert that map. They never call these FEM files directly; they read `zef.L`.

## How EEG (and friends) actually compute `L`

The central dispatcher is `zef_lead_field_matrix`. Wrappers such as `zef_eeg_lead_field_isotropic` only set `zef.lead_field_type` / `zef.imaging_method`, re-process surfaces, attach sensors, call the dispatcher, quantile-filter columns, and optionally interpolate.

For EEG (types 1 and 6) `zef_lead_field_eeg_fem` does:

1. **Volumes** — `zef_tetra_volume` on tetrahedra (optional prisms in the cell `{tetra, prisms}`).
2. **Stiffness** — `zef_stiffness_matrix(nodes, tetrahedra, volumes, sigma)`. Isotropic `sigma` is expanded to a 6-row tensor (diagonal copies, zero shear). Anisotropic input is already `[σ11; σ22; σ33; σ12; σ13; σ23]` per tetrahedron.
3. **Electrodes** — `zef_build_electrodes`. Four-column electrode arrays are CEM (complete electrode model) with optional `lf_param.impedances`; three-column arrays are PEM (point electrodes snapped to nearest nodes).
4. **Transfer matrix `T`** — `zef_transfer_matrix` solves a PCG system once per electrode. Preconditioner is `zef.lf_param.precond`: `'cholinc'` if `zef.preconditioner == 1`, `'ssor'` if `2`. Tolerances: `zef.preconditioner_tolerance` → `cholinc_tol` (default `0.001`), `zef.solver_tolerance` → `pcg_tol` (default `1e-8`). This is **not** `pcg_iteration.m` in the parent folder.
5. **Interpolation `G`** — `zef_lead_field_interpolation` (parent folder) maps source tetrahedra to nodal columns using `core.types.ZefSourceModel` (Whitney, H(div), St. Venant). Optimization system type is `zef.optimization_system_type`, default `'pbo'` (`'mpo'` and `'none'` also exist).
6. **Schur + mean-zero** — `L = Schur_complement \ (T' * G)`, then each column has its mean subtracted so the potential reference is the average over electrodes (`L = L - mean(L,1)`). `zef_set_lead_field_zero_potential` is the equivalent matrix form `R = I - 11'/n` and is available but the EEG FEM uses the mean subtraction in place.

TES (types 5 and 10) additionally builds the tetrahedral gradient field with `zef_tetra_gradient_field` and returns a stimulation matrix `zef.S`. EIT (types 4 and 9) assembles the same stiffness/CEM system, then a conductivity Jacobian: for each brain tetrahedron it uses the unweighted ∇ψ·∇ψ products stored in `D_A` and the nodal potentials to accumulate `-R Φ G_local Φ' I` into source bins (`zef.eit_ind` / `zef.eit_count` from `zef_decompose_dof_space`, reused when `zef.redo_eit_dec` is 0). Background electrode data is `zef.inv_bg_data`. Infinite CEM impedance is rejected for EIT. MEG uses Biot–Savart load vectors `B` instead of the electrode Schur path; sensor orientation is `zef.sensors(:,4:6)` (and `(:,7:9)` for a second gradiometer coil). Primary dipole field plus secondary (PCG) field are scaled by \(1/(4\pi)\) and mean-zeroed across coils.

### Source tetrahedra

Before the FEM call, `zef_lead_field_matrix`:

- Restricts sources to active “brain” tetrahedra (`zef_find_active_compartment_ind`).
- Drops tetrahedra without four face-neighbours (`zef_fi_dipoles` stencil) so sources are not on the surface.
- Optionally peels a millimetre depth (`zef.acceptable_source_depth`, default `0`).
- Decomposes the DOF lattice with `zef_decompose_dof_space` toward `zef.n_sources`, iterating `zef.source_space_creation_iterations` times. Continuous source models keep `nearest_source_neighbour_inds`; discrete models clear that index.

`zef.source_direction_mode` (Mesh tool **Directions**: Cartesian / Normal / Basis) becomes `lf_param.direction_mode` `'cartesian'` / `'normal'` / `'face_based'`.

## GUI versus scripts

**Run script** on the Mesh tool does **not** hard-code EEG. It evaluates whatever is in the Script column. Default head INI rows are the wrappers:

```text
zef_eeg_lead_field_isotropic;
zef_meg_magnetometers_lead_field_isotropic;
zef_meg_gradiometers_lead_field_isotropic;
zef_eit_lead_field_isotropic;
zef_tes_lead_field_isotropic;
```

and the matching `*_anisotropic` names for types 6–10.

Those wrappers **do not create a mesh**. Create the mesh first (**Create FEM mesh**), then run a row.

`zef_*_make_all` scripts **do** create a mesh: they set the type, turn interpolation on, call `zef_create_finite_element_mesh`, postprocess, then the non-isotropic/anisotropic wrapper (`zef_eeg_lead_field`, etc.). They are MATLAB scripts (they read `zef` in the base workspace). They are **not** wired to a Mesh-tool button.

Other Mesh-tool buttons that live in this folder:

| Button | Script |
|--------|--------|
| **Postprocess FEM mesh** | `zef_postprocess_finite_element_mesh` → `zef_postprocess_fem_mesh` |
| **Source interpolation** | `zef_source_interpolation` |
| **Resample field** | `zef_field_downsampling` (subsample source columns toward `zef.n_sources`) |
| **Resample surfaces** | `zef_surface_downsampling` → `zef_downsample_surfaces` |
| **Apply transform** | `zef_apply_transform` (bake current affine into points, reset transform widgets) |

## After `L`: interpolation index

`zef_source_interpolation` drops NaN columns, then nearest-neighbour maps:

1. source positions → nodes of active tetrahedra (`source_interpolation_ind{1}`, four node indices per tet);
2. those sources → each active compartment surface (`{2}`);
3. source positions → combined surface-triangle centroids (`{3}`).

`zef_processLeadfields` in `src/inverse` requires `{1}`. Mesh tool checkbox **LF source interp.** is `zef.source_interpolation_on`; the dispatcher also calls interpolation when that flag is true.

`zef_lead_field_filter` then drops columns whose Euclidean column-norm is **above** `quantile(amp, zef.lead_field_filter_quantile)`. Quantile `1` (example default) removes nothing.

## Gravity (bypasses `zef_lead_field_matrix`)

Asteroid profiles (`profile/asteroid_gravity/zeffiro_forward_simulation.ini`) run:

| Script | `zef.gravity_field_type` | Backend |
|--------|--------------------------|---------|
| `zef_gravity_lead_field_scalar` | 3 | `lead_field_gravity` |
| `zef_gravity_lead_field_vector` | 4 | `lead_field_gravity` |
| `zef_gravity_gradient_lead_field_scalar` | 1 | `lead_field_gravity_grad` |
| `zef_gravity_gradient_lead_field_vector` | 2 | `lead_field_gravity_grad` |

Density is `zef.rho`, not `zef.sigma`. `zef_lead_field_matrix_gravity` is the dispatcher analogue for types 1–4 of `gravity_field_type`.

## File map (by job, not inventory)

| Job | Files |
|-----|--------|
| Dispatch | `zef_lead_field_matrix.m`, `zef_run_forward_simulation.m` |
| Profile wrappers (INI Script cells) | `zef_*_lead_field_isotropic.m`, `zef_*_lead_field_anisotropic.m` |
| Generic wrappers used by `make_all` | `zef_eeg_lead_field.m`, `zef_meg_*_lead_field.m`, `zef_eit_lead_field.m`, `zef_tes_lead_field.m` |
| One-shot mesh+LF scripts | `zef_eeg_make_all.m` and MEG/EIT/TES siblings |
| FEM cores | `zef_lead_field_eeg_fem.m`, `zef_lead_field_meg_fem.m`, `zef_lead_field_meg_grad_fem.m`, `zef_lead_field_eit_fem.m`, `zef_lead_field_tes_fem.m` |
| Dipole stencils | `zef_fi_dipoles.m` (face-interior / H(div)), `zef_ew_dipoles.m` (edge-Whitney) |
| Post-LF | `zef_source_interpolation.m`, `zef_lead_field_filter.m`, `zef_kron_reduction.m` |
| Multiresolution index maps | `zef_make_multires_dec.m`, `zef_make_eit_dec.m`, `zef_make_gravity_dec.m` |
| Mesh-tool helpers | `zef_create_finite_element_mesh.m`, `zef_postprocess_finite_element_mesh.m`, `zef_field_downsampling.m`, `zef_surface_downsampling.m`, `zef_apply_transform.m` |

Call the public names `zef_lead_field_*_fem` (filenames). The first `function` line inside some FEM files still uses the historical names `lead_field_eeg_fem`, `lead_field_meg_fem`, etc.

## Scripting examples

Dispatcher after mesh + attached sensors (same sequence as `examples.forward.lead_field_example`):

```matlab
zef.lead_field_type = 1;
zef.source_model = core.types.ZefSourceModel.Whitney;
zef.source_interpolation_on = true;
zef.sensors_attached_volume = zef_attach_sensors_volume(zef, zef.sensors);
zef = zef_lead_field_matrix(zef);
```

TES with CEM impedances stored in sensor column 6: `zef_lead_field_matrix` copies `zef.sensors(:,6)` into `zef.lf_param.impedances` when `size(zef.sensors,2) == 6` for types 1, 4, 5, 6, 9, 10.

## Developer notes

- PCG tuning for EEG/EIT/TES belongs in `zef_transfer_matrix` and `zef.lf_param`, not in a copy of the FEM file.
- `zef_kron_reduction` applies `Schur \ G` for CEM + Whitney/H(div). St. Venant is intentionally left unchanged (TODO in the source).
- Adding a type above 10 requires a new `if zef.lead_field_type == …` block in `zef_lead_field_matrix`; there is no `otherwise` error, so an unknown type silently leaves `zef.L` untouched.
