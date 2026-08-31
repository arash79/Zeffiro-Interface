## Folder purpose

Small plotting helpers used by the **Mesh visualization tool** (histogram-style graphs on `h_axes1`) and by the **Parcellation tool** (**Plot** button), plus Figure-tool colormaps and movie helpers. Not the main 3-D renderer — volume/surface drawing is `src/gui/plot`.

## Main contents

| Path | Role |
|------|------|
| `colormaps/` | Figure-tool LUTs (`zef_colormap`, `zef_*_colormap`) |
| `graph_bank/zef_histogram.m` | Histogram of `log10(parameter_vec)`, 200 bins |
| `graph_bank/zef_logarithmic_distribution.m` | Same bins, then `plot` of `log10(counts)` |
| `graph_bank/zef_logarithmic_histogram.m` | Log-y histogram of `log10(parameter_vec)` |
| `graph_bank/zef_plot_dof_space.m` | `scatter3` of `zef.source_positions` |
| `time_series_tools/` | Parcel statistics: `[y_vals, plot_mode] = zef_<name>(time_series)` |
| `zef_make_butterfly_plot.m` | Overlay filtered measurement traces vs time (Forward tools → Butterfly plot → **Plot**). Copies `zef.bf_*` onto `inv_*` then `zef_getFilteredData` / `zef_getTimeStep`. |
| `zef_store_cdata.m` | Append current axes1 `CData` onto each child's `UserData` while plotting (when `zef.store_cdata` is true). |
| `zef_play_cdata.m` | Figure-tool **Play** / time-slider replay of stored `CData` frames (`zef.stop_movie` aborts). |
| `zef_snapshot_movie.m` | **Script.** Mesh visualization **Frame / Movie**: `uiputfile` jpg/tif/png/avi then `zef_print_meshes`. |

## Code functionality

**Plot graph:** Mesh-vis **Graph:** list is filled from every `.m` next to `zef_histogram`; list text is each file’s MATLAB `help`. **Plot graph** → `zef_plot_graph` → `feval` on the selected parameter vector. Functions `evalin('base','zef.h_axes1')` and `cla` the axes — need a live Figure tool.

**Parcellation Plot:** `zef_plot_parcellation_time_series` reads `parcellation_time_series` and `feval`s the selected tool. `plot_mode`: 1 = one value/ROI; 2 = ROI×ROI matrix; 3 = full time courses; 4 = cell of samples (boxplot only). List labels come from a `Description:` line in each file’s help.

Documented filename vs body mismatches (do not “fix” lightly): e.g. `zef_mean_energy_no_scaling` does mean-scale then `std`; `zef_std_no_scaling.m` does mean-scale then `corr`; `zef_cov_no_scaling` is DTW; some `corr_*` / `dtw_*` scale differently than the name suggests. Table: [`time_series_tools/README.md`](time_series_tools/README.md).

The Parcellation **Plot type:** popup only stores `zef.parcellation_plot_type`; **Plot** uses `h_time_series_tools_list`.

## Workflow context

Mesh visualization **Plot graph** and Parcellation **Plot** are the only GUI entry points. `zef_init_parcellation` scans `time_series_tools` for list labels.

## Usage instructions

```matlab
ts = zef_parcellation_time_series(zef);
[y, mode] = zef_max_energy_no_scaling(ts);
zef_histogram(zef.sigma(:,1));   % needs figure tool axes
```

## Important notes

- Graph-bank files are discovered by `dir` next to `zef_histogram`; adding a file adds a **Graph:** item.
- Without a `Description:` line, the Parcellation list entry is empty.
- MATLAB dispatches on the filename when filename and `function` line disagree.

## Developer guidance

Do not rename mismatched files without updating callers. Prefer documenting actual computation over renaming for cosmetic consistency.
