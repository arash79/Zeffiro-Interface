# Units, coordinates, and matrix conventions

Scientific bugs in this codebase are often unit or layout bugs. This page records what the **live MATLAB** does. If a comment, a LaTeX chapter, and this file disagree, trust the functions named below.

## Length

Surfaces, sensors, `mesh_resolution`, and (after a lead-field wrap-up) `source_positions` live in the project length unit.

The Mesh tool dropdown `h_popupmenu6` is wired in `src/gui/tools/zef_mesh_tool.m`:

| `zef.location_unit` | Label | After FEM |
|---------------------|-------|-----------|
| `1` (default in `zef_init`) | mm | `source_positions` scaled `×1000` from metres |
| `2` | cm | `source_positions` scaled `×100` from metres |
| `3` | m | no extra scale |

EEG/MEG/EIT/TES FEM cores work in **metres**. `zef_lead_field_matrix` copies `nodes` / `sensors` to `*_aux` and **divides millimetre coordinates by 1000** before calling those cores, then converts `source_positions` back using the table above.

`zef_source_interpolation` nearest-neighbour searches against `zef.nodes` (typically mm). If `location_unit_current == 2`, it multiplies the **local** `source_positions` copy by 10 (cm → mm) for the search. If `location_unit_current == 3`, it writes `1000 * source_positions` back onto `zef.source_positions` (m → mm).

The lattice builder does **not** convert millimetres to metres. `mesh_resolution` must match the surface unit.

`acceptable_source_depth` is millimetres inside `zef_deep_nodes_and_tetra`.

Some solvers (NSE) scale to metres internally; see `src/forward/nse`.

## Conductivity, impedance, density

| Quantity | Field / columns | Unit |
|----------|-----------------|------|
| Isotropic conductivity | `zef.sigma(:,1)` | S/m |
| Anisotropic tensor | `zef.sigma(:,3:8)` = `[σ11 σ22 σ33 σ12 σ13 σ23]` per tetrahedron | S/m |
| CEM contact impedance | electrode column, parsers | ohms |
| Gravity density | `zef.rho` (asteroid profiles) | kg/m³ with SI \(G\); kernels convert mm→m |

Anisotropic types 6–10 require a symmetric positive-definite tensor per tet. Mixed leftover off-diagonals are a common PCG failure after a partial DTI apply.

## Time, frequency, SNR

| Quantity | Typical field | Unit |
|----------|---------------|------|
| Sampling rate | `sampling_frequency` / `inv_sampling_frequency` | Hz |
| Band-pass edges | `low_cut_frequency`, `high_cut_frequency` | Hz |
| Time start / window / step | `time_start`, `time_window`, `time_step` | seconds |
| SNR | `signal_to_noise_ratio` / `inv_snr` | dB |

Class inverters inherit the elliptic band-pass from `inverse.CommonInverseParameters` (order 3). Plugin GUIs copy the same ideas onto `zef.inv_*` fields.

## Angles and affine transforms

Compartment Euler angles (`<tag>_xy_rotation`, `_yz_rotation`, `_zx_rotation`) are **degrees**, applied about the pre-affine centroid in `zef_process_meshes`. Translations use the same length unit as the surface points.

## Indexing

MATLAB is 1-based everywhere in first-party code.

- `zef.tetra(i,:)` — four vertex indices into `zef.nodes`
- `zef.domain_labels(i)` — tissue id of tetrahedron `i`
- `zef.compartment_tags` — cell of short names (`d1`, `w`, …). Segmentation-tool **table rows are stored in reverse order** relative to this cell. Column 1 is labeling priority (lower first).
- `<tag>_sources` — Activity integer. Display label is `zef.compartment_activity{_sources+2}`: `-1` Bounding box / PML, `0` Inactive, `1` Constrained field, `2` Unconstrained field, `3` Active surface. Source placement uses `{1, 2}` only.
- Source interpolation `source_interpolation_ind{1}` — for each active tetrahedron, four nearest source indices (one per node). Volume plotters average those four values.

Zero-based indices appear only at external interfaces (some vendor files). Convert at the boundary.

