# EXP IAS RAMUS solver files

GUIDE **IAS MAP multiresolution (RAMUS) for EP**. This is the Inverse-tools entry on asteroid / `_legacy` / `_nse` profiles (`exp_ias_map_estimation_multires`). Default head profile uses the unified Lasso app in `common/` instead.

Fig **Start** runs `zef_update_exp_ias_multires` then `exp_ias_iteration_multires([])`. Needs `zef.L`, measurements, and `zef.exp_multires_*` (Create decomposition in the fig, or `exp_make_multires_dec`).

| File | Role |
|------|------|
| `exp_ias_map_estimation_multires.m` | INI callback; `open`s the fig |
| `exp_ias_iteration_multires.m` | Solver |
| `zef_init_exp_ias_multires.m` / `zef_update_exp_ias_multires.m` | Widget ↔ `zef` |

Folder overview: [../README.md](../README.md). Unified app: [../../README.md](../../README.md).
