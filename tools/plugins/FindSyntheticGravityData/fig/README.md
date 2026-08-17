# FindSyntheticGravityData — GUIDE layout (`fig/`)

## Folder purpose

Stores the legacy GUIDE window for the **Find Synthetic Gravity Data** plugin. That plugin synthesizes gravity (or related potential) sensor readings from tetrahedral density `zef.rho` plus spherical ROI density perturbations, and writes **`zef.measurements`**. It is a volume-integral forward helper for asteroid / gravity workflows, not an EEG/MEG lead-field product through `zef.L`.

## Main contents

| File | Role |
|------|------|
| `find_synthetic_gravity_data.fig` | GUIDE figure opened by the start script |
| `README.md` | This documentation |

Sibling MATLAB lives under `../m/` (`zef_find_synthetic_gravity_data`, init/update, `zef_synthetic_gravity_data` → `zef_compute_gravity_data`, `zef_plot_gravity_roi`).

## Code functionality

The start script loads this `.fig` with `open(...)`, assigns `zef.h_find_synthetic_gravity_data`, then runs `zef_init_find_synthetic_gravity_data` so ROI sphere / perturbation / Compute / Plot widgets bind into `zef.h_*`. Window title after open: **ZEFFIRO Interface: Find Synthetic Gravity Data**. Compute path writes measurements via density kernels selected by `zef.imaging_method` (1–4), not via `L × source`.

## Workflow context

Parent plugin: `tools/plugins/FindSyntheticGravityData`. Used for gravity/asteroid synthetic data preparation before inversion. **Not** registered in the default profile INI (and typically not on asteroid menus either despite the gravity name). Related profiles: `profile/asteroid_gravity`, `profile/asteroid_radar`. Companion code expects `nodes`, `tetra`, `rho`, `sensors`, and `imaging_method` in 1–4.

## Usage instructions

From MATLAB (base-workspace `zef`):

```matlab
zef_find_synthetic_gravity_data;   % open('find_synthetic_gravity_data.fig') + init
zef_synthetic_gravity_data;        % compute → zef.measurements
```

Edit the layout only with GUIDE / `openfig` workflows. Keep widget tags stable for `zef_init_find_synthetic_gravity_data` / `zef_update_find_synthetic_gravity_data` `findobj` lookups.

## Important notes

- Real figure file name: **`find_synthetic_gravity_data.fig`**.
- Start script that opens it: **`zef_find_synthetic_gravity_data`** (`../m/zef_find_synthetic_gravity_data.m`).
- Parent plugin purpose: synthesize gravity measurements from density + ROI perturbation into `zef.measurements`.
- GUIDE is deprecated; do not add new GUIDE UIs here.
- Not an `L × source` forward; gravity kernels use `G` scaling and `imaging_method` tables in `zef_compute_gravity_data`.

## Developer guidance

- Prefer App Designer under a sibling `mlapp/` if this tool is revived for menus.
- When porting, preserve `zef.inv_roi_sphere`, `zef.inv_roi_perturbation`, and measurement-write semantics so scripts that call `zef_synthetic_gravity_data` keep working.
- Document any `imaging_method` kernel changes in the parent `../README.md` and `../m/README.md`.
