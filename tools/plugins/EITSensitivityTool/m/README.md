# EITSensitivityTool / m

## Folder purpose

MATLAB implementation of the **EIT Sensitivity Tool**: import conductivity interpolants / lead fields, compute sensitivity maps, and **Substitute** a chosen map into `zef.reconstruction` (and sometimes `zef.sigma` or `zef.L`) for Figure-tool plotting.

## Main contents

| File | Role |
|------|------|
| `zef_eit_sensitivity_tool_start.m` | **script** — construct `zef_eit_sensitivity_tool.mlapp`, set Distribution.Items, wire Activate / Import / Substitute |
| `zef_eit_sensitivity_tool_import.m` / `_import_2.m` | `uigetfile` `.mat` → `zef.eit_sensitivity_tool_data` / `_data_2` (expect `.avg`, often `.covK`) |
| `zef_eit_sensitivity_tool_substitute.m` | Huge switch on the dropdown: interpolate σ, EIT MAG/RDM/orthogonal maps vs `inv_bg_data`, EEG `L` differences, Store/Use lead fields |
| `zef_eit_sensitivity_tool_volume.m` | Tetra volumes accumulated on `eit_ind`; several metrics use it as weights |

## Code functionality

- Start builds the App Designer window and binds button callbacks.
- Import fills `zef.eit_sensitivity_tool_data*` and path widgets.
- Substitute interpolates / compares distributions and writes plottable fields; volume weights come from `zef_eit_sensitivity_tool_volume`.
- **Activate** toggles `zef.sigma_bypass` so later lead-field assembly can skip overwriting σ.

## Workflow context

Called from the parent plugin folder; not on any default INI. Distinct from `src/sensitivity` Monte Carlo (`zef_sensitivity_run`). Button table and dropdown metrics: parent [`../README.md`](../README.md).

## Usage instructions

```matlab
zef_eit_sensitivity_tool_start;
zef_eit_sensitivity_tool_import;
zef_eit_sensitivity_tool_substitute;
```

## Important notes

- Confirm dialogs inside Substitute are commented out (switch runs immediately).
- Not the same code path as EEG/MEG sensitivity Monte Carlo under `src/sensitivity`.

## Developer guidance

When adding a distribution item, update both `Distribution.Items` in start and the switch in substitute, and document weight usage (`volume`) if the metric needs it. Keep parent README’s dropdown list in sync.
