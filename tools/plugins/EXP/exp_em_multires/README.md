# EXP EM RAMUS (GUIDE, not on the default menu)

Legacy **EM MAP multiresolution (RAMUS) for EP**. Asteroid / `_legacy` Inverse tools open the **IAS** RAMUS window (`exp_ias_map_estimation_multires`), not this EM variant. Call `exp_em_map_estimation_multires` from MATLAB if you need EM + RAMUS coarsening with the EM inner loop.

The start **script** `open`s `fig/exp_em_map_estimation_multires.fig` and runs `zef_init_exp_em_multires`. Fig **Start** runs `exp_em_iteration_multires([])`. Needs `zef.L`, measurements, and a multiresolution decomposition (`exp_make_multires_dec` / `zef.exp_multires_*`) before Start.

Solver files: [m/README.md](m/README.md). Unified App Designer Lasso tool (default head profile): [../README.md](../README.md).
