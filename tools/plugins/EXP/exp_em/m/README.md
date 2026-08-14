# EXP EM solver files

GUIDE **EM MAP estimation** internals. EM (expectation–maximization) is one of the three estimation types in the unified Exponential Prior tool (`common/exp_iteration`: IAS / EM / sLORETA). This folder is the older standalone window for EM only.

**Not** on the default Inverse-tools menu (that uses `zef_exp_app_launch` → `exp_iteration`). Open from MATLAB:

```matlab
exp_em_map_estimation;   % script; opens the GUIDE fig
```

Start in the fig still calls `exp_em_iteration([])`. Needs `zef.L`, interpolation, `zef.measurements`, and the same SNR/frame fields as other EXP solvers (`inv_snr`, `number_of_frames`, `inv_time_*`). Writes `zef.reconstruction` / `reconstruction_information`.

| File | Role |
|------|------|
| `exp_em_map_estimation.m` | **script** that `open`s the fig and runs `zef_init_exp_em` |
| `exp_em_iteration.m` | Solver (`[]` from the fig Start callback) |
| `zef_init_exp_em.m` / `zef_update_exp_em.m` | Widget ↔ `zef` |

Folder overview: [../README.md](../README.md). Unified app (default INI): [../../README.md](../../README.md).
