# tools/plugins/dataBank/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_dataBank_uiTreeDeleteHash.m` — **function [] = zef_dataBank_uiTreeDeleteHash(node, hashList)**: Function [] = zef data Bank ui Tree Delete Hash(node, hash List).
- `zef_dataBank_delete_uitree.m` — **zef = zef_dataBank_delete_uitree(zef)**: Zef = zef data Bank delete uitree(zef).
- `zef_dataBank_FunctionsDropDown.m` — **zef_dataBank_FunctionsDropDown**: Zef data Bank Functions Drop Down.
- `zef_dataBank_WorkingSpaceInfo.m` — **zef_dataBank_WorkingSpaceInfo**: Zef data Bank Working Space Info.
- `zef_dataBank_add.m` — **zef_dataBank_add**: Zef data Bank add.
- `zef_dataBank_addButtonPress.m` — **zef_dataBank_addButtonPress**: Zef data Bank add Button Press.
- `zef_dataBank_add_data_item.m` — **zef_dataBank_add_data_item**: Zef data Bank add data item.
- `zef_dataBank_combineLeadFields.m` — **zef_dataBank_combineLeadFieLds**: Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
- `zef_dataBank_delete.m` — **zef_dataBank_delete**: Zef data Bank delete.
- `zef_dataBank_exportButtonPress.m` — **zef_dataBank_exportButtonPress**: Zef data Bank export Button Press.
- `zef_dataBank_getData.m` — **zef_dataBank_getData**: Zef data Bank get Data.
- `zef_dataBank_getHashForMenu.m` — **zef_dataBank_getHasForMenu**: Zef data Bank get Has For Menu.
- `zef_dataBank_getHashForTableMenu.m` — **zef_dataBank_getHashForTableMenu**: Zef data Bank get Hash For Table Menu.
- `zef_dataBank_get_reconstructions.m` — **zef_dataBank_get_reconstructions**: Zef data Bank get reconstructions.
- `zef_dataBank_hash2tree.m` — **zef_dataBank_hash2tree**: Zef data Bank hash2tree.
- `zef_dataBank_hashToWorkingSpace.m` — **zef_dataBank_hashToWorkingSpace**: Zef data Bank hash To Working Space.
- `zef_dataBank_importDataBank.m` — **zef_dataBank_importDataBank**: Zef data Bank import Data Bank.
- `zef_dataBank_importNode.m` — **zef_dataBank_importNode**: Zef data Bank import Node.
- `zef_dataBank_importNodeButtonPress.m` — **zef_dataBank_importNodeButtonPress**: Zef data Bank import Node Button Press.
- `zef_dataBank_init.m` — **zef_dataBank_init**: Zef data Bank init.
- `zef_dataBank_loadTreeNodes.m` — **zef_dataBank_loadTreeNodes**: Zef data Bank load Tree Nodes.
- `zef_dataBank_number2hash.m` — **zef_dataBank_number2hash**: Zef data Bank number2hash.
- `zef_dataBank_rebuildTree.m` — **zef_dataBank_rebuildTree**: Zef data Bank rebuild Tree.
- `zef_dataBank_rebuildTreeSaveFile.m` — **zef_dataBank_rebuildTreeSaveFile**: Zef data Bank rebuild Tree Save File.
- `zef_dataBank_refreshTree.m` — **zef_dataBank_refreshTree**: Zef data Bank refresh Tree.
- `zef_dataBank_reorderTree.m` — **zef_dataBank_reorderTree**: Zef data Bank reorder Tree.
- `zef_dataBank_saveFolderButtonPush.m` — **zef_dataBank_saveFolderButtonPush**: Zef data Bank save Folder Button Push.
- `zef_dataBank_saveTreeNodeSwitchChange.m` — **zef_dataBank_saveTreeNodeSwitchChange**: Zef data Bank save Tree Node Switch Change.
- `zef_dataBank_saveTreeNodes.m` — **zef_dataBank_saveTreeNodes**: Zef data Bank save Tree Nodes.
- `zef_dataBank_setData.m` — **zef_dataBank_setData**: Zef data Bank set Data.
- `zef_dataBank_set_reconstructions.m` — **zef_dataBank_set_reconstructions**: Zef data Bank set reconstructions.
- `zef_dataBank_showCurrent.m` — **zef_dataBank_showCurrent**: Zef data Bank show Current.
- `zef_dataBank_sortTree.m` — **zef_dataBank_sortTree**: Zef data Bank sort Tree.
- `zef_dataBank_startNameChange.m` — **zef_dataBank_startNameChange**: Zef data Bank start Name Change.
- `zef_dataBank_text2struct.m` — **zef_dataBank_text2struct**: Zef data Bank text2struct.
- `zef_dataBank_treeSearch.m` — **zef_dataBank_treeSearch**: Zef data Bank tree Search.
- `zef_dataBank_update.m` — **zef_dataBank_update**: Zef data Bank update.
- `zef_databank_showAll.m` — **zef_databank_showAll**: Zef databank show All.
- `zef_size.m` — **zef_size**: Zef size.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_dataBank_delete**: GUI callback or dialog (`zef_dataBank_delete`).
- **zef_dataBank_exportButtonPress**: GUI callback or dialog (`zef_dataBank_exportButtonPress`).
- **zef_dataBank_getHashForTableMenu**: GUI callback or dialog (`zef_dataBank_getHashForTableMenu`).
- **zef_dataBank_importNodeButtonPress**: GUI callback or dialog (`zef_dataBank_importNodeButtonPress`).
- **zef_dataBank_saveFolderButtonPush**: GUI callback or dialog (`zef_dataBank_saveFolderButtonPush`).
- **zef_dataBank_startNameChange**: GUI callback or dialog (`zef_dataBank_startNameChange`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `function [] = zef_dataBank_uiTreeDeleteHash(node, hashList)` from MATLAB with the project root on the path.`
- `Call `zef = zef_dataBank_delete_uitree(zef)` from MATLAB with the project root on the path.`
- ``[zef] = zef_dataBank_FunctionsDropDown(zef)` with project root and `src` on the path.`
- ``[[info, columnNames]] = zef_dataBank_WorkingSpaceInfo(tree, hash)` with project root and `src` on the path.`
- ``[[tree, hash]] = zef_dataBank_add(tree, parentHash, data)` with project root and `src` on the path.`
- ``[zef] = zef_dataBank_addButtonPress(zef)` with project root and `src` on the path.`
- ``[zef] = zef_dataBank_add_data_item(zef, data_type, parent_node_name, node_name)` with project root and `src` on the path.`
- ``[[L, y]] = zef_dataBank_combineLeadFieLds(tree, workingHashes, varargin)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
