# ES Workbench MATLAB (`m/`)

This folder is the **runtime** for Inverse tools → **ES Workbench** (`zef_ES_optimization` in `profile/multicompartment_head/zeffiro_plugins.ini`). It is tES **electrode-current** optimization against `zef.L` and `zef.inv_synth_source`, not MEG/EEG inverse.

| Location | Role |
|----------|------|
| `m/` (this folder) | Start, window wiring, α/ε grid, LP/QP/SDP wrappers, plots |
| `../mlapp/` | App Designer layout only (`zef_ES_optimization_app`). Buttons are bound here in `zef_ES_optimization_window` |
| `../README.md` | User manual |

## GUI vs scripting

`zef_ES_optimization` → `zef_tool_start(..., 'zef_ES_optimization_window', ...)`. That constructor instantiates the `.mlapp`, then sets:

| Handle | Callback |
|--------|----------|
| **Find currents** | confirm dialog; HPO method 1 → `zef_ES_find_currents`, 2 → `zef_ES_find_currents_recursive` |
| **Update reconstruction** | `zef_ES_update_reconstruction` then `zef_plot_meshes` |
| **Plot data** | `zef_ES_plot_data` (dispatch on `ES_plot_type`) |
| Right-click menu | current pattern, bar plot, error chart, optimizer properties, distance curves |
| Parameter table / dropdowns | `zef_ES_optimization_update` |

Scripting the optimizer (no window required after `ES_*` fields exist):

```matlab
zef = zef_ES_find_currents(zef);
zef = zef_ES_update_reconstruction(zef);
```

## Not wired from the workbench

These files exist for scripting or leftover 4×1 montage helpers. They are **not** `ButtonPushedFcn` / `MenuSelectedFcn` in `zef_ES_optimization_window`: `zef_ES_4x1_fun`, `zef_ES_plot_4x1`, `zef_ES_plot_4x1_fun`, `zef_ES_find_valid_separation_angle`, `zef_ES_score_sys`, `zef_ES_clear_plot_data`, `zef_ES_error_criteria`, `zef_ES_update_plot_data`, `zef_ES_centralize_recursive_search_window`.

`zef_cvx_quadprog.m` and `zef_cvx_semidefprog.m` are called by **filename**; the in-file `function` name is still `zef_cvx_linprog`.
