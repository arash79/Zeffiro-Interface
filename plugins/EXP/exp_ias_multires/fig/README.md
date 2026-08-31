# EXP IAS multiresolution — GUIDE layout (`fig/`)

## Folder purpose

Stores the GUIDE window for **EXP IAS MAP multiresolution (RAMUS) for EP** — the asteroid / legacy Inverse-tools entry for exponential-prior IAS with RAMUS lattices. Parent plugin under `plugins/EXP/exp_ias_multires` is the supported GUIDE multires path when profiles do not use the App Designer Lasso tool.

## Main contents

| File | Role |
|------|------|
| `exp_ias_map_estimation_multires.fig` | GUIDE figure opened by `exp_ias_map_estimation_multires` |
| `README.md` | This documentation |

Sibling MATLAB: `../m/exp_ias_map_estimation_multires.m`, `zef_init_exp_ias_multires.m`, `zef_update_exp_ias_multires.m`, `exp_ias_iteration_multires.m`. Lattices: `../../common/exp_make_multires_dec.m`.

## Code functionality

Start script opens this `.fig`, sets `zef.h_exp_ias_map_estimation_multires`, titles the window **ZEFFIRO Interface: IAS MAP multiresolution (RAMUS) for EP**, then runs `zef_init_exp_ias_multires`. Start Callback in the figure:

```matlab
zef_update_exp_ias_multires; [zef.reconstruction,zef.reconstruction_information] = exp_ias_iteration_multires([]);
```

Widgets include multires levels / sparsity / `q`, beta / theta0, SNR, iteration counts, and time/band controls. Needs `zef.L`, measurements, and **`exp_multires_dec`** (plus related `exp_multires_*` fields) before Start.

## Workflow context

Parent: EXP IAS + RAMUS. Wired in asteroid / `_legacy` / `_nse` profile INIs as Inverse tools → **EXP IAS RAMUS**, callback **`exp_ias_map_estimation_multires`**. Default `multicompartment_head` instead uses `zef_exp_app_launch` (App Designer).

## Usage instructions

```matlab
% Ensure exp_multires_* lattices exist (Create / exp_make_multires_dec)
exp_ias_map_estimation_multires;   % opens exp_ias_map_estimation_multires.fig
```

Or: Inverse tools → EXP IAS RAMUS on asteroid / legacy profiles, then Start.

## Important notes

- Real figure file name: **`exp_ias_map_estimation_multires.fig`**.
- Start script that opens it: **`exp_ias_map_estimation_multires`** (`../m/exp_ias_map_estimation_multires.m`).
- Parent plugin purpose: IAS MAP on RAMUS multiresolution lattices for exponential priors (asteroid GUIDE path).
- Not the default-profile Lasso app; not `inverse.GroupLassoInverter`.
- Empty `exp_multires_dec` will fail at Start — build decompositions first.

## Developer guidance

- Preserve asteroid INI callback `exp_ias_map_estimation_multires` and reconstruction tags from `exp_ias_iteration_multires`.
- Keep lattice construction in `EXP/common`; do not fork `exp_make_multires_dec`.
- Prefer App Designer unification for new head-profile work; keep this fig stable for asteroid menus.
