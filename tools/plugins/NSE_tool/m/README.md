# tools/plugins/NSE_tool/m

## Folder purpose

GUI and plugin-local helpers for hemodynamic / NSE vessel flow (**Multi tools → NSE tool**, profile `multicompartment_head_nse`). Most PDE solvers live in `src/forward/nse`; this folder owns the window wiring, ROI/plot helpers, and **solver_type 3** (haemodynamic response + balloon), which is **not** under `src/forward/nse`.

## Main contents

| Group | Files |
|-------|--------|
| Start / UI | `zef_nse_tool_start`, `zef_nse_tool_window`, `zef_nse_tool_init`, `zef_nse_tool_update` |
| Type-3 solvers | `zef_nse_haemodynamic_response_solver`, `zef_nse_balloon_model_solver`, `zef_nse_mollifier` |
| ROI / sources | `zef_nse_apply_roi`, `zef_nse_apply_source`, `zef_nse_apply_nvc`, `zef_nse_dir_v_node`, `zef_nse_roi_ind`, `zef_nse_vel_dir`, `zef_nse_mean_velocity_roi`, `zef_nse_separate_waves_roi` |
| Plots / post | `zef_nse_plot_*`, `zef_nse_calculate_perfusion`, `zef_nse_interpolate` |

Apps: `../mlapp/zef_nse_app.mlapp` (and twin export if present).

## Code functionality

**Solve system** → `zef_nse_run_solver` (`src/forward/nse`):

| Type | Where |
|------|--------|
| 1–2 | `zef_nse_poisson` (± microcirculation) |
| 3 | **`zef_nse_haemodynamic_response_solver` (this folder)** + balloon |
| 4–7 | `zef_nse_poisson_dynamic` |

Also calls forward helpers: `zef_nse_reconstruction`, `zef_nse_sigma`, matrices/iteration/pulse. FE products: `src/mesh/barycentric` via `zef_nse_matrices`.

## Workflow context

```
NSE profile + vessel mesh → NSE_tool UI → Solve
  → src/forward/nse (1–2,4–7) or plugin type 3
  → nse_field / optional sigma / perfusion plots
```

Does **not** build `zef.L`.

## Usage instructions

```matlab
zef_nse_tool_start;
% Set domains, pulse, solver_type → Solve
% Then Parse reconstruction / Interpolate / NSE sigma / graphs
```

## Important notes

- Needs `nodes`, `tetra`, `domain_labels`, `mvd_length`.
- mm→m scaling inside solvers.
- Balloon assumes \(a^2 > 4b\).
- GUI labels for types 4–7 may say Stokes/NS while code uses `zef_nse_poisson_dynamic`.

## Developer guidance

- Keep haemodynamic-only math in this plugin; keep shared Poisson/NS in `src/forward/nse`.
- Extend ROI metrics here and wire buttons in `zef_nse_tool_window`.
- Pitfall: expecting NSE Solve to produce EEG lead fields.
