# FEM mesh pipeline (`src/mesh`)

A Zeffiro forward model is a tetrahedral finite-element mesh of the head, with each tetrahedron labeled by tissue. This folder builds that mesh from the compartment surfaces you imported, then supplies the geometric operators the lead-field code uses (stiffness, gradients, electrode coupling).

If you only need to *use* meshing, read **How a user builds a mesh** and **What the Mesh tool buttons do**. If you are changing the algorithm, read **Volume-mesh builder** and the file-level help.

## Where this sits in Zeffiro

```
Import segmentation  →  compartment STL/ASC on zef.<tag>_points/_triangles
         ↓
zef_process_meshes   →  zef.reuna_p, zef.reuna_t  (active surfaces, scaled)
         ↓
zef_create_fem_mesh  →  zef.nodes, zef.tetra, zef.domain_labels
         ↓
zef_postprocess_fem_mesh  →  smoothing, orientation, zef.sigma
         ↓
src/forward lead field   →  zef.L
```

Surfaces come from the segmentation tool / `src/io` import. Tissue-inside tests used during labeling live in `src/compartments`. After a mesh exists, `src/sensors` attaches electrodes to the volume and `src/forward/lead_field` assembles the stiffness matrix with `operators/zef_stiffness_matrix.m`.

## How a user builds a mesh

1. Import a segmentation so the segmentation tool shows compartments (scalp, skull, CSF, brain, …) with coordinates in the project length unit (typically millimetres).
2. Open **ZEFFIRO Interface: Mesh tool** (created at startup by `zef_mesh_tool`).
3. Set **Mesh resolution** (`zef.mesh_resolution`): this is the cube edge length of the initial lattice. Smaller → more tetrahedra, more memory, slower lead field.
4. Optionally enable **Resample surf.** and set **Surface triangles max.** so imported surfaces are decimated before the volume fill (`zef_downsample_surfaces`).
5. Optionally enable **Refinement** (surface / volume / adaptive flags are on `zef` and in the same tool’s update path).
6. Click **Create FEM mesh**. That does **not** call `zef_create_fem_mesh` alone; it runs the wrapper `zef_create_finite_element_mesh` (in `src/forward/lead_field/`):

```matlab
% Same sequence as the button (zef already in the workspace)
zef.downsample_surfaces = 1;           % checkbox "Resample surf."
zef = zef_create_finite_element_mesh(zef);
```

7. Click **Postprocess FEM mesh** if you changed smoothing or want a second pass (`zef_postprocess_finite_element_mesh` → `zef_postprocess_fem_mesh`).
8. Then run a forward script (Mesh tool **Run script**) or `zef_eeg_make_all` so sensors are attached and `zef.L` is built.

Scripted equivalent without the wrapper:

```matlab
zef = zef_process_meshes(zef);
zef = zef_create_fem_mesh(zef);
zef = zef_postprocess_fem_mesh(zef);
zef = zef_update(zef);
```

A fuller example with resolution and thalamus refinement is `+examples/+meshing/zef_meshing_example.m`.

## What the Mesh tool buttons do

Verified from `src/gui/tools/zef_mesh_tool.m` and `src/gui/apps/zef_mesh_tool_app_exported.m`:

| Control | Calls |
|---------|--------|
| **Create FEM mesh** | `zef_create_finite_element_mesh` |
| **Postprocess FEM mesh** | `zef_postprocess_finite_element_mesh`; `zef_update` |
| **Source interpolation** | `zef_source_interpolation` |
| **Resample field** | `zef_field_downsampling` |
| **Resample surfaces** | `zef_surface_downsampling` (downsample + process_meshes + interpolation) |
| **Run script** | `zef_run_forward_simulation` (evals the selected forward-table row) |
| **Apply transform** | `zef_apply_transform` |
| **Resample surf.** checkbox | `zef.downsample_surfaces` |
| **Refinement** checkbox | `zef.refinement_on` |
| **Mesh smoothing** | `zef.mesh_smoothing_on` |
| **LF source interp.** | `zef.source_interpolation_on` |
| **Mesh resolution** | `zef.mesh_resolution` |
| **Surface triangles max.** | `zef.max_surface_face_count` |
| **Unit** mm/cm/m | `zef.location_unit` |
| **Directions** Cartesian/Normal/Basis | `zef.source_direction_mode` |

The forward-simulation table is the CSV `profile/<profile_name>/zeffiro_forward_simulation.ini`. **Save profile** writes it; **Update from profile** reloads it. **Run script** `eval`s the MATLAB in the selected cell — treat those rows as trusted code.

## Volume-mesh builder (`zef_create_fem_mesh`)

This function fills space with tetrahedra, then labels them.