## Matrix orientation

A **lead field** `zef.L` maps sources to sensors:

```text
y ≈ L x
```

- Rows of `L` = sensors (same order as the attached electrode / MEG coil set)
- Columns of `L` = source degrees of freedom

If `source_direction_mode` is Cartesian or normal with three components per location, columns come in groups of three `(x,y,z)` (or the equivalent triplet after `zef_processLeadfields` reordering). `size(L,2)` is then `3 * n_positions` (or a subset after interpolation / filtering).

Measurements `zef.measurements` are sensors × time (columns are time samples). Inverse output `zef.reconstruction` is a **cell**, one column vector per frame, in the processed source layout; `zef_postProcessInverse` scatters that onto the full grid for plotting.

Dipole scan stores **goodness-of-fit**, not current amplitude, in that vector. Do not read those peaks as source strength.

## Tetrahedral orientation

Zeffiro stores inverted (negative signed volume) tetrahedra as a valid convention. `zef_tetra_volume` on the lead-field path takes `abs`. `zef_refinement_step` swaps vertices 1–2 when volume is positive so the stored orientation stays consistent. Do not “fix” signs without updating refinement, stiffness, and interpolation together.

Default lattice (`initial_mesh_mode == 1`): five tetrahedra per cube, parity-dependent stencils so shared faces use the same diagonal. Mode `2`: six tetrahedra, one stencil.

## Electrode column layouts

There are **three** electrode representations. Mixing them is a common source of unit and indexing bugs.

### 1. Session array `zef.sensors`

Point electrodes (PEM): `N×3` (`x y z`) in the project length unit.

Complete electrode model (CEM): `N×6`. Import parsers, attachment, and
`zef_cem_electrode` all store/consume

```text
[x y z  outer_radius  inner_radius  impedance]
```

DAT/CSV **files** still list inner then outer (`x y z inner outer Z`); the
parsers swap those two columns so `zef_attach_sensors_volume` sees
`inner ≤ d < outer`. The previous parser layout `[inner outer Z]` produced
empty CEM patches (`d < inner` and `d ≥ outer` is impossible).

After **Import → Import electrodes**, `zef_process_meshes` may rebuild columns 4–6 from Segmentation-tool radius widgets. File values are not automatically copied onto those widgets. Re-run the forward script after geometry that should affect `L` changes.

DAT vs CSV impedance: DAT requires strictly positive CEM impedance; CSV allows `0`. A DAT line with all-zero CEM columns is collapsed to `N×3`.

### 2. Attachment table `zef.sensors_attached_volume`

Produced by `zef_attach_sensors_volume`. Assign the return value; the function does not mutate `zef`.

- PEM: same width as the input, with `xyz` replaced by the snapped node.
- CEM: an **index table**, not metres. Typical rows:
  - annulus: `[electrode_id, n1, n2, n3]` (one row per skin triangle)
  - nearest node: `[id, node_or_triangle_index, 1, 0]`
  - buried tet: four rows `[id, tet_node, barycentric λ, 0]`

### 3. FEM `electrodes` argument (EEG / EIT / TES cores)

`zef_lead_field_matrix` does **not** pass `zef.sensors` into the FEM cores for EEG/EIT/TES.

- PEM (`size(zef.sensors,2)==3`): `sensors_aux = sensors_attached_volume(:,1:3)/1000` — snapped xyz in **metres**. The FEM then treats a 3-column array as PEM and snaps again to the nearest node of the metre-scale mesh.
- CEM (otherwise, types 1/4/5/6/9/10): `sensors_aux = sensors_attached_volume` with **no** `/1000`, because the table is integer indices. The FEM treats `size(electrodes,2)==4` as CEM and uses those rows as `ele_ind` for `zef_build_electrodes`. Impedance comes from `zef.sensors(:,6)` via `lf_param.impedances`.

MEG keeps `zef.sensors` and only divides columns 1–3 by 1000 (coil positions). MEG does not attach.

Do not document CEM as “N×4 metres”. The 4-column object is the attachment table.

## Source models

