# NSE tool

Opens a window for hemodynamic Poisson / Navier–Stokes-style solves on vessel compartments of the current FEM mesh. It does **not** compute an EEG lead field. Results are stored on `zef.nse_field`. The PDE lives in `src/forward/nse/`; this plugin is the UI.

## How to open it

**Multi tools → NSE tool** (default profile). Callback: `zef_nse_tool_start` → `zef_tool_start(..., 'zef_nse_tool_window', ...)`.

Need `zef.nodes`, `zef.tetra`, `zef.domain_labels`, and `zef.mvd_length` (microvessel density).

## Solve

The window copies widgets into `zef.nse_field` (`zef_nse_tool_update`). **Solve system** (`h_solve_system`) runs the script `zef_nse_run_solver`, which switches on `nse_field.solver_type`:

- 1–2: steady `zef_nse_poisson` (microcirculation off/on)
- 3: `zef_nse_haemodynamic_response_solver` (in this plugin, not `src/forward/nse`)
- 4–7: `zef_nse_poisson_dynamic` with `nse_type` 1/2 × microcirculation 0/1

Outputs: `nse_field.bp_vessels`, `bv_vessels_1/2/3`, `mu_vessels`, `bf_capillaries`. Optional conductivity coupling: `zef_nse_sigma`.

**Parse reconstruction** copies the selected dropdown type (1–17: artery pressure/velocity/viscosity and microcirculation concentration, plus mean/max/STD collapses) into `zef.reconstruction` via `zef_nse_reconstruction`, and copies `nse_field.inv_time_*` onto `zef.inv_time_*`. Type table: `src/forward/nse/README.md`. **Interpolate** (`zef_nse_interpolate`) sets source flags from artery vs microcirculation type lists, then `zef_source_interpolation`.

## Scripting

```matlab
zef = zef_nse_tool_update(zef);
zef.nse_field.solver_type = 1;
zef_nse_run_solver;   % script; uses/assigns base-workspace zef
```

Or call `zef_nse_poisson` directly (see `src/forward/nse/README.md`). Nodes are converted mm→m inside the Poisson solver.

## Layout

- `m/zef_nse_tool_start.m`, `m/zef_nse_tool_window.m`, update helpers
- `m/zef_nse_haemodynamic_response_solver.m` — solver_type 3 only
- `mlapp/` — App Designer layout; not the algorithm

Profile `multicompartment_head_nse` has NSE-oriented defaults. Details of matrices and pulse BCs: `src/forward/nse/README.md`.
