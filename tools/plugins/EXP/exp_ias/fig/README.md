# EXP IAS (single-resolution) — GUIDE layout (`fig/`)

## Folder purpose

Stores the GUIDE window for **EXP IAS MAP estimation for EP** (exponential prior, iterative alternating sequential / IAS hyperparameter updates, **without** RAMUS coarsening). Parent plugin under `tools/plugins/EXP/exp_ias` is the single-resolution sibling of `exp_ias_multires` and of the EM variants under `EXP/`.

## Main contents

| File | Role |
|------|------|
| `exp_ias_map_estimation.fig` | GUIDE figure opened by `exp_ias_map_estimation` |
| `README.md` | This documentation |

Sibling MATLAB: `../m/exp_ias_map_estimation.m`, `zef_init_exp_ias.m`, `zef_update_exp_ias.m`, `exp_ias_iteration.m`. Shared helpers: `../../common/` (`L1_optimization`, etc.).

## Code functionality

Start script opens this `.fig`, sets `zef.h_exp_ias_map_estimation`, titles the window **ZEFFIRO Interface: IAS MAP estimation for EP**, then runs `zef_init_exp_ias`. Start Callback runs `exp_ias_iteration([])` → writes `zef.reconstruction` / `reconstruction_information` with tag **`EXP IAS`**. Widgets: `exp_ias_beta` / `theta0`, SNR, MAP iteration count, sampling/band/time controls (no multires level/sparsity stack). Needs `zef.L` and `zef.measurements`. Uses `zef_processLeadfields` inside the iteration path.

## Workflow context

Parent: EXP IAS single-resolution. Not the default `multicompartment_head` App Designer Lasso entry (`zef_exp_app_launch`). Not the asteroid INI multires callback (`exp_ias_map_estimation_multires`). Class-side relatives elsewhere in the tree: `ias`, `halpr`, `grouplasso` registry ids — different tracks from this GUIDE script. Call from MATLAB for older menus or manual EXP IAS (no RAMUS).

## Usage instructions

```matlab
exp_ias_map_estimation;   % open('exp_ias_map_estimation.fig') + zef_init_exp_ias
% Start in the fig → exp_ias_iteration([])
```

Base-workspace `zef` required. Prefer App Designer EXP launch on modern head profiles when available.

## Important notes

- Real figure file name: **`exp_ias_map_estimation.fig`**.
- Start script that opens it: **`exp_ias_map_estimation`** (`../m/exp_ias_map_estimation.m`).
- Parent plugin purpose: single-resolution EXP IAS MAP for exponential priors.
- Keep `exp_ias_*` fields distinct from `exp_em_*` and from `exp_ias_multires_*`.
- No `inverse.*Inverter` construction from this Start button.

## Developer guidance

- Share bugfixes with `exp_ias_multires` and `EXP/common`.
- Avoid new GUIDE features here; when porting, keep `exp_ias_*` field names so `exp_ias_iteration` stays unchanged.
- Document menu callback names in the parent `../README.md` if any profile re-enables this entry.
