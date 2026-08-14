# EXP EM RAMUS solver files

GUIDE **EM MAP multiresolution (RAMUS) for EP**. EM on a coarsened source space: Create decomposition first (`exp_make_multires_dec` / `zef.exp_multires_*`), then Start. This is **not** the Inverse-tools entry on asteroid / `_legacy` profiles — those open the **IAS** RAMUS window (`exp_ias_map_estimation_multires`). Open this EM variant from MATLAB:

```matlab
exp_em_map_estimation_multires;   % script; opens the GUIDE fig
```

Fig Start runs `exp_em_iteration_multires([])`. Same `zef.L` / SNR / frame needs as other EXP solvers. Writes `zef.reconstruction` / `reconstruction_information`.

| File | Role |
|------|------|
| `exp_em_map_estimation_multires.m` | **script** that `open`s the fig |
| `exp_em_iteration_multires.m` | Solver (`[]` from fig Start) |
| `zef_init_exp_em_multires.m` / `zef_update_exp_em_multires.m` | Widget ↔ `zef` |

Folder overview: [../README.md](../README.md). Unified app: [../../README.md](../../README.md). IAS RAMUS GUIDE: [../../exp_ias_multires/m/README.md](../../exp_ias_multires/m/README.md).
