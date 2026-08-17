# src/mesh

## Folder purpose

Builds and post-processes the **labeled tetrahedral FEM mesh** from segmentation surfaces: gather active compartment surfaces, voxel/lattice meshing, labeling, refinement, smoothing, electrode coupling helpers, and packing of `sigma` / `brain_ind`. Mesh-tool **Create FEM mesh** calls a thin wrapper in `src/forward/lead_field` that chains the functions here.

## Main contents

| File / subfolder | Role |
|------------------|------|
| `zef_process_meshes` | Active `<tag>_points/_triangles` → `reuna_p` / `reuna_t` + sensors |
| `zef_create_fem_mesh` | Lattice → tets (mode 1: 5/cube; mode 2: 6); PML via `zef_pml_mesh` |
| `zef_postprocess_fem_mesh` | Smooth / re-refine / indices; `brain_ind`, packed `sigma` |
| `zef_downsample_surfaces` | Resample / smooth / inflate surfaces |
| `zef_mesh_refinement` | 8-to-1 tet split |
| `zef_mesh_labeling_step` / `zef_mesh_relabeling` | Tissue IDs after create / refine |
| `zef_build_electrodes` | PEM/CEM couple into FEM blocks |
| `zef_volume_gradient` / `zef_tetra_gradient_field` | P1 gradients / `σ∇u` for TES |
| Geometry utils | `zef_tetra_volume`, `zef_tetra_turn`, `zef_tetra_barycentra`, `zef_surface_mesh`, `zef_source_tetra`, inflate/smooth/merge helpers |
| `operators/` | **`zef_stiffness_matrix`** — EEG/MEG/EIT/TES stiffness |
| `barycentric/` | NSE volume/surface scalar FE products (not EEG stiffness) |
| Legacy | `zef_fem_mesh` (superseded by `zef_create_fem_mesh`); `zef_optimize_mesh` (no caller) |

## Code functionality

Pipeline:

```
segmentation surfaces
  → zef_process_meshes
  → optional zef_downsample_surfaces
  → zef_create_fem_mesh
  → zef_postprocess_fem_mesh
  → lead_field → zef.L
```

**Inputs:** compartment tags on, surface points/triangles, mesh resolution / refinement flags, conductivity parameters.  
**Outputs:** `nodes`, `tetra`, `domain_labels`, `sigma`, `brain_ind`, surface caches used by plot/forward.

## Workflow context

```
Segmentation tool → surfaces
Mesh tool Create FEM mesh → wrappers in lead_field/ → this folder
operators/ → stiffness for lead_field FEM
barycentric/ → NSE (src/forward/nse, NSE_tool)
```

## Usage instructions

```matlab
% GUI: Mesh tool → Create FEM mesh (then Postprocess if needed)
% Programmatic (same chain the button uses):
zef_create_finite_element_mesh;   % wrapper in src/forward/lead_field
```

## Important notes

- EEG stiffness uses **`operators/zef_stiffness_matrix`** + volume-gradient helpers — **not** `barycentric/`.
- Units: surfaces typically mm; some solvers scale to metres internally (NSE).
- Create does not compute `zef.L`; run a forward script afterward.

## Developer guidance

- New labeling or refine policies: keep in this folder; keep FEM modality math in `lead_field`.
- Do not route EEG assembly through barycentric without a deliberate redesign and tests.
- Pitfall: editing `zef_fem_mesh` thinking it is still the live path.
