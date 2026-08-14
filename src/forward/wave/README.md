# Wave / GPU-ToRRe (`src/forward/wave`)

Time-domain electromagnetic wave FEM used for radar-style asteroid imaging (GPU-ToRRe-3D), not for EEG lead fields. These scripts **do not write `zef.L`**. They load nodes/tetra/permittivity from a `torre_dir/system_data` folder, assemble mass/stiffness/damping, leap-frog the fields, and save Jacobians for inverse scattering.

You normally reach this from an **asteroid_radar** (or similar) profile and the associated plugin/scripts, not from the default head Mesh tool **Run script** table.

## What problem it solves

Given a tetrahedral mesh of an asteroid (domain 1) and an orbit/background (domain 2), plus complex relative permittivity, the code builds sparse `C` (mass), `A` (stiffness-like), and `R` (damping), then propagates a pulse (`bh_window` / `mh_window`) from boundary sources. Born and QAM difference-data drivers produce the Jacobian used by radar inverse problems.

## Entry points (scripts)

| Script | Role |
|--------|------|
| `create_system.m` | Load mesh + permittivity, optional `refine_mesh`, assemble `C`,`A`,`R`, save `system_data_*.mat` |
| `compute_data.m` / `compute_data_gpu.m` | Time-step the system (CPU / GPU) |
| `make_born_approximation_amp.m` / `_qam.m` | Born linearization |
| `make_difference_data_amp.m` / `_qam.m` | Difference data for inversion |
| `load_jacobian_data.m` / `save_jacobian_data.m` | Jacobian I/O (real and `*_complex`) |

They expect `parameters.m` and `torre_dir` on the path (`system_setting_index`, `n_refinement`, `signal_center_frequency`). Mesh files are `nodes_*.dat`, `tetrahedra_*.dat`, `real_relative_permittivity_*.dat`, `imaginary_relative_permittivity_*.dat`.

`compute_data_gpu` leap-frog (per `process_id` source): pulse window on orbit nodes → `pcg_iteration_gpu` on lumped mass `C` for \(\partial u/\partial t\) → update electric `u` → `B_prod` curl into magnetic `p_1,p_2,p_3`, with PML damping on `I_u` / `I_p_*`. Samples every `data_param` steps. CPU twin: `compute_data.m`.

## Operators

- `B_prod.m` / `B_T_prod.m` — discrete curl/div-style products used in the leap-frog update
- `mat_vec.m` — sparse matvec
- `surface_integral.m`, `free_boundary.m`, `boundary_source.m`, `boundary_point_source.m`
- `refine_mesh.m` — 4-to-1 tet split local to this module (not `zef_mesh_refinement`)
- `tetra_in_compartment.m` — domain subset (wave copy; head meshing uses `src/compartments`)
- `qam_demod.m`, `calc_cf_and_bw.m`, `array_min.m` — signal-side helpers

## Relation to the rest of Zeffiro

Head EEG/MEG/EIT/TES live in `src/forward/lead_field`. Gravity asteroid work is a different modality (`zef_lead_field_matrix_gravity`). This folder is the radar/wave PDE. Do not call `create_system` expecting it to fill `zef.nodes` for a head project.

## See also

- Profiles: `profile/asteroid_radar/`
- Upstream GPU-ToRRe-3D: copyright on these files points at that project
- Mesh refinement used by the head pipeline: `src/mesh/README.md`
