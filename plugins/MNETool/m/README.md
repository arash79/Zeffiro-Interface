# MNETool / m

## Folder purpose

MATLAB scripts for the legacy **Minimum norm estimation** GUI plugin (Inverse tools). Builds the MNE window, syncs `zef.mne_*` options, and runs MNE / dSPM / sLORETA / wMNE on `zef.L`. Parallel class path is `inverse.MNEInverter` via `zef_inverse_run`; this folder does not construct that object.

## Main contents

| File | Role |
|------|------|
| `zef_minimum_norm_estimation.m` | INI menu callback |
| `zef_mne_tool_start.m` | Opens window, fonts, `zef_init_mne` |
| `zef_mne_tool_window.m` | GUIDE dump; widgets + Start callback |
| `zef_init_mne.m` / `zef_update_mne.m` | Defaults ↔ widgets → `mne_*` / `inv_time_*` |
| `zef_find_mne_reconstruction.m` | Solver |

## Code functionality

- Menu → `zef_tool_start` → `zef_mne_tool_start` → `zef_mne_tool_window` + `zef_init_mne`.
- Start: `zef_update_mne` then `[zef.reconstruction, zef.reconstruction_information] = zef_find_mne_reconstruction(zef)`.
- Solver reads `zef.mne_type` (1 MNE, 2 dSPM, 3 sLORETA, 4 wMNE), `zef.mne_prior`, SNR/`inv_snr`, copies time/filter fields, calls `zef_processLeadfields` / `zef_getFilteredData`, optional GPU.
- Key fields: `zef.mne_*`, `zef.L`, `zef.measurements`, `zef.source_direction_mode`.

## Workflow context

After lead field and measurements exist, open Inverse tools → Minimum norm estimation tool, set prior/type/band/time, Start. Result lands in `zef.reconstruction` for mesh visualization or downstream tools (GMM, parcellation).

## Usage instructions

1. Ensure `zef.L` and `zef.measurements` are set.
2. Run menu callback or `zef_minimum_norm_estimation(zef)`.
3. Choose type/prior, frames (`mne_number_of_frames`, `mne_time_*`), Apply or Start.
4. Inspect `zef.reconstruction` / `reconstruction_information` (tag/type from `mne_type`).

## Important notes

- Filter widgets write `inv_high_pass` / `inv_low_pass`, but filtering often reads `inv_*_cut_frequency`; set those if band-pass must change.
- Cancel callback may still name `h_ias_map_estimation` in older dump strings—prefer live Start wiring in the window file.

## Developer guidance

Keep Start binding in the window dump; `zef_mne_tool_start` documents that it does not rebind Start. Prefer editing `zef_find_mne_reconstruction` for estimator math; use `inverse.MNEInverter` for the class-based pipeline. Scripts `zef_init_mne` / `zef_update_mne` expect workspace `zef` with `h_mne_*` handles.