**Inputs it actually uses** (many injected by the script `zef_segmentation_counter_step` into the caller workspace, not as extra function arguments): `zef.reuna_p`, `zef.mesh_resolution`, `zef.initial_mesh_mode`, compartment `_on` / `_sources` / `_sigma`. A compartment with `_sources == -1` is a perfectly matched layer (PML); the lattice then comes from `zef_pml_mesh` instead of a uniform `meshgrid`.

**Lattice.** Bounding box of non-PML surfaces. Each cube is split into:

- **Mode 1** (default in many profiles): 5 tetrahedra, with a stencil that depends on the parity of the cube indices so shared faces use the same diagonal.
- **Mode 2**: 6 tetrahedra, one stencil for every cube.

**Labeling.** Script `zef_mesh_labeling_step` calls solid-angle inside tests (`src/compartments`) at nodes, keeps tetrahedra whose vertices agree on being inside some compartment, and writes `domain_labels`. Exterior tets are discarded. `zef.priority_mode` and per-compartment labeling priority break ties where surfaces overlap.

**Refinement** (only if `zef.refinement_on`):

- Surface: `zef_refinement_step` splits tets that meet selected compartment boundaries. Compartment list `-1` means all source compartments (`_sources` in `{1,2}`).
- Volume: `zef_mesh_refinement` 4-to-1 split of tets in those compartments.
- Adaptive: `zef_get_tetra_to_refine` picks tets that are too far from the surface (`adaptive_refinement_thresh_val`, `k_param`).

After each pass, `zef.mesh_relabeling` re-runs labeling (`labeling_flag = 2`).

**Outputs on `zef`:** `nodes` (V×3), `tetra` (T×4, 1-based), `domain_labels` (T×1 tissue IDs), `name_tags`, `reuna_distance_vec`.

## Surface resampling (`zef_downsample_surfaces`)

Imported FreeSurfer/SimNIBS surfaces are often too dense for a coarse volume mesh (and too slow to label). This function:

1. Caches the original mesh under `<tag>_points_original_surface_mesh` so repeated clicks do not compound `reducepatch`.
2. For each **active** compartment, sets a target face count `max_surface_face_count * relative_resolution`. Refinement flags raise `relative_resolution` by `4^n` (`zef_find_relative_resolution`).
3. `zef_set_surface_resolution` either `reducepatch`es or loop-refines with `zef_triangular_mesh_refinement`.
4. Light Laplacian smooth (`zef_smooth_surface`).
5. If the compartment is a source region, inflates vertices (`zef_inflate_surface`) into `<tag>_points_inf` so sources sit slightly inside the tissue. Inflation is skipped when `zef.bypass_inflate` is true.

Submeshes (`<tag>_submesh_ind` = cumulative last-face indices) are resampled one patch at a time, then concatenated with face indices offset by the running vertex count.

## Operators the rest of Zeffiro uses

| File | Role |
|------|------|
| `operators/zef_stiffness_matrix.m` | Sparse N×N `A` with `A_ij = ∫ ∇ψ_i · (σ ∇ψ_j) dV`. Used by EEG/MEG/EIT lead fields. Consumes `zef_volume_gradient` (signed face-area vectors) and divides by `9V`. |
| `zef_volume_gradient.m` | Area vector of the face opposite a local vertex. **Not** the physical gradient; see its help. |
| `zef_tetra_gradient_field.m` | Sparse maps nodal potential → `σ∇u` at selected tet centroids. Used by **TES** (`zef_lead_field_tes_fem`), not by the stiffness path. |
| `zef_tetra_barycentra.m` | Arithmetic mean of four vertices. Source placement and interpolation. |
| `zef_build_electrodes.m` | Point vs complete-electrode-model coupling into `A`, `B`, `C`. |
| `barycentric/` | Volume/surface scalar matrices (`GG`, `FG`, `FF`, …). Primary consumer is **`src/forward/nse`**, not standard EEG lead fields. |

Conductivity `σ` is a 6-row packed symmetric tensor per tetrahedron: `xx, yy, zz, xy, xz, yz`. Isotropic tissue uses only the first three equal diagonals.

## Other files in this folder

