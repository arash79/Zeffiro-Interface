# Data Bank internals (`tools/plugins/dataBank/m`)

Functions the Data Bank window calls after `zef_start_dataBank` opens the App. They implement the tree: hash keys, load/save node `.mat` files, import/export, reconstruction get/set, and the uitree refresh.

This is not a second public API. Use **Multi tools → Data Bank** (or `zef_start_dataBank`) as documented in [../README.md](../README.md). Call these `zef_dataBank_*` helpers only when extending the plugin or when a script already has `zef.dataBank` (duneuro `EEG_to_databank` / `MEG_to_databank`, decision-making examples, analysis scripts).

`zef_dataBank_app` / `zef_dataBank_nameChange_app` are App Designer figures loaded from the MATLAB path (not `.m` in this folder). Callbacks in `zef_open_dataBank` point here.

## What lives here vs the start function

| Location | Role |
|----------|------|
| `../zef_start_dataBank.m` | Menu callback: `zef_tool_start(..., 'zef_open_dataBank', ...)` |
| `../zef_open_dataBank.m` | Constructs the App, wires `ButtonPushedFcn` / menus, first `hash2tree` |
| `m/` (this folder) | Tree algebra, disk I/O, table fill, Combine, reconstruction get/set |

## Hash keys

`zef.dataBank.tree` is a struct whose fields are hashes `node`, `node_1`, `node_1_2`, … (`zef_dataBank_number2hash`). Each node has `.type`, `.name`, `.hash`, and `.data` (payload struct, or a `matfile` handle when `zef.dataBank.save2disk` is `'On'`). Uitree `NodeData` stores that hash. `zef_dataBank_add` appends the next free sibling `parentHash_i`.

## GUI vs programmatic

Most GUI callbacks are string `ButtonPushedFcn`s that call these functions with **no arguments**; they `evalin('base','zef')` and `assignin` when `nargout==0`. Scripts that keep a local `zef` should pass it in and capture the output.

Programmatic add used by duneuro: `zef_dataBank_add_data_item` (needs the App already open). Reconstruction harvest: `zef_dataBank_get_reconstructions` / `zef_dataBank_set_reconstructions`.

## Combine and filename mismatches

**Combine** reads `zef.dataBank.workingHashes` (filled by tree **Modify**), not the current uitree highlight. Approaches: `'frobenius'`, `'fuchs'`, `'whitening'` (`combineMenu.Value`). See parent README.

MATLAB dispatches by filename:

| Filename | `function` line inside |
|----------|------------------------|
| `zef_dataBank_getHashForMenu.m` | `zef_dataBank_getHasForMenu` |
| `zef_dataBank_combineLeadFields.m` | `zef_dataBank_combineLeadFieLds` |

Callers use the filenames. Do not rename the in-file symbols without updating every string callback.
