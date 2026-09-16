# src/mesh

## Folder purpose

Builds and post-processes the **labeled tetrahedral FEM mesh** from segmentation surfaces. Mesh-tool **Create FEM mesh** calls `zef_create_finite_element_mesh` in **this folder** (not `src/forward/lead_field`). That wrapper optionally downsamples surfaces, gathers them, runs the lattice builder, then post-processes. Electrode coupling into the stiffness system (`zef_build_electrodes`) and P1 conductivity stiffness (`operators/zef_stiffness_matrix`) also live here so lead-field assemblers can stay modality-specific.

NSE volume/surface scalar products are in `barycentric/` and are **not** used for EEG stiffness.

## Main contents

### Pipeline entry points

| File | Kind | Role |
|------|------|------|
| `zef_create_finite_element_mesh.m` | function | Mesh-tool **Create FEM mesh** (`h_pushbutton21`). Chain: optional `zef_downsample_surfaces` → `zef_process_meshes` → `zef_create_fem_mesh` → `zef_postprocess_fem_mesh` → clear `source_ind` → `zef_update`. Does **not** assemble `zef.L`. |
| `zef_process_meshes.m` | function | Active `<tag>_points/_triangles` → `reuna_p` / `reuna_t` plus sensor transforms. Always run before the lattice builder. Optional `explode_param` for visualization. |
| `zef_create_fem_mesh.m` | function | Lattice → tets via `zef_lattice_cubes_to_tetra`. Mode 1: 5 tets/cube (parity-dependent stencils); mode 2: 6 tets. PML via `zef_pml_mesh` when a compartment has `_sources == -1`. Then labeling and optional refinement. CPU labeling uses `parfor`; `zef_ensure_parpool` starts a pool only when Parallel Computing Toolbox is present. |
| `zef_lattice_cubes_to_tetra.m` | function | Cartesian `meshgrid` lattice → tetra / `label_ind`. Called from `zef_create_fem_mesh`. |
| `zef_postprocess_fem_mesh.m` | function | Smooth / second-pass refine / `zef_tetra_turn` / pack `sigma`, `brain_ind`, per-compartment `surface_triangles`. |
| `zef_postprocess_finite_element_mesh.m` | **script** | Mesh-tool **Postprocess FEM mesh** (`h_pushbutton34`): calls `zef_postprocess_fem_mesh` then `zef_update`. |
| `zef_downsample_surfaces.m` | function | Resample / smooth / inflate surfaces toward `max_surface_face_count` × `zef_find_relative_resolution`. |

### Labeling, refinement, smoothing (caller-workspace scripts)

These scripts are invoked from `zef_create_fem_mesh` / `zef_postprocess_fem_mesh` and write locals into the **caller** workspace. Do not convert them to functions without updating those callers.

| File | Role |
|------|------|
| `zef_segmentation_counter_step.m` | Injects `mesh_res`, `reuna_type`, `pml_ind_aux`, `submesh_cell`, `name_tags`, `aux_active_compartment_ind`. |
| `zef_mesh_labeling_step.m` | Assigns tet tissue IDs (solid-angle tests) and drops exterior tetrahedra. |
| `zef_mesh_relabeling.m` | Re-tests tet membership after refine/smooth (`zef_point_in_compartment`). |
| `zef_solid_angle_labeling.m` | Per-node inside tests walking `reuna_p` / `reuna_t`; first surface that claims a node wins. |
| `zef_choose_domain_labels.m` | Picks one domain label per tet from candidate columns using labeling priority. |
| `zef_find_subdomain_ind.m` | Local 1..K subdomain index within each domain label. |
| `zef_refinement_step.m` | Surface-refinement pass on the tet mesh. |
| `zef_mesh_refinement.m` | 8-to-1 tet split (mid-edge nodes via `zef_mid_edge_node_index`; four corner tets + four octahedron tets). |
| `zef_get_tetra_to_refine.m` | Adaptive volume-refinement candidates near a surface. |
| `zef_triangular_mesh_refinement.m` | 4-to-1 split of every triangle (used when a surface needs *more* faces). |
| `zef_smoothing_step.m` | Taubin smoothing of FEM nodes; may inflate FEM surfaces toward segmentation. |
| `zef_distance_smoothing.m` | Taubin with `exp(−α mean d)` edge weights. |
| `zef_smooth_surface.m` | Taubin λ=1 / μ=−1 Laplacian on a triangle mesh. |
| `zef_inflate_surface.m` | Same Laplacian, scaled by `inflate_strength`, for source-surface inflate. |
| `zef_inflate_surfaces.m` | Snap interior FEM boundary nodes toward segmentation (ray–triangle). |
| `zef_fix_negatives.m` | Move vertices of inverted tets until `zef_condition_number ≥ 0`. |
| `zef_tetra_turn.m` | Face-swap poorly shaped tets with a neighbour. |

### Geometry predicates and mesh queries

