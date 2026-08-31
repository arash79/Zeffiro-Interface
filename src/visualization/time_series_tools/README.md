# src/visualization/time_series_tools

## Folder purpose

**Transforms only** for the Parcellation tool’s **Plot** path. Each file maps a parcel time-series matrix to display data and a `plot_mode` code. These functions do **not** open figures; drawing is `src/gui/plot/zef_plot_parcellation_time_series.m`. Separate from Mesh-visualization **Graph** tools (`src/visualization/graph_bank`).

## Main contents

Every `.m` in this folder is a Plot-list candidate. Labels come from the `Description:` help line.

| File | Family (see notes for filename ≠ math) |
|------|----------------------------------------|
| `zef_time_series_plot.m` / `zef_time_series_plot_sqrt.m` | Full curves (`plot_mode` 3) |
| `zef_max_energy_no_scaling.m` / `_mean_scaling.m` / `_max_scaling.m` | Per-ROI energy (`plot_mode` 1) |
| `zef_mean_energy_no_scaling.m` / `_mean_scaling.m` / `_max_scaling.m` | Mean-energy family (see mismatch table) |
| `zef_corr_no_scaling.m` / `_mean_scaling.m` / `_max_scaling.m` / `_mean_scaling_mean_weighting.m` / `_max_scaling_max_weighting.m` | Correlation matrices (`plot_mode` 2) |
| `zef_cov_no_scaling.m` / `_mean_scaling.m` / `_max_scaling.m` | Covariance / DTW family (see mismatch table) |
| `zef_dtw_no_scaling.m` / `_mean_scaling.m` / `_max_scaling.m` | Dynamic time warping matrices |
| `zef_std_no_scaling.m` / `_mean_scaling.m` / `_max_scaling.m` | Std-named family (see mismatch table) |
| `zef_parcellation_boxplot_amplitude.m` | Boxplot (`plot_mode` 4) |

The Parcellation list is built by `zef_init_parcellation`: `dir` of this folder; list label comes from the help line `Description: …`.

## Code functionality

Contract for every tool:

```matlab
[y_vals, plot_mode] = zef_<name>(time_series);
```

| `plot_mode` | Meaning in the plotter |
|-------------|------------------------|
| 1 | Bar / stem per ROI |
| 2 | ROI×ROI `imagesc` |
| 3 | Time curves |
| 4 | Boxplot samples (cell time series) |

**Input:** parcel time series from `zef_parcellation_time_series` → `zef.parcellation_time_series`.  
**Output:** transformed `y_vals` + mode for `feval` from the Plot button.

## Workflow context

```
reconstruction → zef_parcellation_time_series
    → Parcellation tool list (this folder)
    → Plot → zef_plot_parcellation_time_series → feval(selected)
```

Also used from analysis scripts under `+examples/+studies`.

## Usage instructions

GUI: open **Parcellation tool** → select a time-series tool → **Plot**.

```matlab
% After parcels + reconstruction exist:
ts = zef.parcellation_time_series;
[y, mode] = zef_time_series_plot(ts);
```

Re-open / re-init the Parcellation tool after adding a new `.m` so `dir` refreshes the list.

## Important notes

**Filename ≠ math** in several legacy files — trust the `Description:` help line and function body:

| File | Actual behavior (summary) |
|------|---------------------------|
| `zef_cov_no_scaling` | DTW matrix |
| `zef_std_no_scaling` | mean-scale then `corr` |
| `zef_mean_energy_no_scaling` | mean-scale then STD |
| `zef_dtw_mean_scaling` | Description mentions max scaling |
| `zef_std_max_scaling.m` | inner function still named `zef_std_no_scaling` |

The separate **Plot type** popup stores `parcellation_plot_type` but the Plot button uses the tools list, not that popup.

## Developer guidance

- Add a new tool as `zef_*.m` with a `Description:` help line and the `[y_vals, plot_mode]` contract.
- Prefer renaming for clarity only with a compatibility wrapper — the list is filename-driven.
- Pitfall: opening figures inside a tool file (breaks the Plot dispatcher).
