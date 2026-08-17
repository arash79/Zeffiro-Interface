# src/auxiliary/mesh_averaging

## Folder purpose

Helpers to **split the source space** and **average `zef.L` columns** that fall in the same group — a coarse-graining of the lead field. This is **not** Mesh-tool **Source interpolation** (Whitney / H(div) / St. Venant maps from tetrahedra to `n_sources` dipoles).

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_decompose_soure_space.m` | function | Split `center_points` into `source_count` groups (filename spelling `soure`) |
| `zef_average_lead_field.m` | script | Average lead-field columns using that decomposition (`zef` in workspace) |
| `zef_get_surface_triangles.m` | function | Outer faces of one `domain_labels` value |
| `zef_plot_surface_triangles.m` | script | Plot those faces |
| `zef_distance_to_mesh.m` | function | Duplicate of `src/auxiliary/zef_distance_to_mesh.m` |
| `zef_find_distance_to_mesh.m` | script | Sample distances (`number_of_points = 10000`) |

## Code functionality

- Decomposition groups nearby source centers; averaging collapses matching lead-field columns into a coarser `L`.
- Surface-triangle helpers extract and plot outer faces for a chosen domain label.
- Distance helpers sample point-to-mesh distances (legacy / diagnostic).

## Workflow context

Offline coarse-graining or mesh diagnostics after `zef.L` and source positions exist. Production source interpolation remains Mesh tool **Source interpolation** (`zef_source_interpolation` in `src/gui/helpers` / forward lead-field code).

## Usage instructions

1. Build mesh and lead field so `zef.L` and source centers exist.
2. From MATLAB, call `zef_decompose_soure_space` then run `zef_average_lead_field` (script expects workspace `zef`).
3. Optionally run surface / distance scripts for inspection.

Not on any menu.

## Important notes

- Filename `zef_decompose_soure_space.m` is spelled that way in this tree.
- `zef_distance_to_mesh.m` duplicates `src/auxiliary/zef_distance_to_mesh.m`.
- Averaging changes the meaning of columns — keep track of the grouping if you invert with the coarse `L`.

## Developer guidance

Prefer fixing callers to use production `zef_source_interpolation` for tetra→dipole maps. If extending averaging, document group count and column indexing next to the decomposition API; avoid silent renames of the misspelled filename without updating callers.
