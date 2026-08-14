# Topography tool — MATLAB files (`m/`)

Sensor-space map on the outer surface. Menu, **Start** / **Apply**, and `zef.top_reconstruction`: parent [../README.md](../README.md).

| File | Kind | Role |
|------|------|------|
| `zef_topography.m` | start | INI callback **Forward tools → Topography tool**. |
| `zef_topography_app.m` | widgets | Window title **ZEFFIRO Interface: Topography tool**; button Callbacks. |
| `zef_init_topography.m` | **script** | Default `top_*` from inverse `inv_*` (band, times, `top_regularization_parameter = 5`). |
| `zef_update_topography.m` | **script** | Copy widgets onto `zef.top_*` **and** onto `zef.inv_*` / `number_of_frames` / `normalize_data`. |
| `zef_evaluate_topography.m` | function | Inverse-distance sum on `reuna_p{end-1}` (scalp; last entry is usually the bounding box) → `top_reconstruction`. L∞-normalizes across frames. |

`fig/` is unused leftover layout, not the live window.
