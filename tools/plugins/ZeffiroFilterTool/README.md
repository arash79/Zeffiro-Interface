## Folder purpose

Builds an ordered pipeline of FIR/IIR, referencing, epoching, and channel stages, then runs that pipeline on imported **raw** time series. Inverse tools still read `zef.measurements` (and optionally `zef.noise_data`); this window is how you get from a `.mat`/`.dat` dump to those fields.

## Main contents

- Start script: `m/zef_filter_tool.m`
- Pipeline runner: `m/zef_filter_raw_data.m`
- Stages: `m/filter_bank/*.m`
- Layout: `mlapp/zeffiro_interface_filter_tool.mlapp`

Stages live in `m/filter_bank/`. The list in the window is `help()` of those files: each stage must contain `Description:`, `Input: … [Default: …]`, and `Output:` so **Add** can fill the parameter table.

## Code functionality

Buttons (`ButtonPushedFcn` in `m/zef_filter_tool.m`):

| Button handle | Action |
|---------------|--------|
| Import data | `zef_import_raw_data` → `zef.raw_data` from `.mat`/`.dat` |
| Plot data | scroll bar + `zef_filter_raw_data` + `zef_filter_plot_data` (runs the pipeline into `zef.processed_data` and plots) |
| Add / Delete / Move up / Move down | edit `zef.filter_pipeline` |
| Load epoch points / Get epoch points / Reset epoch points | `zef.filter_epoch_points` (manual epoching) |
| Substitute raw with measurements | copy `zef.measurements` → `zef.raw_data` |
| Substitute measurements | confirm, run pipeline, write `zef.processed_data` → `zef.measurements` (or `zef.measurements{filter_data_segment}` if segment &gt; 0). Handle `h_filter_substitute_raw_data` calls `zef_filter_substitute_measurement_data` (names are swapped) |
| Substitute raw | confirm, run pipeline, `zef.raw_data = zef.processed_data`. Handle `h_filter_substitute_measurement_data` calls `zef_filter_substitute_raw_data` |
| Substitute noise | confirm, run pipeline, `zef.noise_data = zef.processed_data` |
| Load / Save as / Save processed / Reset | pipeline `.mat` (v7.3 `zef_data` of `filter_*` fields + `raw_data`; **not JSON**), processed export, reset widgets. **Save as** writes `filter_file_list` from `filter_name_list` as written. **Load** stores the dialog pick on `zef_data.file` then `load([zef.file_path zef.file])` — the project `zef.file`, not the dialog pick. |

Sampling rate widget writes `zef.filter_sampling_rate`. Filter-bank defaults named `filter_sampling_rate` pick that field up.

## Workflow context

**Forward tools → Filter tool** (default `multicompartment_head` profile). Callback: `zef_filter_tool` (script). Window title: **ZEFFIRO Interface: Filter tool**.

Need data in `zef.raw_data` (Import) or copy measurements into raw first.

## Usage instructions

```matlab
zef_import_raw_data;          % or assign zef.raw_data
zef_add_filter_item;          % after choosing a stage in the list
zef_filter_raw_data;          % zef.processed_data
zef.measurements = zef.processed_data;
```

Or call a stage directly, e.g. `zef_ellip_low_pass_filter(f, 3, 3, 80, 40, fs)`.

1. Import raw data (or substitute measurements into raw).
2. Build the pipeline (Add / reorder stages).
3. Plot / substitute into measurements or noise_data.

## Important notes

- Substitute-measurements and substitute-raw handle names are swapped relative to the functions they call.
- Pipeline save/load is `.mat` v7.3, not JSON.
- Load uses project `zef.file` / `zef.file_path`, not the dialog pick stored on `zef_data.file`.

## Developer guidance

Every new stage in `m/filter_bank/` must expose `Description:`, `Input: … [Default: …]`, and `Output:` in `help()` so Add can fill the parameter table. Keep callback `zef_filter_tool` stable.
