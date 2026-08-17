# FindSyntheticGravityData / m

## Folder purpose

MATLAB files for **Find synthetic gravity data**: open the GUIDE tool, sync ROI widgets, run the volume integral into `zef.measurements`, and plot ROIs.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_find_synthetic_gravity_data.m` | script | Open `fig/find_synthetic_gravity_data.fig`, init widgets |
| `zef_init_find_synthetic_gravity_data.m` | script | Copy `inv_roi_sphere` / `inv_roi_perturbation` onto widgets |
| `zef_update_find_synthetic_gravity_data.m` | script | Widgets → `zef` |
| `zef_synthetic_gravity_data.m` | script | Calls the volume integral, writes `zef.measurements` |
| `compute_gravity_data.m` | function **`zef_compute_gravity_data`** | Density + ROI perturbation, kernels by `imaging_method` 1–4, scale by G |
| `zef_plot_gravity_roi.m` | function | Plot ROI spheres |

## Code functionality

- Start/init/update manage GUIDE widgets and `zef.inv_roi_*`.
- `zef_synthetic_gravity_data` delegates to `zef_compute_gravity_data`.
- Filename is `compute_gravity_data.m` but the function name is `zef_compute_gravity_data` — callers use the function name (file must be on the path).

## Workflow context

Not on any default INI. Parent overview: [`../README.md`](../README.md). GUIDE layout: [`../fig/README.md`](../fig/README.md).

## Usage instructions

```matlab
zef_find_synthetic_gravity_data;
zef_synthetic_gravity_data;
zef_plot_gravity_roi;
```

## Important notes

- MATLAB resolves the function by name `zef_compute_gravity_data`; do not rename without updating callers.
- Requires mesh density `zef.rho` and sensors; not `zef.L`-based.

## Developer guidance

Document kernel choices for `imaging_method` 1–4 next to `zef_compute_gravity_data`. Prefer keeping filename/function naming quirks unchanged unless all callers are updated together.
