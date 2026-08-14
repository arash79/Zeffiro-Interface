# EIT Sensitivity Tool — MATLAB files (`m/`)

Not on any default INI. Open with `zef_eit_sensitivity_tool_start`. The tool compares stored conductivity interpolants / lead fields and can **Substitute** a chosen map into `zef.reconstruction` (and sometimes `zef.sigma` or `zef.L`) so the Figure tool can plot it. Button table and dropdown metrics: parent [../README.md](../README.md).

This is **not** `src/sensitivity` (`zef_sensitivity_run` Monte Carlo on EEG/MEG inverse ids).

| File | Role |
|------|------|
| `zef_eit_sensitivity_tool_start.m` | **script** — construct `zef_eit_sensitivity_tool.mlapp`, set Distribution.Items, wire Activate / Import / Substitute. |
| `zef_eit_sensitivity_tool_import.m` / `_import_2.m` | `uigetfile` `.mat` → `zef.eit_sensitivity_tool_data` / `_data_2` (expect `.avg`, often `.covK`). |
| `zef_eit_sensitivity_tool_substitute.m` | Huge switch on the dropdown: interpolate σ, EIT MAG/RDM/orthogonal maps vs `inv_bg_data`, EEG `L` differences, Store/Use lead fields. |
| `zef_eit_sensitivity_tool_volume.m` | Tetra volumes accumulated on `eit_ind`; several metrics use it as weights. |

**Activate** toggles `zef.sigma_bypass` so later lead-field assembly can skip overwriting σ. Confirm dialogs inside Substitute are commented out in the current tree (the switch runs immediately).
