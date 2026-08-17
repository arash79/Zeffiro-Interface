# tools/plugins/EITSensitivityTool

## Folder purpose

Compares conductivity interpolants and lead fields for **EIT vs EEG** sensitivity metrics, and can bypass live `zef.sigma` (`zef.sigma_bypass`). **Substitute** writes a chosen distribution into `zef.reconstruction` (and sometimes `zef.sigma` or `zef.L`).

## Main contents

| Path | Role |
|------|------|
| `m/zef_eit_sensitivity_tool_start.m` | Construct app; wire Activate / Import / Substitute |
| `m/zef_eit_sensitivity_tool_import.m` / `_import_2.m` | Load `.mat` → `eit_sensitivity_tool_data` / `_data_2` |
| `m/zef_eit_sensitivity_tool_substitute.m` | Distribution dropdown switch → reconstruction / σ / L |
| `m/zef_eit_sensitivity_tool_volume.m` | Tetra volumes on `eit_ind` (metric weights) |
| `mlapp/` | App Designer UI |

## Code functionality

- **Activate** toggles `zef.sigma_bypass` and `zef.eit_sensitivity_tool_active`.
- **Import** / **Import 2** load interpolants (`.avg`, often `.covK`).
- **Substitute** supports Sigma 1/2 (optionally excluding outer layers), EIT sensitivity (parallel / MAG / orthogonal / RDM) and relative/difference variants vs `zef.inv_bg_data`, EEG lead-field differences (`L_EEG_1` / `L_EEG_2`), amplitudes, and Store/Use EIT or EEG lead fields. Quantile widgets clip `zef.reconstruction`.

## Workflow context

Sensitivity comparison / visualization for EIT–EEG studies. **Not** `src/sensitivity` (`zef_sensitivity_run` Monte Carlo on EEG/MEG inverse ids). **Not** in the default profile INI.

## Usage instructions

```matlab
zef_eit_sensitivity_tool_start;   % script
% Title: ZEFFIRO Interface: EIT Sensitivity Tool
zef_eit_sensitivity_tool_import;
zef_eit_sensitivity_tool_substitute;
```

Typical inputs: two interpolation `.mat` files, `zef.L`, `zef.inv_bg_data`, `zef.source_interpolation_ind`, `zef.brain_ind`.

## Important notes

- Confirm dialogs inside Substitute are commented out in the current tree (the switch runs immediately).
- Activating sigma bypass affects later lead-field assembly that would otherwise overwrite σ.

## Developer guidance

Keep Distribution.Items in start in sync with cases in `zef_eit_sensitivity_tool_substitute`. Detail for MATLAB files: [`m/README.md`](m/README.md).
