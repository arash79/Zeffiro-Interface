# Parcellation Plot transforms (`time_series_tools`)

Each file here is a small function

```matlab
[y_vals, plot_mode] = zef_<name>(time_series)
```

used by **Parcellation tool → Plot**. The plotter (`zef_plot_parcellation_time_series`) reads `zef.parcellation_time_series` (ROI × time, or a cell of samples) and `feval`s the selected file. These functions **do not open figures**; they only return arrays.

## How a user reaches this

1. Build a reconstruction (`zef.reconstruction`) and interpolate it onto parcels so `zef.parcellation_time_series` exists.
2. Open **Parcellation tool**.
3. The **time-series tools list** (`h_time_series_tools_list`) is filled at init from every `.m` in this folder. The visible label is the `Description:` line in that file’s MATLAB help (`zef_init_parcellation` searches `help`, then `strfind(...,'Description:')`, then `strtrim` of the rest). **If you omit `Description:`, the list entry is blank.**
4. Click **Plot**. That uses the list, **not** the **Plot type:** popup. The popup only stores `zef.parcellation_plot_type`.

## `plot_mode`

| Value | What the plotter draws |
|-------|------------------------|
| 1 | One number per ROI (bar / stem) |
| 2 | ROI × ROI matrix (`imagesc`-style) |
| 3 | Full time courses |
| 4 | Cell of samples per ROI (boxplot); only `zef_parcellation_boxplot_amplitude` |

## Filename vs formula

Several file names do not match the computation. **Do not trust the name.** The table of what each file actually computes is in the parent [../README.md](../README.md) (traced from the function bodies). Examples: `zef_cov_no_scaling` is DTW; `zef_std_no_scaling` is mean-scale then `corr`; `zef_mean_energy_no_scaling` is mean-scale then `std`.

## Adding a tool

1. Add `zef_my_summary.m` in this folder with a complete `function` signature, then help that includes a line `Description: My summary`.
2. Return `[y_vals, plot_mode]` as above.
3. Re-open or re-init the Parcellation tool so `dir` picks up the file.

Keep the `Description:` line. Other documentation in the help is fine; that one line is what the GUI parses.

## Scripting

```matlab
ts = zef_parcellation_time_series(zef);
[y, mode] = zef_max_energy_no_scaling(ts);   % max over time, plot_mode 1
```
