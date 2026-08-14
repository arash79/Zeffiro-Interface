# Filter-bank stages (`m/filter_bank`)

Each `.m` file here is one row you can **Add** in **Forward tools → Filter tool**. The tool does not hard-code the list: `zef_init_filter_tool` (and Add) call `help()` on every file in this folder and parse:

- `Description:` — label shown in the stage list (sorted as the files are scanned)
- `Input: … [Default: …]` — parameter table rows
- `Output:` — unused for execution, required so the parser does not break

Do **not** remove those tags when editing help. Inverse methods still read `zef.measurements`; this pipeline writes `zef.processed_data`, and the Substitute buttons copy that onto measurements / raw / noise.

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

How to open the tool, Substitute-button name swap, and scripting: [parent README](../../README.md).
