# Multi lead field tool

Stores several complete lead-field packages (`zef.lf_bank_storage{i}`: `L`, sensors, interpolation, measurements, noise, tag) and can **recompute** or **merge** them into the live `zef.L` / `zef.measurements`. Merge stacks rows (sensors) and applies a normalization from `m/lead_field_normalization_functions/`.

This is the default-profile **Multi lead field tool**. `LeadFieldProcessingTool/` is a second, App Designer bank with mag→grad and noise-weighted combine.

## How to open it

**Multi tools → Multi lead field tool** (default profile). Callback: `zef_lf_bank_tool` (script). Title: **ZEFFIRO Interface: Multi lead field tool**.

## Buttons (`ButtonPushedFcn` in `m/zef_lf_bank_tool.m`)

| Handle | Action |
|--------|--------|
| Add | `zef_add_lf_item` — copy current `zef.L`, sensors, measurements, noise, interpolation into the bank (runs `zef_process_meshes` if `zef.s_points` nonempty) |
| Merge selected | confirm → `zef_combine_lead_fields` — vertical concat of normalized `L` and measurements; first item wins sensors/imaging method |
| Delete selected | `zef_delete_lf_item` |
| Re-calculate lead fields | `zef_lf_bank_compute_lead_fields` — for each selected item, restore sensors, `zef_process_meshes`, `zef_attach_sensors_volume`, `zef_lead_field_matrix`, write `L` back into the bank |
| Update measurements / noise | copy live `zef.measurements` / `zef.noise_data` onto selected items |
| Make all | mesh (`zef_create_fem_mesh` + postprocess) then compute lead fields |

Normalization dropdown (`zef.lf_normalization`) is an **index into the alphabetically sorted `Description:` labels**, not a fixed enum. Init scans `m/lead_field_normalization_functions/`, takes MATLAB `help`, and sorts. With the shipped files, index 2 is **Normalize Frobenius**; Merge then also re-Frobenius-scales the stacked `L`. Adding a file whose `Description:` sorts earlier will shift every later index. Keep a `Description:` line in each helper — Filter-tool style. Table: `m/lead_field_normalization_functions/README.md`.

## Scripting

```matlab
zef_add_lf_item;
zef_combine_lead_fields;   % selected items → zef.L, zef.measurements
```
