# Stiffness operator (`src/mesh/operators`)

One file: `zef_stiffness_matrix.m`. This is the sparse P1 conductivity matrix used by EEG/MEG/EIT/TES lead fields.

```
A_ij = ∫ ∇ψ_i · (σ ∇ψ_j) dV
```

Pipeline: [`src/mesh/README.md`](../README.md). NSE mass/Laplacian products live in [`barycentric/`](../barycentric/README.md), not here.

## Why every entry is divided by 9V

`zef_volume_gradient(nodes, tetra, i)` returns the signed **area vector** of the face opposite local vertex i (½ e1×e2, oriented toward that vertex). It is **not** ∇ψ_i.

For linear hats, ∇ψ_i = area_i / (3V). Two gradients and the remaining volume in the integral give

```
∫ ∇ψ_i · (σ ∇ψ_j) dV = (area_i · σ area_j) / (9V)
```

That is the `./ (9 * volume)` in the assembler. Contrast `zef_tetra_gradient_field`, which *does* divide by volume and maps nodal potential → σ∇u (TES), not this matrix.

`volume` must come from `zef_tetra_volume(..., true)` in the same length unit as `nodes` (metres on the lead-field path).

## Packed σ (6×T)

| Row | Entry |
|-----|--------|
| 1–3 | σ_xx, σ_yy, σ_zz |
| 4–6 | σ_xy, σ_xz, σ_yz |

Isotropic tissue repeats the scalar on rows 1–3 and leaves 4–6 zero. Off-diagonal rows add both g_i(a)g_j(b) and g_i(b)g_j(a).

## Assembly

Local vertices i ≤ j: `sparse(tetrahedra(:,i), tetrahedra(:,j), entry_vec', N, N)`. Off-diagonals add A_part + A_part'. Side effect: waitbar (closed by `onCleanup`).

Callers: `zef_lead_field_eeg_fem` and the other `src/forward/lead_field` assemblers, after electrode coupling in `zef_build_electrodes`.
