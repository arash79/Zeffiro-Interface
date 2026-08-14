# Find synthetic gravity data — MATLAB files (`m/`)

Not on any default INI. Start: `zef_find_synthetic_gravity_data`. Volume integral → `zef.measurements`: parent [../README.md](../README.md).

| File | Kind | Role |
|------|------|------|
| `zef_find_synthetic_gravity_data.m` | **script** | Open `fig/find_synthetic_gravity_data.fig`, init widgets. |
| `zef_init_find_synthetic_gravity_data.m` | **script** | Copy `inv_roi_sphere` / `inv_roi_perturbation` onto widgets. |
| `zef_update_find_synthetic_gravity_data.m` | **script** | Widgets → `zef`. |
| `zef_synthetic_gravity_data.m` | **script** | Calls the volume integral, writes `zef.measurements`. |
| `compute_gravity_data.m` | function **`zef_compute_gravity_data`** | Density + ROI perturbation, kernels by `imaging_method` 1–4, scale by G. MATLAB calls it by **filename** only if you `run` the file; callers use the function name `zef_compute_gravity_data` (must be on the path as this file). |
| `zef_plot_gravity_roi.m` | plot ROI spheres | |

GUIDE layout: [../fig/README.md](../fig/README.md).
