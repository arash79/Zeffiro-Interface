# src/visualization/time_series_tools

## Folder purpose

**Transforms only** for the Parcellation tool’s **Plot** path. Each file maps a parcel time-series matrix to display data and a `plot_mode` code. These functions do **not** open figures; drawing is `src/gui/plot/zef_plot_parcellation_time_series.m`. Separate from Mesh-visualization **Graph** tools (`src/visualization/graph_bank`).

## Main contents

| Family | Representative files | Typical `plot_mode` |
|--------|----------------------|---------------------|
| Full curves | `zef_time_series_plot`, `zef_time_series_plot_sqrt` | 3 |
| Energy (per-ROI scalar) | `zef_max_energy_*`, `zef_mean_energy_*` | 1 |
| Corr / cov / DTW matrices | `zef_corr_*`, `zef_cov_*`, `zef_dtw_*` (+ weighting variants) | 2 |
| Std-named family | `zef_std_*` | 1 or 2 (see notes) |
| Boxplot | `zef_parcellation_boxplot_amplitude` | 4 |

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

Also used from analysis scripts (Kalman helpers, `kalman_custom_q_driver.m`, compartment studies).

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
