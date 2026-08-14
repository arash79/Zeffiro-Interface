# Multi lead field tool — App Designer layout

`zeffiro_interface_lf_bank_tool.mlapp` is the window source. `m/zef_lf_bank_tool.m` constructs it via `zeffiro_interface_lf_bank_tool`, then assigns every `ButtonPushedFcn` (Add, Merge, Delete, Re-calculate, Update measurements/noise, Make all). Do not run the generated app from the command line; those callbacks would be missing.

Button table: parent [../README.md](../README.md). MATLAB files: [../m/README.md](../m/README.md).
