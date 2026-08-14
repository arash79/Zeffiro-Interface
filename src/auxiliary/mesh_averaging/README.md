# Lead-field averaging (`src/auxiliary/mesh_averaging`)

Helpers to split the source space and average `zef.L` columns that fall in the same group. That is a coarse-graining of the lead field, not the Mesh-tool **Source interpolation** (Whitney / H(div) / St. Venant maps from tetrahedra to `n_sources` dipoles).

Not on any menu. Call from MATLAB after `zef.L` and `source_positions` exist. Filename `zef_decompose_soure_space.m` is spelled that way in this tree.

| File | Kind | Role |
|------|------|------|
| `zef_decompose_soure_space.m` | function | Split `center_points` into `source_count` groups (filename spelling `soure`) |
| `zef_average_lead_field.m` | **script** | Average lead-field columns using that decomposition (`zef` in workspace) |
| `zef_get_surface_triangles.m` | function | Outer faces of one `domain_labels` value |
| `zef_plot_surface_triangles.m` | **script** | Plot those faces |
| `zef_distance_to_mesh.m` | function | Duplicate of `src/auxiliary/zef_distance_to_mesh.m` |
| `zef_find_distance_to_mesh.m` | **script** | Sample distances (`number_of_points = 10000`) |

Production source interpolation is Mesh tool **Source interpolation** (`zef_source_interpolation` / Whitney–H(div)–St. Venant in `src/gui/helpers`).
