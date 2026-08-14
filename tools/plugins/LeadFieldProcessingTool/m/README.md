# LeadFieldProcessingTool internals (`m`)

Implementations behind the App Designer **LeadFieldProcessingTool** bank (`zef.LeadFieldProcessingTool.bank`). Start script is `../LeadFieldProcessingTool_start.m`. User manual (menu, buttons, scripting): [parent README](../README.md).

This bank is **not** the Multi lead field tool (`LFBankTool/`, `zef.lf_bank_storage`). That tool can **recompute** `L` from stored sensors. This tool instead snapshots the live `L`, can left-multiply a magnetometer→gradiometer `tra`, and can noise-weight `vertcat` several rows. Use LFBank when you need Merge + recompute; use this tool when you already have `L` and want mag→grad or a noise-weighted stack.

## Files

| File | Role |
|------|------|
| `zef_LeadFieldProcessingTool_addCurrentData2bank.m` | **Add**: snapshot live `L` / sensors / measurements / noise / interpolation / compartment source flags; new `lead_field_id` |
| `zef_LeadFieldProcessingTool_add.m` | Alternate add path (fills `auxData` then `aux2bank_new`); not the wired Add button |
| `zef_LeadfieldProcessingTool_aux2current.m` | **Replace**: checked row → live `zef` |
| `zef_LeadfieldProcessingTool_bank2aux_bank2auxIndex.m` | `bank{bank2auxIndex}` → `auxData` |
| `zef_LeadFieldProcessingTool_aux2bank_new.m` / `_bankPosition.m` | Append or overwrite `auxData` in the bank |
| `zef_LeadfieldProcessingTool_mag2Grad.m` / `_loadTra.m` | **Mag2Grad** / **loadTra**: `L ← tra*L` on checked rows, `imaging_method = 3`, new bank entry |
| `zef_LeadfieldProcessingTool_combine.m` | **Combine**: each checked row’s `L` and measurements divided by per-channel std on Noise start:end, then `vertcat` |
| `zef_LeadfieldProcessingTool_combinebla.m` | Same combine, selection column 5; **not** wired |
| `zef_LeadfieldProcessingTool_delete.m` / `_refresh.m` / `_updateTable.m` / `_BankTableLabelUpdate.m` | Drop rows, rebuild table, edit label |

Bank table checkbox column (index 6) selects rows for Replace / Mag2Grad / Combine / Delete.
