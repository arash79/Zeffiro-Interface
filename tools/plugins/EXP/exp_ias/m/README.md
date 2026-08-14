# EXP IAS solver files

GUIDE **IAS MAP estimation for EP** internals. IAS (iterative alternating sequential MAP on the same L1/L2 hierarchical prior) is estimation type 1 in the unified Exponential Prior tool. This folder is the older standalone window for IAS without RAMUS coarsening.

**Not** on the default Inverse-tools menu. Asteroid / `_legacy` profiles open the **IAS RAMUS** window (`exp_ias_multires/`), not this one. Open from MATLAB:

```matlab
exp_ias_map_estimation;   % script; opens the GUIDE fig
```

Start in the fig still calls `exp_ias_iteration([])`. Same `zef.L` / SNR / frame needs as `exp_iteration`. Writes `zef.reconstruction` / `reconstruction_information`.

| File | Role |
|------|------|
| `exp_ias_map_estimation.m` | **script** that `open`s the fig and runs `zef_init_exp_ias` |
| `exp_ias_iteration.m` | Solver (`[]` from the fig Start callback) |
| `zef_init_exp_ias.m` / `zef_update_exp_ias.m` | Widget ↔ `zef` |

Folder overview: [../README.md](../README.md). Unified app: [../../README.md](../../README.md). RAMUS IAS GUIDE: [../../exp_ias_multires/m/README.md](../../exp_ias_multires/m/README.md).