- `zef_process_meshes.m` — gathers active `<tag>_points` into `reuna_p` / `reuna_t`, applies scaling and inflation, prepares sensors. Always run before `zef_create_fem_mesh` unless the wrapper already did.
- `zef_postprocess_fem_mesh.m` — smoothing, `zef_tetra_turn` (positive volumes), assigns `zef.sigma` from the parameter profile, writes `brain_ind`.
- `zef_fem_mesh.m` — unused legacy 6-tet lattice (reads base `zef`). Live path is `zef_create_fem_mesh`.
- `zef_pml_mesh.m` — graded outer grid when a PML compartment is present (wave / some NSE profiles).
- `zef_tetra_volume.m`, `zef_tetra_turn.m`, `zef_unique_tetra.m` — geometry cleanup. `zef_optimize_mesh` wraps tetra_turn but has no caller.
- `zef_triangulate_surface.m`, `zef_create_sphere.m` — synthetic surface primitives. Not on the default head pipeline.
- `zef_inflate_surface.m` — Taubin on a triangle mesh (`<tag>_points_inf`). `zef_inflate_surfaces.m` — snap FEM nodes toward segmentation (smoothing step).
- `zef_smooth_surface.m`, `zef_merge_surface_mesh.m`, `zef_triangular_mesh_refinement.m`.
- `zef_source_tetra.m` — barycentric point-in-tet; unused in this tree.
- `zef_deep_nodes_and_tetra.m` — `zef.brain_activity_inds` in `zef_lead_field_matrix`.
- `zef_hexa_to_tetra.m` — DUNEuro hexa conversion.
- `zef_mri_mesh_tetra_histogram_snr.m` — analysis helper, no caller.
- `zef_minimal_mesh.m` / `zef_surface_mesh.m` — plot and boundary extraction.

## Surface registration (`zef_process_meshes`)

Turns each active `<tag>_points` / `_triangles` into `zef.reuna_p` / `reuna_t` and transforms `zef.sensors`. Affine is applied as homogeneous rows times `A'`. Euler angles are degrees about the *pre-affine* centroid. A compartment with `_sources == -1` is replaced by a cube whose half-width is `pml_outer_radius` (absolute, unit 2) or `pml_outer_radius * max(|reuna_p|)` (unit 1). The sensor transform sits inside the compartment loop, so the last pass wins. Optional second argument `explode_param` (visualization) pushes submeshes away from their centroids; 1 means no explosion.

`zef.reuna_type` is C×4: `{_sources, zef.compartment_activity{_sources+2}, original tag index, tag name}`. Activity strings are Bounding box / Inactive / Constrained field / Unconstrained field / Active surface for `_sources` = −1,0,1,2,3.

## Labeling (`zef_mesh_labeling_step`, a script)

`labeling_flag` is a caller-workspace variable, not an argument:

| Flag | When | What |
|------|------|------|
| 1 | start of `zef_create_fem_mesh` | solid-angle inside test; drop exterior tets |
| 2 | after each refinement / smoothing if `mesh_relabeling` | `zef_mesh_relabeling` (priority only if `priority_mode==3`) |
| 3 | end of create when `priority_mode==3` | relabel without priority |

`zef_segmentation_counter_step` (also a script) injects `mesh_res`, `pml_ind_aux`, `submesh_cell`, `aux_active_compartment_ind` into `zef_create_fem_mesh` before the lattice is built.

## Postprocess (`zef_postprocess_fem_mesh`)

Does **not** call `zef_optimize_mesh` (that wrapper is unused). It calls `zef_smoothing_step` if `mesh_smoothing_on`, optional second-pass refine (`refinement_*_2` flags), `zef_fix_negatives` then `zef_tetra_turn`, maps subdomain IDs back to compartment indices, optionally drops the outermost domain (`exclude_box`), and writes `brain_ind` / `active_compartment_ind` / `non_source_ind` / `surface_triangles` / `condition_number`. Segmentation/Scalar/On rows of `parameter_profile` become `zef.<param> = [value_at_tet, domain_label]` (typically includes `sigma`).

## Barycentric operators (`barycentric/`)

Letters: **F** = P1 hat ψ, **G** = one Cartesian component of ∇ψ, **n** = unit face normal, **C** = constant per tet. Weights from `zef_barycentric_weighting`: FF `[1/10 1/20]`, GG `1`, FG `1/4`, surface_FF `[1/6 1/12]`, surface_FG `1/3`.

Live NSE consumers (`src/forward/nse`): `GG`, `FF`, `FG`, `volume_scalar_vector_F`, `surface_scalar_matrix_FF`, `surface_scalar_vector_F` / `_Fn`. EEG stiffness does **not** use this folder (`operators/zef_stiffness_matrix` + `zef_volume_gradient` instead).

## Assumptions

- Coordinates of surfaces, sensors, and the volume mesh share one Cartesian frame and one length unit. The Mesh tool unit dropdown stores `zef.location_unit` but the lattice spacing `mesh_resolution` is in that same unit; there is no automatic mm→m conversion inside `zef_create_fem_mesh`.
- `zef.reuna_p` must be populated. Creating a volume mesh with empty surfaces produces an empty or degenerate box.
- GPU vs CPU: when `zef.use_gpu` is false, labeling/refinement expect a parallel pool of size `zef.parallel_processes`.

## See also

- Mesh tool wiring: `src/gui/tools/zef_mesh_tool.m`
- Wrapper: `src/forward/lead_field/zef_create_finite_element_mesh.m`
- Lead field that consumes the mesh: `src/forward/README.md`
- Compartment inside tests: `src/compartments/README.md`
