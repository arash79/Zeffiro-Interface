## Folder purpose

Functions the **Multi lead field tool** window calls: bank CRUD, recompute, merge, and measurement/noise sync. GUI paths and `zef.lf_bank_storage` layout: parent README.

## Main contents

| File | Role |
|------|------|
| `zef_lf_bank_tool.m` | Script start: build window, wire buttons (INI callback) |
| `zef_init_lf_bank_tool.m` | Seed widgets from `zef.lf_bank_*` |
| `zef_update_lf_bank_tool.m` | Copy widgets back onto `zef` |
| `zef_add_lf_item.m` | Snapshot live `L`, sensors, measurements, noise, interpolation |
| `zef_delete_lf_item.m` | Drop selected bank entries |
| `zef_combine_lead_fields.m` | Vertical concat of normalized `L` and measurements (Merge) |
| `zef_lf_bank_compute_lead_fields.m` | Restore sensors, remesh-attach, recompute `L` |
| `zef_lf_bank_update_measurements.m` / `zef_lf_bank_update_noise_data.m` | Copy live data onto selected items |
| `lead_field_normalization_functions/` | Merge-time normalization maps |

## Code functionality

Bank items store sensors and related data so **Compute** can rebuild `L`. **Merge** runs the selected normalization map on each index, then `vertcat`s. This tool can recompute lead fields from stored sensors; LeadFieldProcessingTool cannot.

## Workflow context

Multi tools → Multi lead field tool (INI). Distinct from LeadFieldProcessingTool (`zef.LeadFieldProcessingTool.bank`) and Data Bank lead-field combine. Use after meshes/sensors exist when stacking modality or session lead fields.

## Usage instructions

Open from the menu, **Add** live items, optionally **Compute**, then **Merge selected**. Programmatic:

```matlab
zef_lf_bank_tool;   % script; uses base-workspace zef
```

Normalization maps: see `lead_field_normalization_functions/README.md`.

## Important notes

- Storage key: `zef.lf_bank_storage` (not Data Bank hashes).
- Merge normalization index `zef.lf_normalization` is into an alphabetically sorted Description list.
- When sorted selection is Normalize Frobenius (`== 2`), combine applies an extra global Frobenius rescale after stacking.

## Developer guidance

Keep merge math in `zef_combine_lead_fields` and map files under `lead_field_normalization_functions/`. Preserve `Description:` help tags on new maps. Layout may live in `mlapp/` plus widgets created in `zef_lf_bank_tool`.
