# EXP EM (single-resolution) — GUIDE layout (`fig/`)

## Folder purpose

Stores the GUIDE window for **EXP EM MAP estimation** (exponential-prior family, expectation–maximization hyperparameter updates, single resolution). Parent plugin under `tools/plugins/EXP/exp_em` is a legacy Inverse-tools path for EM MAP; it is **not** the default-profile App Designer Lasso entry (`zef_exp_app_launch`).

## Main contents

| File | Role |
|------|------|
| `exp_em_map_estimation.fig` | GUIDE figure opened by `exp_em_map_estimation` |
| `README.md` | This documentation |

Sibling MATLAB: `../m/exp_em_map_estimation.m`, `zef_init_exp_em.m`, `zef_update_exp_em.m`, `exp_em_iteration.m`. Shared optimizers live in `../../common/`.

## Code functionality

Start script opens this `.fig`, sets `zef.h_exp_em_map_estimation`, titles the window **ZEFFIRO Interface: EM MAP estimation**, then runs `zef_init_exp_em`. Start Callback in the figure runs `exp_em_iteration([])`, which writes `zef.reconstruction` and `reconstruction_information` (tag **`EXP EM`**). Widgets cover `exp_em_beta` / `theta0`, SNR, MAP / L1 iteration counts, sampling/band/time frame controls. Needs `zef.L` and `zef.measurements`.

## Workflow context

Parent: EXP EM single-resolution under `tools/plugins/EXP/`. Sibling variants: `exp_em_multires` (EM + RAMUS), `exp_ias` / `exp_ias_multires` (IAS). Default head profile uses `common/zef_exp_app_launch` instead. This GUIDE entry is **not** in default/asteroid INIs — call from MATLAB when you specifically need EM (not IAS) without multiresolution.

## Usage instructions

```matlab
exp_em_map_estimation;   % open('exp_em_map_estimation.fig') + zef_init_exp_em
% Start in the fig → exp_em_iteration([])
```

Edit only with GUIDE / `openfig`. Keep `exp_em_*` handle tags stable for init/update.

## Important notes

- Real figure file name: **`exp_em_map_estimation.fig`**.
- Start script that opens it: **`exp_em_map_estimation`** (`../m/exp_em_map_estimation.m`).
- Parent plugin purpose: single-resolution EXP EM MAP → `zef.reconstruction`.
- Do not mix `exp_em_*` fields with `exp_ias_*` or multires namespaces casually.
- Not wired to `inverse.*Inverter` classes.

## Developer guidance

- Share bugfixes with `exp_em_iteration` and `EXP/common` (`L1_optimization`, etc.).
- Prefer documenting the App Designer Lasso path for new head-profile work; keep this fig for legacy EM-only callers.
- Avoid new GUIDE features; port to App Designer only if a profile still requires dedicated EM UI.