| File | Role |
|------|------|
| `zef_surface_mesh.m` | Boundary faces of a tet mesh (or subset). Workhorse for labeling, inflation, plotting, NSE, barycentric surface operators. |
| `zef_tetra_volume.m` | Signed (or absolute) tet volume `(1/6) det`. Lead-field path always takes `abs`. |
| `zef_tetra_barycentra.m` | Arithmetic centroid of each tet (source placement / interpolation sites). |
| `zef_tetra_gradient_field.m` | Sparse maps nodal scalars → `σ∇u` at tet centroids (TES current density). |
| `zef_volume_gradient.m` | Signed face-area vectors for one P1 hat per tet (`∇ψ_i = area_i / 3V`). |
| `zef_condition_number.m` | Signed tet quality, volume, longest edge. Inverted (negative-volume) orientation is the stored convention. |
| `zef_adjacency_matrix.m` | Sparse node–node adjacency of tet edges. |
| `zef_source_tetra.m` | Barycentric locate of points in the tet mesh (`knnsearch` + `zef_3by3_solver`). |
| `zef_point_in_cluster.m` | Solid-angle inside test (no GPU/waitbar wrapping). |
| `zef_find_intersecting_triangle.m` | First triangle hit by a directed segment (`zef_fix_negatives`). |
| `zef_find_adjacent_tetra.m` | Neighbour tet sharing a given face (NSE face-flux). |
| `zef_find_active_compartment_ind.m` | Tet indices whose domain is a source tissue (`*_sources` in `{1,2}`). |
| `zef_find_relative_resolution.m` | Per-compartment `4^n` face-count multiplier for downsampling. |
| `zef_nearest_points.m` | KD-tree / range search (`single` / `count` / `range`). |
| `zef_deep_nodes_and_tetra.m` | Subvolume nodes/tets farther than a depth from the skin → `zef.brain_activity_inds`. |
| `zef_minimal_mesh.m` | Drop unused vertices when a plot patch is sparse vs its node array. |
| `zef_smooth_field.m` | Jacobi averages of a nodal field on a triangulation. |
| `zef_merge_surface_mesh.m` | Append or replace `zef.<tag>_points` / `_triangles` during import. |
| `zef_hexa_to_tetra.m` | Split 8-node hexes into six tets (DUNEuro hex meshes; same stencil as lattice mode 2). |
| `zef_pml_mesh.m` | Graded Cartesian lattice for a perfectly matched outer layer. |
| `zef_build_electrodes.m` | PEM/CEM couple into the FEM blocks after stiffness: augments `A`, builds `B` (N×E) and `C` (E×E). |

### Subfolders

| Path | Role |
|------|------|
| `operators/` | **`zef_stiffness_matrix`** — EEG/MEG/EIT/TES P1 conductivity stiffness. |
| `barycentric/` | NSE volume/surface scalar FE products (and `zef_3by3_solver` used by meshing too). |

## Code functionality

```
segmentation surfaces (<tag>_points / _triangles)
  → zef_process_meshes          % affine / scale / rotate / translate → reuna_*
  → optional zef_downsample_surfaces
  → zef_create_fem_mesh         % lattice, label, refine → nodes / tetra / domain_labels
  → zef_postprocess_fem_mesh    % smooth, quality, sigma, brain_ind
  → (later) lead_field → zef.L
```

**Inputs:** compartment tags on, surface points/triangles, mesh resolution / refinement / smoothing flags, conductivity parameters from `parameter_profile`.  
**Outputs:** `nodes`, `tetra`, `domain_labels`, `sigma`, `brain_ind`, `surface_triangles`, `condition_number`, surface caches used by plot and forward.

Coordinate unit is the project length unit (typically millimetres). EEG FEM later divides by 1000 inside `zef_lead_field_matrix`. Zeffiro stores inverted (negative-volume) tet orientation as valid; `zef_refinement_step` swaps vertices 1–2 when volume is positive.

## Workflow context

```
Segmentation tool → surfaces
Mesh tool Create FEM mesh → zef_create_finite_element_mesh (this folder)
operators/ → stiffness for src/forward/lead_field FEM
barycentric/ → NSE (src/forward/nse, plugins/NSE_tool)
zef_hexa_to_tetra → utilities.duneuro2zef.convert
```

Sensors still need attaching (`src/sensors`) after Create FEM mesh. Lead field is a separate Mesh-tool **Run script** / `zef_lead_field_matrix` step.

## Usage instructions

```matlab
% GUI: Mesh tool → Create FEM mesh (then Postprocess if you changed smoothing/refine-2)
% Programmatic (same chain the button uses):
zef = zef_create_finite_element_mesh(zef);

% Surfaces only (transforms, no volume mesh):
zef = zef_process_meshes(zef);

% Stiffness (called from lead-field FEM, not from the Mesh tool):
volume = zef_tetra_volume(nodes, tetra, true);
A = zef_stiffness_matrix(nodes, tetra, volume, sigma_packed);
```

## Important notes

- EEG stiffness uses **`operators/zef_stiffness_matrix`** + `zef_volume_gradient` — **not** `barycentric/`.
- Create does not compute `zef.L`; run a forward script afterward.
- `zef_create_finite_element_mesh` and `zef_postprocess_finite_element_mesh` live here. Mesh-tool **Resample field** / **Resample surfaces** scripts (`zef_field_downsampling`, `zef_surface_downsampling`) still live under `src/forward/lead_field` because they also touch `zef.L` / source interpolation.
- Units: surfaces typically mm; some solvers (NSE) scale to metres internally.
- Several pipeline steps are **scripts** (`zef_segmentation_counter_step`, `zef_mesh_labeling_step`, `zef_refinement_step`, `zef_smoothing_step`). They require `zef` and mesh arrays in the caller workspace.

## Developer guidance

- New labeling or refine policies: keep in this folder; keep FEM modality math in `src/forward/lead_field`.
- Do not route EEG assembly through barycentric without a deliberate redesign and tests.
- Pitfall: treating `zef_hexa_to_tetra` as the Mesh-tool lattice path (`zef_create_fem_mesh` is).
- Pitfall: converting a workspace script to a function without updating `zef_create_fem_mesh` / `zef_postprocess_fem_mesh`.
- When moving `zef_create_finite_element_mesh`, update `tests.smoke.ArchitectureLayoutTest`, `docs/architecture.md`, and this README together.
- Length units and tet orientation: [docs/conventions.md](../../docs/conventions.md). Typeset mesh chapter: [`documentation/mesh_generation.tex`](../../documentation/mesh_generation.tex).
