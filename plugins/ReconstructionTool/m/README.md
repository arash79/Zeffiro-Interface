## Folder purpose

Scripts the **Multi tools → ReconstructionTool** buttons run. They manage `zef.reconstructionTool.bankReconstruction` / `bankInfo` so several inverse results can be kept without overwriting live `zef.reconstruction`. Start file: `../zef_reconstructionTool_start.m`.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_reconstructionTool_addCurrent2bank.m` | script | Snapshot live reconstruction / information |
| `zef_reconstructionTool_replace.m` | script | First checked bank row → live `zef` |
| `zef_reconstructionTool_apply.m` | script | `str2func` transform on checked rows; append |
| `zef_reconstructionTool_refresh.m` | script | Rebuild `currentInfo` from live `zef` |
| `zef_reconstructionTool_delete.m` | script | Drop checked bank rows |
| `zef_reconstructionTool_import.m` | function | `uigetfile` `*.mat` → reconstruction variables |
| `apply_functions/` | transforms | Dropdown maps for **Apply** |

## Code functionality

**Add** wraps a non-cell reconstruction as `{rec}`. **Replace** restores reconstruction (and `inv_time_*` when present) for Figure-tool plotting. **Apply** never overwrites a source row; it appends a transformed copy via `zef_reconstructionTool_<dropdown>`.

## Workflow context

Multi tools → ReconstructionTool. Complements Data Bank (hash tree) and inverse plugins. Use after inverses exist when comparing methods or post-processing banked reconstructions.

## Usage instructions

Open from the menu; use Add / Apply / Replace / Delete / Import. Checkbox column selects bank rows. Transform list: `apply_functions/README.md`.

## Important notes

- Most helpers are **scripts** that read/write base-workspace `zef`.
- Apply appends; Replace is what updates the live session for plotting.
- Import is a function; the rest are scripts wired as `ButtonPushedFcn`.

## Developer guidance

New transforms belong under `apply_functions/` as `zef_reconstructionTool_<name>.m`. Keep bankInfo column indices consistent with Apply / Delete / Replace. Prefer functions with `zef` in/out when adding programmatic APIs.
