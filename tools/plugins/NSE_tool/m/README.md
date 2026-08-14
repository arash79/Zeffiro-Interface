# NSE tool MATLAB (`m/`)

This folder is the **UI and plugin-only solver** for Multi tools → **NSE tool** (`zef_nse_tool_start` in `profile/multicompartment_head/zeffiro_plugins.ini`). Hemodynamic Poisson / Navier–Stokes-style solves on vessel compartments. Results live on `zef.nse_field`. **Does not write `zef.L`.**

| Location | Role |
|----------|------|
| `m/` (this folder) | Window, widget copy, plot/ROI helpers, **solver_type 3** (`zef_nse_haemodynamic_response_solver`) |
| `../mlapp/` | App Designer layout (`zef_nse_app`). Buttons are bound here in `zef_nse_tool_window` |
| `src/forward/nse/` | PDE for solver types 1–2 and 4–7 (`zef_nse_poisson`, `zef_nse_poisson_dynamic`, `zef_nse_run_solver`) |
| `../README.md` | User manual |

## GUI vs scripting

`zef_nse_tool_start` → `zef_tool_start(..., 'zef_nse_tool_window', ...)`. Widgets copy into `zef.nse_field` via `zef_nse_tool_update`.

| Handle | Callback |
|--------|----------|
| **Solve system** | script `zef_nse_run_solver` (in `src/forward/nse/`) |
| **Parse reconstruction** | `zef_nse_reconstruction` (src) → `zef.reconstruction` |
| **Interpolate** | `zef_nse_interpolate` then `zef_source_interpolation` |
| **NSE σ** | `zef_nse_sigma` (src) → `zef.nse_sigma` |
| Plot sphere / ROI / graph | `zef_nse_plot_sphere`, `zef_nse_plot_roi`, `zef_nse_plot_graph` |
| Apply ROI / source / dir_v | DataTips → `roi_*` / `sphere_*` / `dir_v_*` |

`zef_nse_run_solver` always calls `zef_nse_tool_update` first. For **solver_type 3** it calls `zef_nse_haemodynamic_response_solver` **in this plugin**, not a file under `src/forward/nse`.

```matlab
zef = zef_nse_tool_update(zef);
zef.nse_field.solver_type = 1;
zef_nse_run_solver;   % script; uses/assigns base-workspace zef
```

## Not wired from the window

`zef_nse_apply_nvc_source` is the same DataTip pattern as apply-source but is **not** a `ButtonPushedFcn` in `zef_nse_tool_window`. Balloon / mollifier helpers are used from solver_type 3, not from buttons.
