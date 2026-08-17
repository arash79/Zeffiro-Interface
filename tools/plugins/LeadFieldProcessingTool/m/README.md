# tools/plugins/LeadFieldProcessingTool/m

## Folder purpose

Bank helpers for the App Designer **Lead Field Processing Tool**: snapshot / transform / combine **existing** `zef.L` entries in `zef.LeadFieldProcessingTool.bank`. Does **not** recompute FEM lead fields (that is LFBankTool / `src/forward/lead_field`). Distinct from Data Bank (multi-type session tree).

## Main contents

| File | Role |
|------|------|
| `../LeadFieldProcessingTool_start.m` | Menu start (Multi tools) |
| `zef_LeadFieldProcessingTool_addCurrentData2bank.m` | **Add** live `L` snapshot |
| `zef_LeadfieldProcessingTool_aux2current.m` | **Replace** current from aux |
| `zef_LeadfieldProcessingTool_loadTra.m` | Apply `tra*L` |
| `zef_LeadfieldProcessingTool_mag2Grad.m` | Mag→grad (`imaging_method=3`) |
| `zef_LeadfieldProcessingTool_combine.m` | Noise-std weighted `vertcat` |
| `*_delete` / `*_refresh` / `*_updateTable` / `*_BankTableLabelUpdate` | Table maintenance |
| `*_aux2bank_*` / `*_bank2aux_*` / `*_bankPosition` | Bank ↔ aux plumbing |
| Unwired | `add.m`, `combinebla.m` (leftovers) |

## Code functionality

1. **Add** copies current lead-field-related fields into the bank table.
2. Transforms operate on bank/aux copies (`tra`, mag2grad).
3. **Combine** stacks selected rows with noise-std weighting.
4. **Replace** pushes aux back to live `zef`.

Checkbox / selection column indexing is sensitive (historically column **6**) — verify against the `.mlapp` if editing.

## Workflow context

```
Compute L (lead_field / LFBankTool)
  → LeadFieldProcessingTool (this folder) → bank ops
  → Inverse on modified zef.L
```

## Usage instructions

```matlab
LeadFieldProcessingTool_start;  % or Multi tools menu
% Add → optional Mag2Grad / loadTra / Combine → Replace
```

## Important notes

- Filename casing mixes `LeadField` and `Leadfield` — call the exact names MATLAB resolves.
- Does not call `zef_lead_field_matrix`.
- Not the same as Data Bank entry type `leadfield`.

## Developer guidance

- Wire new buttons only through the start/window script; remove or document unwired leftovers.
- Pitfall: combining incompatible sensor counts / modalities without updating `imaging_method` and measurement size.
