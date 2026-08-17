## Folder purpose

A tree of named snapshots (lead field, measurements, noise, reconstruction, GMM, custom, import). Use it to keep several `L` / data sets in one project and load one back onto `zef`, or combine selected lead fields into the current `zef.L` / `zef.measurements`.

## Main contents

Data-bank open helpers, tree refresh / get-set data, combine lead fields, import/export, and working-hash table support under this plugin folder (entry via `zef_start_dataBank` → `zef_open_dataBank`).

## Code functionality

**Combine** does **not** use the tree selection. First **Modify** selected nodes into the working-hash table (`zef.dataBank.workingHashes`), then Combine stacks those hashes. Combine menu `Value` is `'frobenius'` (default, `||L||_F / n_sensors`), `'fuchs'` (`diag(std(y))` on the time window), or `'whitening'` (`chol(cov(y))`). After stacking, `L` and `y` are rescaled so `max|L|` matches the pre-stack maximum.

MATLAB dispatches Combine by **filename** `zef_dataBank_combineLeadFields.m`; the `function` line inside is `zef_dataBank_combineLeadFieLds`. Tree selection uses filename `zef_dataBank_getHashForMenu.m` with in-file name `zef_dataBank_getHasForMenu`. Callers use the filenames. Do not patch those names.

Buttons (`ButtonPushedFcn` in `zef_open_dataBank.m`):

| Control | Action |
|---------|--------|
| **Add** | `zef_dataBank_addButtonPress` — snapshot `zef` fields matching Entry type onto the selected tree node (`zef_dataBank_getData`) |
| **Combine** | `[zef.L, zef.measurements] = zef_dataBank_combineLeadFields(...)` on **working hashes** (not the tree highlight), plus combine menu, start/end time, sampling frequency |
| **Show** / **Show current** | fill the tables from the tree / from live `zef` |
| **Refresh** | `zef_dataBank_refreshTree` |
| **Select folder** | disk folder for optional save-to-disk |
| **Import** / **Export** | node file I/O |
| **Show working hashes** | working-space table |

Tree context menu: Load, Load with parents (`zef_dataBank_setData` → copies stored fields onto `zef`), Delete, Modify (hash → working space), Change name. Entry types: `data`, `noisedata`, `leadfield`, `reconstruction`, `gmm`, `custom`, `import`.

Optional `zef.dataBank.save2disk` writes node payloads next to `zef.dataBank.folder`.

## Workflow context

**Multi tools → Data Bank** (default profile). Callback: `zef_start_dataBank` → `zef_tool_start(..., 'zef_open_dataBank', ...)`.

## Usage instructions

```matlab
zef = zef_start_dataBank(zef);
% after selecting a node:
zef.dataBank.loadParents = false;
zef_dataBank_setData;
```

1. Open Multi tools → Data Bank.
2. Add snapshots by entry type; Load / Load with parents to restore onto `zef`.
3. To combine: Modify nodes into working hashes, then Combine with frobenius / fuchs / whitening.

## Important notes

- Combine uses working hashes, not the tree highlight.
- Internal function name typos (`combineLeadFieLds`, `getHasForMenu`) must stay; callers use filenames.
- Save-to-disk is optional via `zef.dataBank.save2disk` and folder selection.

## Developer guidance

Do not rename the misspelled in-file function names to match filenames — callers already use the filenames. Keep entry-type list and combine modes (`frobenius`, `fuchs`, `whitening`) stable.
