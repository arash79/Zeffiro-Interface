# EXP EM multiresolution — GUIDE layout (`fig/`)

## Folder purpose

Stores the GUIDE window for **EXP EM MAP with RAMUS multiresolution** (exponential prior, EM updates on coarsened lattices). Parent plugin under `tools/plugins/EXP/exp_em_multires` is a legacy Inverse-tools path; asteroid menus typically point at **IAS** multires (`exp_ias_multires`), not this EM multires figure.

## Main contents

| File | Role |
|------|------|
| `exp_em_map_estimation_multires.fig` | GUIDE figure opened by `exp_em_map_estimation_multires` |
| `README.md` | This documentation |

Sibling MATLAB: `../m/exp_em_map_estimation_multires.m`, `zef_init_exp_em_multires.m`, `zef_update_exp_em_multires.m`, `exp_em_iteration_multires.m`. Lattice builder: `../../common/exp_make_multires_dec.m`.

## Code functionality

Start script opens this `.fig`, sets `zef.h_exp_em_map_estimation_multires`, titles the window **ZEFFIRO Interface: EM MAP multiresolution (RAMUS) for EP**, then runs `zef_init_exp_em_multires`. Start runs `exp_em_iteration_multires([])` → tag **`EXP EM Multiresolution`**. Widgets include `exp_em_multires_n_levels` / sparsity / `q` / beta / theta0, SNR, iteration counts, and time/band controls. Requires `zef.L`, measurements, and **`zef.exp_multires_dec`** (from `exp_make_multires_dec`) before Start.

## Workflow context

Parent: EXP EM + RAMUS under `tools/plugins/EXP/`. Parallel IAS multires is the asteroid INI entry. This EM multires GUIDE tool is **not** in default/asteroid INIs. Empty `exp_multires_dec` fails similarly to other RAMUS-style paths that assume prebuilt lattices.

## Usage instructions

```matlab
% Build lattices first (shared EXP helper):
exp_make_multires_dec;   % or equivalent Create path that fills exp_multires_*
exp_em_map_estimation_multires;   % opens exp_em_map_estimation_multires.fig
% Start → exp_em_iteration_multires([])
```

## Important notes

- Real figure file name: **`exp_em_map_estimation_multires.fig`**.
- Start script that opens it: **`exp_em_map_estimation_multires`** (`../m/exp_em_map_estimation_multires.m`).
- Parent plugin purpose: EM MAP on RAMUS multiresolution lattices for exponential priors.
- Profile INIs may omit this entry — absence from the menu is expected.
- Field namespace is `exp_em_multires_*` plus shared `exp_multires_*` lattices; do not confuse with `exp_ias_multires_*`.

## Developer guidance

- Prefer documenting IAS multires as the supported GUIDE multires path for asteroid profiles.
- Share `exp_make_multires_dec` rather than duplicating lattice builders.
- Keep EM multires iteration bugfixes aligned with `exp_em_iteration` / `EXP/common`.
