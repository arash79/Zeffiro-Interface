# profile / multicompartment_head_nse

## Folder purpose

Zeffiro **startup profile** for multi-compartment head models with extra **Navier–Stokes / microvessel** parameter rows. Selects which plugins, default modalities, segmentation columns, material parameters, and forward lead-field recipes load when this profile is active.

## Main contents

| File | Role |
|------|------|
| `zeffiro_init.ini` | Plot size, modalities (EEG/MEG), CEM electrode factory |
| `zeffiro_plugins.ini` | Menu → callback map (inverse/multi/forward tools) |
| `zeffiro_parameters.ini` | Material/sensor parameter table (incl. NSE extras) |
| `zeffiro_segmentation.ini` | Compartment table column template |
| `zeffiro_forward_simulation.ini` | Named lead-field builders (iso/aniso EEG/MEG/EIT/tES) |

No `.m` files in this folder—INI data only.

## Code functionality

- Startup / profile switch reads these INIs into `zef` (plugins list, parameter definitions, forward method strings).
- `zeffiro_parameters.ini` enables `sigma`, and adds `mvd_length` (microvessel density, default 200 Count/mm³) and `nse_sigma` (NSE conductivity, default 0 S/m, On but not written from segmentation).
- Plugins include IAS, MNE, Dipole Scan, Kalman (`zef_kf_start`), Dynamical plot queue, GMM (SP/JL), and **NSE tool** (`zef_nse_tool_start`).
- Forward INI lists isotropic/anisotropic lead-field entry points (`zef_eeg_lead_field_isotropic`, …).

## Workflow context

Choose this profile when meshing a multi-compartment head and using NSE / microvessel fields (`src/forward/nse`). Plugin set aligns with `multicompartment_head_legacy` plus NSE. Segmentation INI is an empty template—import anatomy separately.

## Usage instructions

1. In the segmentation tool, set **Profile** to `multicompartment_head_nse` (or start Zeffiro with this profile selected).
2. Apply/reload INIs so parameters and plugins refresh.
3. Import compartments; set `sigma` / `mvd_length` as needed.
4. Use Forward simulation rows for EEG/MEG/EIT/tES; open **NSE tool** for NSE-specific solves (not launched by the forward-simulation table alone).

## Important notes

- `nse_sigma` is On in the parameter table but Off for “write from segmentation”—set explicitly if used.
- Many “legacy” inverse plugins remain available; NSE does not replace MNE/IAS.
- Changing plugins here does not move code—only which start scripts appear in menus.

## Developer guidance

Keep parameter CSV column order consistent with other `profile/*/zeffiro_parameters.ini` files. When adding NSE-related fields, document defaults here and wire UI in the NSE tool, not only in this INI. Parent overview: [`../README.md`](../README.md).