`zef.source_model` is an integer 1–6 or a `core.types.ZefSourceModel` member. Default in `zef_init` is `2` (H(div)).

| Code | Member | Element idea |
|------|--------|----------------|
| 1 | Whitney | Edge elements |
| 2 | Hdiv | Face-interior (H(div)) |
| 3 | StVenant | Nodal monopolar St. Venant loads |
| 4–6 | Continuous* | Same element family with continuous neighbourhood |

`core.ZefSourceModel` at the package root exists so older `.mat` files still load. Live code should use `core.types.ZefSourceModel`.

## Direction mode

`zef.source_direction_mode` (Mesh tool **Directions**):

| Value | Name in `lf_param` | Meaning |
|-------|--------------------|---------|
| 1 | `cartesian` | Three Cartesian components |
| 2 | `normal` (default) | Constrained toward the local surface normal |
| 3 | `face_based` | Face-based basis |

This controls how columns of `L` are interpreted in inverse and visualization. It does not pick which FEM file `zef_lead_field_matrix` calls (`lead_field_type` does that).

## Lead-field type integers

| `zef.lead_field_type` | Modality | Conductivity |
|-----------------------|----------|--------------|
| 1 / 6 | EEG | isotropic `sigma(:,1)` / anisotropic `(:,3:8)` |
| 2 / 7 | MEG magnetometers | same |
| 3 / 8 | MEG gradiometers | same |
| 4 / 9 | EIT | same |
| 5 / 10 | TES / tES | same |

Gravity uses `zef.gravity_field_type` and a separate dispatcher. NSE and GPU-ToRRe wave do not write EEG/MEG `zef.L`.

## PCG (lead-field transfer)

EEG and TES electrode potentials are solved in `zef_transfer_matrix`. MEG magnetometer/gradiometer and EIT copy the **same** PCG into their FEM files; they do not call `zef_transfer_matrix`. NSE/wave use a third pair, `pcg_iteration` / `pcg_iteration_gpu` under `src/forward/solvers`. Gravity FEM does not use this electrode-transfer PCG.

| Path | Preconditioner |
|------|----------------|
| GPU (`use_gpu` and `gpu_count > 0`) | Jacobi: multiply by `1./diag(A)`. `zef.preconditioner` is ignored. |
| CPU, `preconditioner == 2` (`'ssor'`) | Symmetric successive over-relaxation factors |
| CPU, otherwise (`'cholinc'`, including `preconditioner == 1`) | `ichol(A, struct('type','nofill'))` |

`zef_init` sets `preconditioner = 2` (SSOR) and `solver_tolerance = 1e-6`. `zef_lead_field_matrix` copies `solver_tolerance` → `lf_param.pcg_tol`. If `solver_tolerance` is **missing**, the dispatcher falls back to `1e-8`. Live GUI sessions therefore use **1e-6**.

`preconditioner_tolerance` (default `0.001`) is copied to `lf_param.cholinc_tol` and the FEM files assign it to a local `cholinc_tol`. **Nothing reads that local after the assignment.** The incomplete-Cholesky path is no-fill; there is no drop-tolerance argument. Changing the Mesh-tool / Forward-options “preconditioner tolerance” widget does not change the PCG that currently runs.

The Forward-and-inverse options initializer (`zef_init_forward_and_inverse_options`) would set `preconditioner = 1` only if the field were missing. After a normal `zef_init`, the field is already `2`.

## Workspace coupling

Many mesh scripts (`zef_refinement_step`, `zef_smoothing_step`, …) write into the **caller** workspace. GUI callbacks often `evalin('base','zef')`. If you keep a local copy of `zef` and never `assignin` it, the next click sees stale state.

New numerical code should take `zef` (or extracted arrays) as arguments when practical. See [ADR-001](adr/ADR-001-hybrid-path-and-packages.md).

## Related

- Field dictionary: [zef-state.md](zef-state.md)
- Mesh pipeline: [`src/mesh/README.md`](../src/mesh/README.md)
- Lead field: [`src/forward/lead_field/README.md`](../src/forward/lead_field/README.md)
- PCG failures: [troubleshooting.md](troubleshooting.md)
