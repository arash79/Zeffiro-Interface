# src/mesh

## Folder purpose

**FEM mesh generation and processing**: convert compartment surfaces into labeled tetrahedral volumes (`zef.nodes`, `zef.tetra`, `zef.domain_labels`), refine and relabel meshes, build electrode structures, and provide barycentric finite-element operators used by forward (stiffness) and NSE solvers.

## Main contents

### Root (~33 files)
| File | Role |
|------|------|
| `zef_create_fem_mesh.m` | Main mesh builder: lattice/PML grid, 5- or 6-tet cubes, labeling, refinement |
| `zef_fem_mesh.m` | Lower-level lattice builder with `zef_tetra_in_compartment` labeling |
| `zef_postprocess_fem_mesh.m` | Smoothing, refinement, `zef_tetra_turn`, `zef_optimize_mesh`, sigma assignment |
| `zef_process_meshes.m` | Surface inflation/explosion, sensor prep before volume mesh |
| `zef_mesh_refinement.m` | 4-to-1 tetra split |
| `zef_build_electrodes.m` | Electrode FEM coupling structures for lead fields |
| `zef_downsample_surfaces.m` / `zef_merge_surface_mesh.m` | Surface preprocessing |
| `zef_source_tetra.m` / `zef_deep_nodes_and_tetra.m` | Source-space indexing helpers |

Alias used by lead-field scripts: `zef_postprocess_finite_element_mesh` → calls `zef_postprocess_fem_mesh`.

### `operators/`
| File | Role |
|------|------|
| `zef_stiffness_matrix.m` | ∫ ∇ψᵢ · (σ∇ψⱼ) dV — used by all `lead_field_*_fem` paths |

### `barycentric/` (~30 files)
Volume/surface scalar matrices (`zef_volume_scalar_matrix_GG`, `FG`, `FF`, `GCC`, `uFG`, …) and `zef_volume_barycentric` quadrature — primary consumer is **`src/forward/nse`**, not standard EEG lead fields.

## Code functionality

**Typical GUI mesh pipeline:**
```
zef_process_meshes → zef_create_fem_mesh → zef_postprocess_fem_mesh
```

Inside `zef_create_fem_mesh`: optional `zef_pml_mesh` → structured grid → `zef_mesh_labeling_step` (point-in-compartment via `src/compartments`) → `zef_mesh_refinement` (adaptive/volume flags from `zef`).

**Labeling** uses `zef_tetra_in_compartment(reuna_p, reuna_t, nodes)` to assign tissue IDs per tetra centroid.

**Postprocess** updates `zef.sigma` per compartment, optimizes quality, and prepares domains for forward solvers.

## Workflow context

| Caller | Usage |
|--------|-------|
| `src/forward/*_make_all` | `zef_create_finite_element_mesh` → `zef_postprocess_finite_element_mesh` |
| `src/gui/tools/zef_mesh_tool.m` | Buttons for create/postprocess mesh |
| `src/compartments` | Inside tests for tetra-in-compartment |
| `src/forward/nse` | Barycentric operators for hemodynamic matrices |
| `+examples/+meshing` | `zef_meshing_example.m` demonstrates full pipeline |

## Usage instructions

```matlab
% After segmentation import and compartment table built
zef = zef_process_meshes(zef);
zef = zef_create_fem_mesh(zef);
zef = zef_postprocess_fem_mesh(zef);
zef = zef_update(zef);

% See +examples/+meshing/zef_meshing_example.m for kwargs (resolution, refinement, PML)
```

GUI: **Mesh tool** → Create FEM mesh / Postprocess buttons.

## Important notes

- Mesh quality and `zef.mesh_resolution` strongly affect lead-field accuracy and memory.
- `zef.meshing_threshold` and `zef.meshing_accuracy` control labeling strictness (see compartment inside tests).
- Barycentric folder is large but **EEG lead fields use `zef_stiffness_matrix`**, not the full GG/FG stack.
- Thalamus refinement example: `+examples/+meshing/zef_meshing_example_thalamus_refinement.m`.

## Developer guidance

- New refinement rule: extend `zef_mesh_refinement.m` and expose flags on `zef` + mesh tool table.
- Labeling changes must stay consistent with `zef.compartment_tags` and dynamic `<tag>_on` fields.
- PML meshes (`zef_pml_mesh`) affect wave/NSE domains — document which profiles enable them.
- When adding operators, follow `zef_volume_scalar_matrix_*` naming and register usage in NSE docs.
