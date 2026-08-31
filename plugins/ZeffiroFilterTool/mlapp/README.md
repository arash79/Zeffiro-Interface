# ZeffiroFilterTool — App Designer layouts

## Folder purpose

App Designer UI for the **Filter tool**: build an ordered FIR/IIR / referencing / epoching / channel pipeline and run it on imported raw time series so inverse tools can read `zef.measurements` (and optionally `zef.noise_data`).

## Main contents

| File | Role |
|------|------|
| `zeffiro_interface_filter_tool.mlapp` | Filter tool (Import, Plot, Add/Delete/Move stages, epoch points, substitute raw/measurements/noise, Load/Save) |
| `README.md` | This documentation |

MATLAB logic: `plugins/ZeffiroFilterTool/m/` (`zef_filter_tool`, `zef_filter_raw_data`, stages under `m/filter_bank/`).

## Code functionality

`zef_filter_tool` opens this app, sets font size / delete cleanup, and wires buttons to import raw data, edit `zef.filter_pipeline`, run the pipeline into `zef.processed_data`, and substitute into measurements / raw / noise. Stage list text comes from `help()` of `filter_bank` files (`Description:`, `Input: … [Default: …]`, `Output:`). Sampling-rate widget writes `zef.filter_sampling_rate`.

## Workflow context

**Forward tools → Filter tool** (default `multicompartment_head`). Callback: `zef_filter_tool`. Title: **ZEFFIRO Interface: Filter tool**. Need `zef.raw_data` via Import or by copying measurements into raw first.

## Usage instructions

```matlab
zef_filter_tool;   % opens zeffiro_interface_filter_tool.mlapp
zef_import_raw_data;
zef_add_filter_item;
zef_filter_raw_data;   % → zef.processed_data
```

1. Import raw data (or substitute measurements into raw).
2. Build the pipeline (Add / reorder stages).
3. Plot / substitute into measurements or `noise_data`.

Edit UI only in App Designer.

## Important notes

- Substitute-measurements and substitute-raw handle names are swapped relative to the functions they call.
- Pipeline save/load is `.mat` v7.3, not JSON. Load uses the file chosen in the dialog.

## Developer guidance

- Preserve callback `zef_filter_tool`.
- New stages in `m/filter_bank/` must expose the required `help()` lines so Add can fill the parameter table.
- Keep button Tags in sync with `ButtonPushedFcn` wiring in `zef_filter_tool.m`.
