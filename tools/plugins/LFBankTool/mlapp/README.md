# LFBankTool — App Designer layouts

## Folder purpose

App Designer UI for the **Multi lead field tool**: store several lead-field packages in `zef.lf_bank_storage`, recompute them, or merge selected items into live `zef.L` / `zef.measurements`.

## Main contents

| File | Role |
|------|------|
| `zeffiro_interface_lf_bank_tool.mlapp` | Multi lead field tool (Add, Merge, Delete, re-calculate, update measurements/noise, Make all, normalization dropdown) |
| `README.md` | This documentation |

MATLAB logic: `tools/plugins/LFBankTool/m/` (`zef_lf_bank_tool`, `zef_add_lf_item`, `zef_combine_lead_fields`, `zef_delete_lf_item`, `zef_lf_bank_compute_lead_fields`, normalization helpers under `m/lead_field_normalization_functions/`).

## Code functionality

`zef_lf_bank_tool` opens this app, inits the bank table, and wires buttons: Add copies current `L`/sensors/measurements into the bank; Merge runs `zef_combine_lead_fields` with a normalization index from sorted `Description:` labels; Delete / re-calculate / update measurements-noise / Make all call the matching `m/` helpers. Distinct from `LeadFieldProcessingTool/` (mag→grad / noise-weighted combine).

## Workflow context

**Multi tools → Multi lead field tool** (default profile). Callback: `zef_lf_bank_tool`. Title: **ZEFFIRO Interface: Multi lead field tool**.

## Usage instructions

```matlab
zef_lf_bank_tool;   % opens zeffiro_interface_lf_bank_tool.mlapp
zef_add_lf_item;
zef_combine_lead_fields;   % selected items → zef.L, zef.measurements
```

1. Open Multi tools → Multi lead field tool.
2. Add packages; optionally re-calculate or update measurements/noise.
3. Merge selected with the chosen normalization index.

Edit UI only in App Designer.

## Important notes

- `zef.lf_normalization` is a sorted-`Description:` index, not a fixed enum — adding helpers can shift indices.
- Merge: first item wins sensors/imaging method; stacked `L` may be re-Frobenius-scaled.

## Developer guidance

- Preserve callback `zef_lf_bank_tool`.
- Every normalization helper must keep a `Description:` line in `help()`.
- Keep button Tags aligned with `ButtonPushedFcn` wiring in `zef_lf_bank_tool.m`.
