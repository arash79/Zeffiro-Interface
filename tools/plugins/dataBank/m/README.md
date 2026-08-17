# tools/plugins/dataBank/m

## Folder purpose

Implementation of the **Data Bank** Multi-tools plugin: a named snapshot tree for lead fields, measurements, noise, reconstructions, GMM models, and custom/import shells. Lets one session keep several `L`/data sets, **Load** them back onto live `zef`, or **Combine** selected lead fields/measurements. Distinct from LFBankTool and LeadFieldProcessingTool.

## Main contents

App Designer layouts live in the plugin root (`zef_dataBank_app.mlapp`, rename app) — not under `m/`.

| Group | Files |
|-------|--------|
| Start / open | `zef_start_dataBank` (plugin root), `zef_open_dataBank` |
| CRUD / payload | `zef_dataBank_add`, `_addButtonPress`, `_add_data_item`, `_getData`, `_setData`, `_delete`, `_delete_uitree`, `_uiTreeDeleteHash` |
| Hash / uitree | `zef_dataBank_number2hash`, `_hash2tree`, `_sortTree`, `_rebuildTree`, `_rebuildTreeSaveFile`, `_refreshTree`, `_reorderTree` (legacy), `_getHashForMenu`, `_getHashForTableMenu`, `_treeSearch` |
| Working / combine | `_hashToWorkingSpace`, `_WorkingSpaceInfo`, `_combineLeadFields` (in-file name `combineLeadFieLds`) |
| Disk I/O | `_saveFolderButtonPush`, `_saveTreeNodeSwitchChange`, `_saveTreeNodes`, `_loadTreeNodes`, `_importNodeButtonPress`, `_importNode`, `_importDataBank`, `_exportButtonPress` |
| UI / session | `_init`, `_update`, `_showAll` / `zef_databank_showAll`, `_showCurrent`, `_FunctionsDropDown`, `_startNameChange`, `zef_size` |
| Scripting | `_get_reconstructions`, `_set_reconstructions` |
| Orphan | `_text2struct` (no first-party callers) |

## Code functionality

Storage: `zef.dataBank.tree` keyed by hashes (`node`, `node_1`, …). Each node has `.type`, `.name`, `.hash`, `.data` (struct or `matfile` when save-to-disk is on).

| Entry type | Payload via `getData` |
|------------|------------------------|
| `data` | measurements |
| `noisedata` | `zef.noise_data` |
| `leadfield` | `L`, sensors, imaging method, interpolants, compartment source flags, … |
| `reconstruction` | reconstruction + `reconstruction_information` |
| `gmm` | GMM model / dipoles / amplitudes / parameters |
| `custom` / `import` | shell nodes (parents / imports) |

Combine modes (workingHashes, not tree highlight alone): `frobenius` / `fuchs` / `whitening` → updates `zef.L` / `zef.measurements`.

## Workflow context

```
Multi tools → Data Bank → zef_start_dataBank → zef_open_dataBank
External: duneuro2zef EEG/MEG_to_databank, decision-making examples, analysis scripts
```

INI: `Data Bank,multi_tools,zef_start_dataBank`.

## Usage instructions

```matlab
zef_start_dataBank;           % or Multi tools menu
% Add entry by type → Load / Load with parents
% Modify → workingHashes → Combine
[zef, recs] = zef_dataBank_get_reconstructions(zef);  % scripting harvest
```

## Important notes

- Combine uses **workingHashes**, not selection alone.
- Preserve filename / in-file name typos (`combineLeadFieLds`, `getHashForMenu`) — callers depend on them.
- `get_reconstructions` can clear `zef.reconstruction` as a side effect.
- `custom`/`import` have no full `getData` cases.
- Many GUI callbacks `evalin` base `zef`.

## Developer guidance

- Extend entry types in `getData`/`setData` together; update the Add dropdown.
- Prefer `add_data_item` for programmatic inserts when the App is open.
- Pitfall: confusing Data Bank with LFBankTool (lead-field bank) or LeadFieldProcessingTool.
