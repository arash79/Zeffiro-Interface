# tools/plugins/FindSyntheticGravityData

## Folder purpose

Synthesizes gravity (or related potential) measurements from tetrahedral density `zef.rho` plus spherical ROI density perturbations. Writes **`zef.measurements`**. Volume integral (`zef_compute_gravity_data`), not an EEG dipole through `zef.L`.

## Main contents

| Path | Role |
|------|------|
| `m/zef_find_synthetic_gravity_data.m` | Open GUIDE fig; init widgets |
| `m/zef_synthetic_gravity_data.m` | Calls volume integral → `zef.measurements` |
| `m/compute_gravity_data.m` | Function `zef_compute_gravity_data` (kernels by `imaging_method`) |
| `m/zef_plot_gravity_roi.m` | Plot ROI spheres |
| `m/zef_init_*` / `zef_update_*` | Widget ↔ `zef` |
| `fig/find_synthetic_gravity_data.fig` | GUIDE layout |

## Code functionality

- Init copies `zef.inv_roi_sphere` (xyz + radius) and `zef.inv_roi_perturbation` onto widgets.
- Compute: density + ROI perturbation, subtract `zef.inv_bg_data`, add `zef.inv_eit_noise * randn`, scale by `6.67408E-11` (G).
- `imaging_method` 1–4 pick kernels (directed vs scalar, 1/r² vs 1/r³).

## Workflow context

Gravity/asteroid synthetic data. **Not** in the default profile INI (nor in `asteroid_gravity` despite the name). Related profiles: `profile/asteroid_gravity`, `profile/asteroid_radar`.

## Usage instructions

```matlab
zef_find_synthetic_gravity_data;   % script; uses base-workspace zef
% Title: ZEFFIRO Interface: Find Synthetic Gravity Data
zef_synthetic_gravity_data;        % zef.measurements = zef_compute_gravity_data(...)
```

Need `zef.nodes`, `zef.tetra`, `zef.rho`, `zef.sensors`, `zef.brain_ind`, `zef.imaging_method` in 1–4. Widgets: ROI sphere, perturbation, **Compute data**, **Plot ROI**.

## Important notes

- GUIDE callbacks live in the `.fig`.
- Not an `L × source` forward product.

## Developer guidance

Detail for MATLAB files: [`m/README.md`](m/README.md). Keep `imaging_method` kernel table documented when changing `zef_compute_gravity_data`.
