# ReconstructionTool internals (`m`)

These scripts are what the **Multi tools → ReconstructionTool** buttons actually run. They read/write `zef.reconstructionTool.bankReconstruction` and `bankInfo` in the **base workspace**. The start file that opens the window and assigns `ButtonPushedFcn` is `../zef_reconstructionTool_start.m` (one directory up, not in `m/`). User-facing button table: [parent README](../README.md).

A reconstruction bank exists so you can keep several inverse results (different methods, SNRs, or time windows) without overwriting `zef.reconstruction`. **Replace** copies a bank row back to the live session so the Figure tool can plot it. **Apply** never overwrites a source row; it appends a transformed copy.

| File | Kind | Role |
|------|------|------|
| `zef_reconstructionTool_addCurrent2bank.m` | **script** | Snapshot live `zef.reconstruction` / `reconstruction_information` (wrap a non-cell rec as `{rec}`). |
| `zef_reconstructionTool_replace.m` | **script** | First checked bank row → live `zef.reconstruction` and information (copies `inv_time_*` when present). |
| `zef_reconstructionTool_apply.m` | **script** | `str2func('zef_reconstructionTool_' + dropdown)` on each checked row; appends new bank rows. |
| `zef_reconstructionTool_refresh.m` | **script** | Rebuild `currentInfo` from live `zef`. |
| `zef_reconstructionTool_delete.m` | **script** | Drop checked bank rows. |
| `zef_reconstructionTool_import.m` | **function** | `uigetfile` `*.mat` → reconstruction variables. |

Dropdown maps: [apply_functions/README.md](apply_functions/README.md).
