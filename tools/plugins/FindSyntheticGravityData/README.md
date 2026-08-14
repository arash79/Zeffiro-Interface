# Find synthetic gravity data

Synthesizes gravity (or related potential) measurements from tetrahedral density `zef.rho` plus spherical ROI density perturbations. Writes **`zef.measurements`**. This is a gravity/EIT-style volume integral (`zef_compute_gravity_data`), not an EEG dipole through `zef.L`.

**Not in the default profile INI** (nor in `asteroid_gravity` despite the name). Call the start script from MATLAB.

## How to open it

```matlab
zef_find_synthetic_gravity_data;   % script; uses base-workspace zef
```

Opens GUIDE figure `fig/find_synthetic_gravity_data.fig`, title **ZEFFIRO Interface: Find Synthetic Gravity Data**. Init copies `zef.inv_roi_sphere` (xyz + radius) and `zef.inv_roi_perturbation` onto the widgets.

Need `zef.nodes`, `zef.tetra`, `zef.rho`, `zef.sensors`, `zef.brain_ind`, `zef.imaging_method` in 1–4. Subtracts `zef.inv_bg_data` and adds `zef.inv_eit_noise * randn`. Scales by `6.67408E-11` (G).

## Buttons

GUIDE widgets stacked on open: ROI sphere coords, perturbation, **Compute data** (`h_inv_compute_data`), **Plot ROI** (`h_inv_plot_roi`). Callbacks live in the `.fig`. Matching algorithms: `zef_synthetic_gravity_data` (writes `zef.measurements`) and `zef_plot_gravity_roi`.

`imaging_method` 1–4 pick different kernels (directed vs scalar, 1/r² vs 1/r³).

## Scripting

```matlab
zef_synthetic_gravity_data;   % script; zef.measurements = zef_compute_gravity_data(...)
```
