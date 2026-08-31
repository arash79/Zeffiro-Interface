## Folder purpose

Filter-bank stages for **Forward tools → Filter tool**. Each `.m` file is one row you can **Add**. The tool does not hard-code the list: `zef_init_filter_tool` (and Add) call `help()` and parse tagged lines.

## Main contents

| File | `Description:` (list label) |
|------|-----------------------------|
| `zef_ellip_low_pass_filter.m` | Elliptic low-pass filter |
| `zef_ellip_high_pass_filter.m` | Elliptic high-pass filter |
| `zef_ellip_band_stop_filter.m` | Elliptic band-stop filter |
| `zef_zero_reference.m` | Set the reference (average) level to zero |
| `zef_electrode_reference.m` | Set a given electrode as a reference |
| `zef_select_channels.m` | Select channels |
| `zef_exclude_channels.m` | Exclude channels |
| `zef_define_time_interval.m` | Define time interval |
| `zef_constant_epoching.m` | Averaging over epochs with constant length |
| `zef_manual_epoching.m` | Averaging over manually selected epochs |
| `zef_threshold_epoching.m` | Averaging over epochs obtained via thresholding |
| `zef_simple_downsampling_filter.m` | Simple downsampling filter |
| `zef_simple_ica_cleaning.m` | Simple ICA for data cleaning |

## Code functionality

Required help tags:

- `Description:` — label in the stage list
- `Input: … [Default: …]` — parameter table rows
- `Output:` — unused for execution; required so the parser does not break

Stages transform filter-tool data; the pipeline runner writes `zef.processed_data`. Inverse methods still read `zef.measurements` until Substitute copies data across.

## Workflow context

Discovered by `../zef_init_filter_tool.m` / `zef_add_filter_item.m`. Parent Filter tool README covers open, run, save/load, and Substitute-button name swap.

## Usage instructions

Add stages from the Filter tool UI. To add a new stage, drop a `.m` here with the help tags above; no INI edit.

## Important notes

- Do not remove `Description:` / `Input:` / `Output:` tags when editing help.
- Label order follows how files are scanned / listed by init — not necessarily alphabetical.
- Epoching stages may depend on loaded epoch points (`zef_load_epoch_points`).

## Developer guidance

Keep stage functions pure on their declared inputs/outputs so the pipeline runner stays generic. Prefer Signal Processing Toolbox elliptics for IIR stages. Document new defaults in `Input:` lines.
