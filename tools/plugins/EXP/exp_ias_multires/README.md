# EXP IAS RAMUS (GUIDE; asteroid / legacy menu)

This is the window asteroid and `multicompartment_head_legacy` / `_nse` profiles open as Inverse tools → **EXP IAS RAMUS** (`exp_ias_map_estimation_multires`). The default head profile uses the App Designer Lasso tool instead (`zef_exp_app_launch`).

**script** `open`s `fig/exp_ias_map_estimation_multires.fig`. Fig **Start** (from parent README):

```matlab
zef_update_exp_ias_multires; [zef.reconstruction,zef.reconstruction_information] = exp_ias_iteration_multires([]);
```

Needs `zef.L`, measurements, and `exp_multires_dec`. Title in code: **ZEFFIRO Interface: IAS MAP multiresolution (RAMUS) for EP**. GUIDE resource name: `IAS MAP estimation multiresolution`.

Parent: [../README.md](../README.md).
