## Folder purpose

A bank of reconstructions (`zef.reconstructionTool.bankReconstruction` + `bankInfo` table). Store the current `zef.reconstruction` / `zef.reconstruction_information`, put a bank row back, import a file, or apply `mean` / `power` (and any extra `m/apply_functions/zef_reconstructionTool_*.m`) to checked rows.

## Main contents

- Start: `zef_reconstructionTool_start.m`
- Bank helpers: add / replace / refresh / delete / apply / import
- Apply functions: `m/apply_functions/` (shipped: **mean**, **power**; see that folder’s README)

## Code functionality

Buttons (`ButtonPushedFcn` in `zef_reconstructionTool_start.m`):

| Button | Action |
|--------|--------|
| **Add** | `zef_reconstructionTool_addCurrent2bank` — wrap non-cell reconstructions as `{rec}`; copy `reconstruction_information` |
| **Replace** | `zef_reconstructionTool_replace` — first checked row → live `zef.reconstruction` and `zef.reconstruction_information` (also copies `inv_time_*` when present) |
| **Refresh** | `zef_reconstructionTool_refresh` — current table from live `zef` |
| **Delete** | `zef_reconstructionTool_delete` |
| **Apply transformation** | `zef_reconstructionTool_apply` — `str2func('zef_reconstructionTool_' + dropdown)` on each checked reconstruction; appends a new bank row (does not overwrite) |
| **Import** | `[zef.reconstruction, zef.reconstruction_information] = zef_reconstructionTool_import` then refresh |

Dropdown is filled from `m/apply_functions/*.m` (names after `Tool_`). Shipped: **mean** and **power**. Both loop `size(reconstruction,2)`. The bank stores `zef.reconstruction` as-is (typically an N×1 cell from inverse solvers), so those transforms keep the **first frame** rather than averaging all frames. A 1×N cell would average. See `m/apply_functions/README.md`.

Checkbox column 7 of `bankInfo` is the apply/replace selection.

## Workflow context

**Multi tools → ReconstructionTool** (default profile). Callback: `zef_reconstructionTool_start` (script).

## Usage instructions

```matlab
zef_reconstructionTool_start;
zef_reconstructionTool_addCurrent2bank;
zef.reconstruction = zef.reconstructionTool.bankReconstruction{k}.reconstruction;
```

1. Add the current reconstruction to the bank.
2. Replace to restore a checked row, or Apply transformation to append mean/power (etc.).
3. Import can load a reconstruction file into live `zef` then refresh.

## Important notes

- Apply appends a new bank row; it does not overwrite the source row.
- mean/power on typical N×1 cell banks keep the first frame only; a 1×N cell would average across frames.
- Replace also copies `inv_time_*` when present in bank metadata.

## Developer guidance

Preserve callback `zef_reconstructionTool_start`. New apply helpers must be named `zef_reconstructionTool_*.m` under `m/apply_functions/` so the dropdown discovers them.
