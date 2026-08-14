# EXP EM (GUIDE, not on the default menu)

Legacy **EM MAP estimation** window. Default Inverse tools → Lasso uses `common/zef_exp_app_launch` instead.

Call `exp_em_map_estimation` from MATLAB. That **script** `open`s `fig/exp_em_map_estimation.fig`, runs `zef_init_exp_em`, and the fig **Start** callback runs `exp_em_iteration([])`. Needs `zef.L` and `zef.measurements`. Window title: **ZEFFIRO Interface: EM MAP estimation**.

| Path | Role |
|------|------|
| `m/exp_em_map_estimation.m` | Open the fig |
| `m/exp_em_iteration.m` | Solver |
| `m/zef_init_exp_em.m` / `zef_update_exp_em.m` | Widget ↔ `zef` |
| `fig/exp_em_map_estimation.fig` | GUIDE layout |

Parent EXP README: [../README.md](../README.md).
