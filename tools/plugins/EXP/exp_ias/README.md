# EXP IAS (GUIDE, not on the default menu)

Legacy **IAS MAP estimation for EP** window. Default Lasso app is `common/zef_exp_app_launch`.

Call `exp_ias_map_estimation` from MATLAB. **script** `open`s `fig/exp_ias_map_estimation.fig`, `zef_init_exp_ias`. Fig **Start** runs `exp_ias_iteration([])`. Needs `zef.L` and `zef.measurements`. Title: **ZEFFIRO Interface: IAS MAP estimation for EP**.

| Path | Role |
|------|------|
| `m/exp_ias_map_estimation.m` | Open the fig |
| `m/exp_ias_iteration.m` | Solver |
| `m/zef_init_exp_ias.m` / `zef_update_exp_ias.m` | Widget ↔ `zef` |
| `fig/exp_ias_map_estimation.fig` | GUIDE layout |

Parent: [../README.md](../README.md).
