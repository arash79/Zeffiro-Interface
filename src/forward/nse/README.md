# Hemodynamic NSE solvers (`src/forward/nse`)

## Folder purpose

Solve simplified **Navier–Stokes / Poisson hemodynamic** problems on vessel-like FEM submeshes. Results live on `zef.nse_field` (pressure, velocity, viscosity, capillary flow). **Does not write `zef.L`.** Optional conductivity coupling via `zef_nse_sigma`. GUI lives in `tools/plugins/NSE_tool`; FE products come from `src/mesh/barycentric`.

## Main contents

| File | Role |
|------|------|
| `zef_nse_run_solver.m` | **Script** GUI entry; dispatches on `nse_field.solver_type` |
| `zef_nse_poisson.m` | Steady Poisson → `bp_vessels`, `bv_vessels_*`, `mu_vessels`, `bf_capillaries` |
| `zef_nse_poisson_dynamic.m` | Time-dependent Poisson (types 4–7 via `nse_type` + microcirculation) |
| `zef_nse_iteration.m` | Full NS time-step: submesh → matrices → `zef_QinvMQ` / PCG |
| `zef_p_iteration.m` | Nearest-node sources variant; **function line may still be named `zef_nse_iteration`** |
| `zef_nse_matrices.m` | Assemble `M`, `L_ij`, `Q_i`, `F`, surface `B*` via barycentric |
| `zef_QinvMQ.m` | Matrix-free `Q⁻¹ M Q⁻¹` for PCG |
| `zef_KDMD.m` | Matrix-free `(K + D M D)x` (**not** dynamic-mode decomposition) |
| `zef_averaging_matrix.m` | Tetra→node smoother weights |
| `zef_get_submesh.m` | Extract/relabel tet subset |
| `zef_smooth_nse_field.m` | Smooth `u_*` / `p` (or vessel cells) |
| `zef_set_nse_source_space.m` | `source_positions` ← NSE nodes + `zef_source_interpolation` |
| `zef_nse_sigma.m` | Capillary/vessel state → conductivity columns |
| `zef_nse_reconstruction.m` | Pack vessel fields → inverse-style `reconstruction` cells (types 1–17) |
| `zef_nse_threshold_distribution.m` | Quantile clamp for visualization |
| `zef_nse_signal_pulse.m` | Blackman–Harris P/T/D pulse (Pa) |
| `zef_nse_plot_pulse.m` | Plot pulse on `zef.h_axes1` |

PCG kernels: `src/forward/pcg_iteration*.m`. Haemodynamic type **3** solver: `tools/plugins/NSE_tool` (`zef_nse_haemodynamic_response_solver`), not this folder.

## Code functionality

`zef_nse_run_solver` always runs `zef_nse_tool_update` first. Requires `zef.nodes`, `zef.tetra`, `zef.domain_labels`, `zef.mvd_length`.

| `solver_type` | Call | Flags |
|---------------|------|-------|
| 1 | `zef_nse_poisson` | `microcirculation_model=0` |
| 2 | `zef_nse_poisson` | `microcirculation_model=1` |
| 3 | `zef_nse_haemodynamic_response_solver` (plugin) | `nse_type=2`, micro=1 |
| 4–7 | `zef_nse_poisson_dynamic` | combinations of `nse_type` 1/2 × micro 0/1 |

GUI labels may say “Dynamic Stokes / Navier–Stokes” while the code path for 4–7 remains `zef_nse_poisson_dynamic`. `zef_nse_iteration` / `zef_p_iteration` are **not** in this dispatch table.

**In:** mesh + domains + `mvd_length`; pulse/domain fields on `nse_field`; iteration may need `inv_synth_source`, `active_compartment_ind`.  
**Out:** vessel cell arrays on `nse_field`; optional σ / figure-tool reconstruction packs.

## Workflow context

```
Multi tools → NSE_tool → zef_nse_tool_update → zef_nse_run_solver
  → types 1–2,4–7: this folder (+ barycentric matrices + pcg_iteration)
  → type 3: plugin haemodynamic / balloon solvers
```

Profile: typically `multicompartment_head_nse`. Independent of EEG inverse until/unless `zef_nse_sigma` updates `zef.sigma` and a lead field is recomputed.

## Usage instructions

```matlab
% Preferred: Multi tools → NSE tool → set solver_type → Solve
% Programmatic (after nse_field is populated):
zef_nse_run_solver;   % script; uses base-workspace zef
```

## Important notes

- Nodes scaled **mm→m** (`/1000`) inside solvers.
- `zef_p_iteration` filename vs internal function name mismatch — call carefully.
- `zef_nse_signal_pulse` may ignore a legacy 3rd argument.
- Reconstruction packing types 8 and 17 have documented bugs in headers — avoid those display modes or fix upstream.
- Hard-coded atmospheric / flux constants appear in iteration paths.

## Developer guidance

- New PDE variants: add here and extend `zef_nse_run_solver` + NSE_tool dropdown together.
- Keep EEG stiffness out of this folder (`src/mesh/operators`).
- Pitfall: expecting Solve to populate `zef.L` for MEG/EEG inverse.
