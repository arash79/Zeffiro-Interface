# Barycentric P1 operators (`src/mesh/barycentric`)

Sparse volume and surface matrices of products of linear hats on tetrahedra. **NSE** (`src/forward/nse`) is the live consumer. EEG/MEG/EIT stiffness does **not** use this folder — that path is `operators/zef_stiffness_matrix` (area vectors / 9V). Pipeline context: [`src/mesh/README.md`](../README.md).

## Letter table

Assemblers name integrals by concatenating symbols. `φ` is a per-tet scalar (`scalar_field`).

| Letter | Meaning |
|--------|---------|
| **F** | P1 hat ψ at a tet (or face) vertex |
| **G** | One Cartesian component of ∇ψ (from `zef_volume_barycentric` columns 1:3) |
| **D** | Same as G in the generic `*_D` / `*_DD` kernels (explicit gradient index `g_i_ind`) |
| **n** | Unit outward face normal (surface files with `n` / `Fn` / `FFn` / `FGn` / `Dn`) |
| **C** | Constant per tet (no hat; `CC` is φ × volume) |
| **u** | Extra vector field in matrix-free kernels (`uFG`, `GFu`) |

Weights from `zef_barycentric_weighting` (reference tet volume 1 or triangle area 1; assemblers multiply by |V| or area):

| Type | Weights | Integral |
|------|---------|----------|
| `FF` | `[1/10 1/20]` | ∫ ψ_i ψ_j dV (diag / off) |
| `GG` | `1` | ∫ (∇ψ)_α (∇ψ)_β dV (grads already 1/V) |
| `FG` | `1/4` | ∫ ψ ∇ψ dV (mean of ψ is 1/4) |
| `uFG` | `[1/10 1/20]` | same pair as FF for the u·F·G kernel |
| `surface_FF` | `[1/6 1/12]` | ∫_Δ ψ_i ψ_j dS |
| `surface_FG` | `1/3` | ∫_Δ ψ ∇ψ dS |

Hats and ∇ψ: `zef_volume_barycentric` (batched Cramer kernel `zef_3by3_solver`). Volume V = |det|/6.

## Volume wrappers (NSE)

| Function | Integral | NSE use |
|----------|----------|---------|
| `zef_volume_scalar_matrix_FF` | φ F F | mass C, I_μ, M_2 |
| `zef_volume_scalar_matrix_GG` | φ G_α G_β | Laplacian K, L (`GG(1,1)+GG(2,2)+GG(3,3)`) |
| `zef_volume_scalar_matrix_FG` | φ F G_α | divergence blocks Q_1…Q_3 |
| `zef_volume_scalar_vector_F` | φ F | load / mean vectors |
| `zef_volume_scalar_matrix` / `_D` / `_DD` / `_CC` / `_GCC` / `_FFG` / `_Kx` / `_GFu` / `_uFG` | generic or specialised | wrappers or unused extras |

`zef_volume_scalar_diagonal_matrix` / `_FF` lump the mass onto the diagonal.

## Surface wrappers

Skin faces from `zef_surface_mesh`. Area uses (abs(det)/2)×‖∇ψ_f‖ for the hat opposite the face.

| Function | Role |
|----------|------|
| `zef_surface_scalar_matrix_FF` | Robin / surface mass M_1 |
| `zef_surface_scalar_vector_F` / `_Fn` | surface loads (with/without n) |
| `*_FG`, `*_FGn`, `*_FFn`, `*_D`, `*_DD`, `*_Dn`, `*_n` | gradient / normal variants |

## Do not confuse with stiffness

`operators/zef_stiffness_matrix` builds A_ij = ∫ ∇ψ_i · (σ ∇ψ_j) dV via `zef_volume_gradient` (signed face-area vectors) divided by **9V**. That is the EEG lead-field matrix. GG here is a P1 product with barycentric ∇ψ, used by NSE, not a drop-in replacement for A.
