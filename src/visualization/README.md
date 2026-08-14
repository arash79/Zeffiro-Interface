# Graphs and parcel time-series (`src/visualization`)

Small plotting helpers used by the **Mesh visualization tool** (histogram-style graphs on `h_axes1`) and by the **Parcellation tool** (**Plot** button).

This is not the main 3-D renderer. Volume/surface drawing is `src/gui/plot` (`zef_plot_volume`, `zef_visualize_volume`, …).

## Mesh visualization → Plot graph

In **ZEFFIRO Interface: Mesh visualization tool**, the **Graph:** list is filled from every `.m` file next to `zef_histogram` (`src/visualization/graph_bank`). The list *text* is each file’s MATLAB `help`. **Plot graph** runs `zef_plot_graph`, which `feval`s the selected file on the currently chosen **Parameter:** vector.

Verified button: **Plot graph** → `zef_plot_graph` (`zef_mesh_visualization_tool.m`).

| File | What it draws on `zef.h_axes1` |
|------|--------------------------------|
| `graph_bank/zef_histogram.m` | Histogram of `log10(parameter_vec)`, 200 bins |
| `graph_bank/zef_logarithmic_distribution.m` | Same bins, then `plot` of `log10(counts)` |
| `graph_bank/zef_logarithmic_histogram.m` | Histogram of `log10(parameter_vec)` with log y-axis. **Filename vs function:** the file is `zef_logarithmic_histogram.m` but the first function line is named `zef_logarithmic_distribution` — MATLAB calls it by filename. |
| `graph_bank/zef_plot_dof_space.m` | `scatter3` of `zef.source_positions` (hold on) |

These functions `evalin('base','zef.h_axes1')` and `cla` the axes. They need a live Figure tool.

## Parcellation → Plot

**Parcellation tool → Plot** calls `zef_plot_parcellation_time_series`, which reads `zef.parcellation_time_series` and `feval`s the selected `time_series_tools` function.

Each tool is:

```matlab
[y_vals, plot_mode] = zef_<name>(time_series)
```

`plot_mode` tells the plotter how to draw:

| `plot_mode` | Meaning |
|-------------|---------|
| 1 | One value per ROI (bar / stem) |
| 2 | ROI×ROI matrix (imagesc-style) |
| 3 | Full time courses |
| 4 | Cell of samples per ROI (boxplot); `zef_parcellation_boxplot_amplitude` only |

`zef_init_parcellation` builds the list labels from a `Description:` line in each file’s help. Without that line the list entry is empty.

**Scaling in the filename is not always what the file does.** Documented from the body:

| File | Actual computation | `plot_mode` |
|------|--------------------|-------------|
| `zef_max_energy_mean_scaling` | divide by `mean`, then `mean(...,2)` | 1 |
| `zef_max_energy_max_scaling` | (see file) max along dim 2 after scale | 1 |
| `zef_max_energy_no_scaling` | `max(...,[],2)` — no extra scale | 1 |
| `zef_mean_energy_mean_scaling` | mean-scale then mean | 1 |
| `zef_mean_energy_max_scaling` | max-scale then mean | 1 |
| `zef_mean_energy_no_scaling` | **mean-scale then `std`** (not mean energy) | 1 |
| `zef_std_mean_scaling` | **max-scale** then `std` | 1 |
| `zef_std_max_scaling.m` | max-scale then `std`; inner `function` name is `zef_std_no_scaling` | 1 |
| `zef_std_no_scaling.m` | **mean-scale then `corr`** (not std) | 2 |
| `zef_corr_*` | `corr(time_series')`; NaNs → 1 | 2 |
| `zef_corr_max_scaling_max_weighting` | **mean-scale then `cov`** (not weighted corr) | 2 |
| `zef_cov_mean_scaling` / `_max_scaling` | `cov(time_series')` after scale | 2 |
| `zef_cov_no_scaling` | **DTW matrix, not covariance** | 2 |
| `zef_dtw_*` | pairwise `dtw`; `_mean_scaling` actually divides by `max` | 2 |
| `zef_corr_mean_scaling_mean_weighting` | max-scale, `corr`, then `D*y*D` | 2 |
| `zef_time_series_plot` | `time_series/max(...)` | 3 |
| `zef_time_series_plot_sqrt` | `sqrt` of that | 3 |
| `zef_parcellation_boxplot_amplitude` | cell of `abs` samples; needs cell `time_series` | 4 |

The Parcellation tool also has a hardcoded **Plot type:** popup (`Maximum energy, Mean scaling`, …). **Plot** does **not** use that popup; it uses `h_time_series_tools_list`. The popup only stores `zef.parcellation_plot_type`.

## Scripting

```matlab
% After a reconstruction and parcellation interpolation
ts = zef_parcellation_time_series(zef);
[y, mode] = zef_max_energy_no_scaling(ts);
zef_histogram(zef.sigma(:,1));   % needs figure tool axes
```

## Developer notes

- Graph-bank files are discovered by `dir` next to `zef_histogram`; adding a file adds a **Graph:** item.
- Time-series tools: add `Description: <label>` in the help or the Parcellation list will not show a name.
- Do not “fix” filename/function mismatches here without updating callers; MATLAB dispatches on the filename.
