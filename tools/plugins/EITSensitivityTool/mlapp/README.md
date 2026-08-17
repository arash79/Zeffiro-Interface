# EITSensitivityTool — App Designer layouts

## Folder purpose

App Designer UI for the **EIT Sensitivity Tool**: compare conductivity interpolants and lead fields for EIT vs EEG sensitivity metrics, optionally bypass live `zef.sigma`, and substitute a chosen distribution into `zef.reconstruction` (or σ / L).

## Main contents

| File | Role |
|------|------|
| `zef_eit_sensitivity_tool.mlapp` | EIT Sensitivity Tool (Activate, Import / Import 2, Substitute, Distribution dropdown) |
| `README.md` | This documentation |

MATLAB logic: `tools/plugins/EITSensitivityTool/m/` (`zef_eit_sensitivity_tool_start`, `_import`, `_import_2`, `_substitute`, `_volume`).

## Code functionality

`zef_eit_sensitivity_tool_start` constructs this app, fills Distribution.Items, and wires **Activate** (`sigma_bypass` / `eit_sensitivity_tool_active`), **Import** / **Import 2** (`.mat` → `eit_sensitivity_tool_data` / `_data_2`), and **Substitute** (`zef_eit_sensitivity_tool_substitute` → reconstruction / σ / L). Quantile widgets clip the displayed reconstruction.

## Workflow context

Not in the default profile INI — call from MATLAB for EIT–EEG sensitivity studies. Distinct from `src/sensitivity` (`zef_sensitivity_run` Monte Carlo on EEG/MEG inverse ids). Typical inputs: two interpolation `.mat` files, `zef.L`, `zef.inv_bg_data`, interpolation indices.

## Usage instructions

```matlab
zef_eit_sensitivity_tool_start;   % opens zef_eit_sensitivity_tool.mlapp
% Title: ZEFFIRO Interface: EIT Sensitivity Tool
zef_eit_sensitivity_tool_import;
zef_eit_sensitivity_tool_substitute;
```

Edit layouts only in App Designer. Prefer the start script for production runs.

## Important notes

- Confirm dialogs inside Substitute are commented out in the current tree (switch runs immediately).
- Activating sigma bypass affects later lead-field assembly that would otherwise overwrite σ.

## Developer guidance

- Keep Distribution.Items in `zef_eit_sensitivity_tool_start` in sync with cases in `_substitute`.
- Preserve start entry `zef_eit_sensitivity_tool_start`.
- Detail for MATLAB files: parent `m/README.md`.
