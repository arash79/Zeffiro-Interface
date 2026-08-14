# IASInversion / m

MATLAB for IAS MAP: `ias_map_estimation` opens the window; `zef_ias_iteration` is the solver. User manual: parent README.

This folder does **not** construct `inverse.IASInverter`.

## Internals

| File | Role |
|------|------|
| `ias_map_estimation.m` | INI callback |
| `zef_init_ias.m` | Window, defaults, **live** Start → `zef_ias_iteration` |
| `zef_ias_map_estimation_window.m` | GUIDE dump |
| `zef_update_ias.m` | Widgets → `ias_*` |
| `zef_ias_iteration.m` | Solver |

## Unpatched (filename ≠ function)

- File `zef_ias_map_estimation_window.m` declares `ias_map_estimation_window`. MATLAB calls the filename.
- Dump Start is `zef.reconstruction = zef_ias_iteration(zef)` (no `reconstruction_information`). Init overrides both outputs.
- In `zef_ias_iteration`, both sLORETA branches are `isequal(ias_type,2)` as written.
