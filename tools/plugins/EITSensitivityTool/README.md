# EIT Sensitivity Tool

Compares conductivity interpolants and lead fields for **EIT vs EEG** sensitivity metrics, and can bypass live `zef.sigma` (`zef.sigma_bypass`). **Substitute** writes a chosen distribution into `zef.reconstruction` (and sometimes `zef.sigma` or `zef.L`).

**Not in the default profile INI.** Call `zef_eit_sensitivity_tool_start` from MATLAB.

## How to open it

```matlab
zef_eit_sensitivity_tool_start;   % script
```

Title: **ZEFFIRO Interface: EIT Sensitivity Tool**. Typical inputs: two interpolation `.mat` files (`eit_sensitivity_tool_data` / `_data_2` with `.avg` and often `.covK`), `zef.L`, `zef.inv_bg_data`, `zef.source_interpolation_ind`, `zef.brain_ind`.

## Buttons (`ButtonPushedFcn` in `m/zef_eit_sensitivity_tool_start.m`)

| Handle | Action |
|--------|--------|
| **Activate** | toggle `zef.sigma_bypass` and `zef.eit_sensitivity_tool_active` (label Inactive / Active, font color) |
| **Import** / **Import 2** | load `.mat` → `zef.eit_sensitivity_tool_data` / `_data_2` and file path widgets |
| **Substitute** | `zef_eit_sensitivity_tool_substitute` — huge switch on the distribution dropdown |

Dropdown items (wired in start): Sigma 1/2 (optionally excluding outer layers) → interpolate `.avg` onto `zef.sigma(brain_ind,1)` and `zef.reconstruction`; EIT sensitivity (parallel / MAG / orthogonal / RDM) and relative/difference variants vs `zef.inv_bg_data`; EEG lead-field difference between stored `L_EEG_1` and `L_EEG_2`; amplitudes; **Store** / **Use** EIT or EEG lead fields (`zef.eit_sensitivity_tool_L_*`). Quantile widgets clip `zef.reconstruction`.

Volume weights: `zef_eit_sensitivity_tool_volume`.

## Scripting

```matlab
zef_eit_sensitivity_tool_import;
zef_eit_sensitivity_tool_substitute;
```
