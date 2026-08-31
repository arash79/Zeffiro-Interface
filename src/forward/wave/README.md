# src/forward/wave

## Folder purpose

Time-domain electromagnetic **wave FEM** used by the asteroid **radar** / GPU-ToRRe-3D style pipeline. Assembles system matrices, leap-frog time steps, Born approximations, and Jacobian I/O under a `torre_dir` workspace. **Does not write `zef.L`** and is not selected via `lead_field_type`.

## Main contents

| Role | Files |
|------|--------|
| System assembly | `create_system` — load mesh + permittivity, refine, assemble `C`/`A`/`R`, save mats |
| Time stepping | `compute_data`, `compute_data_gpu`, `B_prod`, `B_T_prod`, `mat_vec` |
| Sources / BC | `boundary_source`, `boundary_point_source`, `surface_integral` |
| Born / difference | `make_born_approximation_qam`, `make_born_approximation_amp`, `make_difference_data_qam`, `make_difference_data_amp` |
| Jacobian I/O | `save_jacobian_data`, `save_jacobian_data_complex`, `load_jacobian_data`, `load_jacobian_data_complex`, `combine_data_complex`, `combine_data_sincos` |
| Pulse / demod | `bh_window`, `qam_demod` |
| Wave-local mesh | `refine_mesh` (8-way split; **not** `zef_mesh_refinement`), `make_interp_mat` |

## Code functionality

Typical order:

1. `create_system` — read `torre_dir/system_data` nodes/tetra/ε `.dat`, refine, assemble, write system mats.
2. `compute_data_gpu` (or CPU wrapper) — leap-frog Maxwell-like update with curl/div products.
3. `make_born_approximation_qam` (or amp) — linearize for inverse.
4. `save_jacobian_data` — persist Jacobians / time series for radar inverse.

Parameters often come from a local `parameters.m` / profile asteroid radar settings, not from `zef.lead_field_type`.

## Workflow context

| Path | Relationship |
|------|----------------|
| `src/forward/lead_field` | Head EEG/MEG/EIT/TES → `zef.L` |
| `profile/asteroid_radar` | Menus / INI for radar studies |
| `data/itokawa_model`, example asteroid projects | Geometry demos |
| Head inverse (`+inverse`, plugins) | Does **not** consume wave Jacobians as `zef.L` |

## Usage instructions

```matlab
% From a prepared torre_dir / asteroid radar session (see profile docs):
create_system;
compute_data_gpu;
make_born_approximation_qam;
save_jacobian_data;
```

Exact working directory and `parameters.m` layout follow the asteroid radar study setup — do not expect head-project `zef.L` afterward.

## Important notes

- Mesh refine here is wave-local; do not confuse with `src/mesh/zef_mesh_refinement`.
- GPU path expects Parallel Computing / CUDA availability when `compute_data_gpu` is used.
- Outputs live under `torre_dir`, not necessarily as `zef.reconstruction`.

## Developer guidance

- Keep wave numerics isolated from quasi-static lead-field FEM; share only generic linear-algebra helpers if needed.
- When changing Born / QAM demod, update save/load pairs together.
- Pitfall: running wave scripts inside a multicompartment head session and looking for `zef.L`.
