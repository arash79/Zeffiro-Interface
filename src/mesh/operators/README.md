# Stiffness operator (`src/mesh/operators`)

## Folder purpose

Holds the sparse **P1 conductivity stiffness matrix** used by EEG/MEG/EIT/TES lead-field assemblers:

```
A_ij = ∫ ∇ψ_i · (σ ∇ψ_j) dV
```

NSE mass/Laplacian products live in `../barycentric/`, not here.

## Main contents

| File | Role |
|------|------|
| `zef_stiffness_matrix.m` | Assemble `A` from `nodes`, `tetra`, packed conductivity `σ` (6×T) |

## Code functionality

`zef_volume_gradient` returns signed **area vectors** (not ∇ψ). With ∇ψ_i = area_i / (3V),

```
∫ ∇ψ_i · (σ ∇ψ_j) dV = (area_i · σ area_j) / (9V)
```

hence the `./ (9 * volume)` factor. Volumes from `zef_tetra_volume(..., true)` in the same length unit as `nodes` (metres on the lead-field path).

**Packed σ rows:** 1–3 diagonal σ_xx/yy/zz; 4–6 σ_xy/xz/yz. Isotropic tissue repeats the scalar on 1–3 and zeros 4–6.

Assembly: local vertices i ≤ j into `sparse(...)`; off-diagonals add `A_part + A_part'`. Shows a waitbar (cleaned with `onCleanup`).

## Workflow context

```
zef_build_electrodes → zef_stiffness_matrix → zef_transfer_matrix (PCG) → lead_field_*_fem → zef.L
```

Callers: `zef_lead_field_eeg_fem` and other `src/forward/lead_field` assemblers.

## Usage instructions

Not usually called alone. Prefer modality `make_all` / `zef_lead_field_matrix`. Direct use:

```matlab
A = zef_stiffness_matrix(nodes, tetra, sigma_packed);
```

## Important notes

- Do not confuse with `zef_tetra_gradient_field` (maps nodal potential → σ∇u for TES).
- Anisotropic DTI tensors must stay SPD or assembly/solves fail.
- Length-unit consistency between mesh and σ is critical.

## Developer guidance

- Changing the 9V factor requires updating both this file and any analytic tests.
- Keep waitbar non-blocking for cluster/nodisplay when possible.
- Document σ packing next to DTI writers when the layout changes.
