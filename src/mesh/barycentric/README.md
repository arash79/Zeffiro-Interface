# src/mesh/barycentric

## Folder purpose

Sparse **P1 finite-element assemblers** built from linear hat functions on tetrahedra and boundary faces. The live physics consumer is the **NSE / microcirculation** stack (`src/forward/nse` and `plugins/NSE_tool`). EEG/MEG/EIT stiffness assembly uses `src/mesh/operators/zef_stiffness_matrix.m`, **not** this folder. Visualization does not call these assemblers.

## Main contents

| Role | Files |
|------|--------|
| Core geometry | `zef_volume_barycentric`, `zef_barycentric_weighting`, `zef_3by3_solver`, `zef_determinant` |
| Volume mass / Laplacian / coupling | `zef_volume_scalar_matrix`, `_FF`, `_GG`, `_FG`, `_DD`, `_D` |
| Volume load | `zef_volume_scalar_vector_F` |
| Surface integrals | `zef_surface_scalar_matrix`, `_FF`, `_n`, `_Dn`; vectors `_F`, `_Fn` |

Letter codes in names: **F** = hat, **G/D** = gradient component, **n** = face normal.

## Code functionality

1. `zef_volume_barycentric(nodes, tetra, p_ind, det)` returns barycentric gradient data `b_coord` and signed `det` (related to 6V), using `zef_3by3_solver` for the local 3×3 systems.
2. `zef_barycentric_weighting` supplies reference-tet weights (e.g. volume FF `[1/10 1/20]`, GG `1`, FG `1/4`, surface FF `[1/6 1/12]`).
3. Named wrappers set those weights and call the generic `zef_volume_scalar_matrix*` / `zef_surface_scalar_matrix*` assemblers, returning sparse matrices/vectors on the nodal index set.

**Inputs:** `nodes`, `tetra` (and face connectivity for surface routines), optional subdomain masks.  
**Outputs:** sparse FE matrices / vectors for NSE mass, stiffness-like GG blocks, FG couplings, and boundary terms.

## Workflow context

```
nodes/tetra
    → barycentric assemblers
    → zef_nse_matrices / zef_nse_poisson(_dynamic)
    → NSE_tool Solve / perfusion plots
```

`zef_3by3_solver` is also reused outside NSE for geometry predicates: `zef_source_tetra`, `zef_inflate_surfaces`, `zef_find_intersecting_triangle`. `zef_determinant` is the vectorized 3×3 determinant used by `zef_attach_sensors_volume` for barycentric λ of a point sensor inside a tet.

**Not** on the EEG lead-field FEM path. Sensor burial barycentric λ values live elsewhere (`zef_attach_sensors_volume`).

## Usage instructions

Prefer calling through NSE helpers rather than assembling ad hoc:

```matlab
% Typical production path (inside NSE):
%   zef_nse_matrices → volume FF/GG/FG + surface _n/_Dn
[b_coord, det] = zef_volume_barycentric(nodes, tetra, p_ind, []);
W = zef_barycentric_weighting();
M = zef_volume_scalar_matrix_FF(nodes, tetra, ...);  % see file headers for args
```

## Important notes

- Gradients from `zef_volume_barycentric` already include the 1/V factor; GG weighting is therefore `1`.
- Do not redirect EEG stiffness through this folder without an explicit design change and tests.

## Developer guidance

- New integral: add a named `zef_volume_scalar_matrix_*` (or surface twin), document the letter code here, and wire it through `zef_nse_matrices` / Poisson.
- Keep `zef_3by3_solver` numerically stable — meshing and intersection tests depend on it.
- Pitfall: assuming these matrices are what `zef_stiffness_matrix` uses for EEG.
