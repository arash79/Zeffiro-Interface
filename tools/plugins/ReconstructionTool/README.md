# ReconstructionTool

A bank of reconstructions (`zef.reconstructionTool.bankReconstruction` + `bankInfo` table). Store the current `zef.reconstruction` / `zef.reconstruction_information`, put a bank row back, import a file, or apply `mean` / `power` (and any extra `m/apply_functions/zef_reconstructionTool_*.m`) to checked rows.

## How to open it

**Multi tools → ReconstructionTool** (default profile). Callback: `zef_reconstructionTool_start` (script).

## Buttons (`ButtonPushedFcn` in `zef_reconstructionTool_start.m`)

| Button | Action |
|--------|--------|
| **Add** | `zef_reconstructionTool_addCurrent2bank` — wrap non-cell reconstructions as `{rec}`; copy `reconstruction_information` |
| **Replace** | `zef_reconstructionTool_replace` — first checked row → live `zef.reconstruction` and `zef.reconstruction_information` (also copies `inv_time_*` when present) |
| **Refresh** | `zef_reconstructionTool_refresh` — current table from live `zef` |
| **Delete** | `zef_reconstructionTool_delete` |
| **Apply transformation** | `zef_reconstructionTool_apply` — `str2func('zef_reconstructionTool_' + dropdown)` on each checked reconstruction; appends a new bank row (does not overwrite) |
| **Import** | `[zef.reconstruction, zef.reconstruction_information] = zef_reconstructionTool_import` then refresh |

Dropdown is filled from `m/apply_functions/*.m` (names after `Tool_`). Shipped: **mean** (average frames), **power** (mean of squares).

Checkbox column 7 of `bankInfo` is the apply/replace selection.

## Scripting

```matlab
zef_reconstructionTool_start;
zef_reconstructionTool_addCurrent2bank;
zef.reconstruction = zef.reconstructionTool.bankReconstruction{k}.reconstruction;
```
