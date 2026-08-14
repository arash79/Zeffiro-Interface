# Hemodynamic NSE solvers (`src/forward/nse`)

This folder solves simplified Navier–Stokes / Poisson problems for blood pressure and flow on vessel-like submeshes of a Zeffiro FEM head. It is **not** an EEG lead-field assembler: it does not write `zef.L`. Results live on `zef.nse_field` (pressure, velocity, viscosity, capillary flow) and can later couple into conductivity via `zef_nse_sigma`.

The GUI is **Multi tools → NSE tool** (`zef_nse_tool_start` in the default profile). **Solve system** in that window runs the script `zef_nse_run_solver`, which dispatches on `zef.nse_field.solver_type`.

## Why it exists

EEG/MEG usually treat conductivity as static. Neurovascular coupling and some EIT/hemodynamic studies need a pressure-driven flow field on arteries/capillaries that were labeled as compartments in the segmentation. This folder builds those submeshes, assembles barycentric FEM matrices from `src/mesh/barycentric`, and time-steps or solves a Poisson problem for pressure.

## How a user runs it

1. Import a segmentation that includes vessel (or equivalent) compartments and build a FEM mesh.
2. Open **Multi tools → NSE tool**.
3. Set solver type, pulse amplitude, viscosity, which domain labels are arteries vs capillaries (`nse_field` fields; the tool window copies widgets into `zef.nse_field` via `zef_nse_tool_update`).
4. Click the tool’s **Solve system** control (bound to `zef_nse_run_solver`).
5. Inspect `zef.nse_field.bp_vessels`, `bv_vessels_*`, `bf_capillaries`. Optional: `zef_nse_sigma` to push flow-dependent conductivity back onto `zef.sigma`.

Requires `zef.nodes`, `zef.tetra`, `zef.domain_labels`, and `zef.mvd_length` (microvessel density per tet; first column used, scaled ×1e6 in the Poisson solver).

## Solver types (`zef_nse_run_solver`)

| `solver_type` | Call |
|---------------|------|
| 1 | `zef_nse_poisson`, `microcirculation_model = 0` |
| 2 | `zef_nse_poisson`, `microcirculation_model = 1` |
| 3 | `zef_nse_haemodynamic_response_solver` (lives in `tools/plugins/NSE_tool`, not this folder), `nse_type = 2`, microcirculation on |
| 4–7 | `zef_nse_poisson_dynamic` with combinations of `nse_type` 1/2 and microcirculation 0/1 |

Always calls `zef_nse_tool_update` first so widget values are on `nse_field`.

## Scripting

```matlab
zef = zef_nse_tool_update(zef);   % or set nse_field fields yourself
zef.nse_field.solver_type = 1;
zef.nse_field.microcirculation_model = 0;
zef.nse_field = zef_nse_poisson(zef.nse_field, zef.nodes, zef.tetra, ...
    zef.domain_labels, zef.mvd_length);
```

Coordinates: `zef_nse_poisson` converts `nodes` millimetres → metres (`×0.001`) internally. Pulse amplitude is millimetres of mercury on `nse_field`.

## Main files

| File | Role |
|------|------|
| `zef_nse_run_solver.m` | Script: GUI dispatch |
| `zef_nse_poisson.m` | Steady pressure on artery/capillary submeshes |
| `zef_nse_poisson_dynamic.m` | Time-dependent Poisson |
| `zef_nse_iteration.m` / `zef_p_iteration.m` | Iterative pressure/velocity updates |
| `zef_nse_matrices.m` | Assemble barycentric FF/FG/GG operators |
| `zef_nse_signal_pulse.m` | Cardiac-like boundary pulse |
| `zef_nse_plot_pulse.m` | Plot that pulse |
| `zef_nse_reconstruction.m` | Map NSE fields onto `zef.reconstruction` (see types below) |
| `zef_nse_sigma.m` | Couple flow to conductivity |
| `zef_set_nse_source_space.m` | Restrict sources to NSE domains |
| `zef_get_submesh.m` | Extract a labeled tet subset |
| `zef_QinvMQ.m`, `zef_KDMD.m`, `zef_averaging_matrix.m` | Linear-algebra helpers for the dynamic schemes |
| `zef_smooth_nse_field.m`, `zef_nse_threshold_distribution.m` | Post-smooth / threshold |

Barycentric matrices: `src/mesh/barycentric/README.md`. Plugin window: `tools/plugins/NSE_tool/`.

## Parse reconstruction (NSE tool)

The tool dropdown **reconstruction type** (`h_reconstruction_type.Items` in `zef_nse_tool_window.m`) is 1-based and is passed to `zef_nse_reconstruction`. **Parse reconstruction** also copies `nse_field.inv_time_*` onto `zef.inv_time_*` so the Figure tool’s time sliders match the NSE frames.

| Value | Label in the tool | Source fields |
|-------|-------------------|---------------|
| 1–5 | Pressure / velocity / viscosity (arteries); concentration / deoxygenized Hb (microcirculation) | one cell per time frame |
| 6–8 | Mean / max / STD pressure (arteries) | collapsed to `reconstruction{1}` |
| 9–11 | Mean / max / STD velocity | `bv_vessels_1/2/3` |
| 12–14 | Mean / max / STD viscosity | `mu_vessels` |
| 15–17 | Mean / max / STD concentration (microcirculation) | `bf_capillaries`, values clamped to `[0,1]` |

Types 1–3, 6–14 are the artery list (`reconstruction_type_list{1}`); 4–5, 15–17 are microcirculation (`list{2}`). **Interpolate** (`zef_nse_interpolate`) uses that split to set source flags before `zef_source_interpolation`.

Each vector is stored as an xyz triplet scaled by \(1/\sqrt{3}\) so the Figure tool’s magnitude colormap matches a scalar field. Frames are quantile-clipped with `nse_field.min/max_reconstruction_quantile`.

Type 8 (STD pressure) assigns `aux_vec` with a comma expression that does **not** call `zef_nse_threshold_distribution` (as written). Type 17 divides the running mean by `size(bp_vessels,2)` rather than `bf_capillaries`. Both are documented from the implementation; they are not patched here.

## See also

- `src/forward/README.md` — NSE is a sibling of lead-field FEM, not a substitute
- Profile `multicompartment_head_nse` if you need NSE-oriented defaults
