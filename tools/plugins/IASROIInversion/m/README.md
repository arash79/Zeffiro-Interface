# IASROIInversion / m

MATLAB for IAS ROI: `ias_map_estimation_roi` opens the window; `zef_ias_iteration_roi` is the solver on disk. User manual: parent README (Start callback name mismatch is documented there).

There is **no** `inverse.*Inverter` for this ROI variant.

## Internals

| File | Role |
|------|------|
| `ias_map_estimation_roi.m` | INI callback |
| `zef_init_ias_roi.m` | Window + defaults; does **not** rebind Start |
| `zef_ias_map_estimation_roi_window.m` | GUIDE dump with live Start string |
| `zef_update_ias_roi.m` / `zef_switch_roi_mode.m` | Widgets / enable |
| `zef_iasroi_plot_roi.m` | Plot Sphere(s) |
| `zef_ias_iteration_roi.m` | Solver on disk |

## Unpatched (filename ≠ function / Start)

- File `ias_map_estimation_roi.m` declares `function zef = ias_map_estimation(zef)` (same name as the non-ROI start). INI calls the **filename** `ias_map_estimation_roi`.
- Live Start: `[zef.reconstruction, zef.iasroi_rec_source] = ias_iteration_roi([]);` — there is no `ias_iteration_roi.m`; the solver is `zef_ias_iteration_roi`. Init does not override this string.
- `zef_iasroi_plot_roi` with no args uses `eval('base','zef')` as written (not `evalin`).
