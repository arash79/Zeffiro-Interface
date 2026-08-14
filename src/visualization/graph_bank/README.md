# Graph bank (`src/visualization/graph_bank`)

These files are the **Graph:** dropdown in **ZEFFIRO Interface: Mesh visualization tool**. `zef_plot_graph` lists every `.m` next to `zef_histogram` and uses MATLAB `help` of each file as the visible label. **Plot graph** `feval`s the selected file. Adding a new `.m` here adds a list item; no INI edit.

They are **not** the 3-D renderer. Volume/surface drawing is `src/gui/plot`. Parcellation **Plot** uses `src/visualization/time_series_tools/`, not this folder.

## What they need

A live Figure tool (`zef.h_axes1`). Histogram-style files `cla` that axes first. Input is the currently selected Mesh-vis **Parameter:** vector (`zef_plot_graph` passes it). `zef_plot_dof_space` ignores that vector and scatters `zef.source_positions` (`hold on`); source interpolation must already have run.

## What each file actually draws

| File | Axes | Computation |
|------|------|-------------|
| `zef_histogram.m` | `cla` then histogram | `log10` of the parameter vector, 200 bins |
| `zef_logarithmic_distribution.m` | `cla` then `plot` | Same bins, then `log10(counts)` |
| `zef_logarithmic_histogram.m` | `cla` then histogram | `log10` of the parameter, log y-axis. **Filename vs function:** the first function line is named `zef_logarithmic_distribution`; MATLAB still calls it by filename. |
| `zef_plot_dof_space.m` | `hold on` scatter3 | `zef.source_positions` (dummy argument unused) |

Parent table of Parcellation time-series tools (a different **Plot** button): [`../README.md`](../README.md).

```matlab
% Needs a live Figure tool
zef_histogram(zef.sigma(:,1));
zef_plot_dof_space([]);   % dummy arg unused
```
