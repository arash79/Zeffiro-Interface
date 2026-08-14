# Multi lead field tool — MATLAB files (`m/`)

These are the functions the **Multi lead field tool** window actually calls. GUI paths, storage layout (`zef.lf_bank_storage`), and button table: parent [../README.md](../README.md). Layout: `mlapp/` (if present) plus widgets created in `zef_lf_bank_tool`.

| File | Role |
|------|------|
| `zef_lf_bank_tool.m` | **script** start: build the window, wire buttons. INI callback. |
| `zef_init_lf_bank_tool.m` | Seed widgets from `zef.lf_bank_*`. |
| `zef_update_lf_bank_tool.m` | Copy widgets back onto `zef`. |
| `zef_add_lf_item.m` | Snapshot live `L`, sensors, measurements, noise, interpolation into the bank. |
| `zef_delete_lf_item.m` | Drop selected bank entries. |
| `zef_combine_lead_fields.m` | Vertical concat of normalized `L` and measurements (Merge). |
| `zef_lf_bank_compute_lead_fields.m` | Restore each item’s sensors, remesh-attach, `zef_lead_field_matrix`, write `L` back. |
| `zef_lf_bank_update_measurements.m` / `zef_lf_bank_update_noise_data.m` | Copy live measurements / noise onto selected items. |

Normalization maps used at merge time: [lead_field_normalization_functions/README.md](lead_field_normalization_functions/README.md).
