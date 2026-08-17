# src/visualization/graph_bank

## Folder purpose

Plot functions for the **Graph:** dropdown in **ZEFFIRO Interface: Mesh visualization tool**. They draw 1-D / scatter summaries of a selected parameter vector — **not** the 3-D volume/surface renderer (`src/gui/plot`).

## Main contents

| File | Axes | Computation |
|------|------|-------------|
| `zef_histogram.m` | `cla` then histogram | `log10` of the parameter vector, 200 bins |
| `zef_logarithmic_distribution.m` | `cla` then `plot` | Same bins, then `log10(counts)` |
| `zef_logarithmic_histogram.m` | `cla` then histogram | `log10` of the parameter, log y-axis. **Filename vs function:** first function line is named `zef_logarithmic_distribution`; MATLAB still calls it by filename |
| `zef_plot_dof_space.m` | `hold on` scatter3 | `zef.source_positions` (dummy argument unused) |

## Code functionality

- `zef_plot_graph` lists every `.m` next to `zef_histogram` and uses MATLAB `help` of each file as the visible label; **Plot graph** `feval`s the selected file.
- Adding a new `.m` here adds a list item — no INI edit.
- Histogram-style files clear the Figure-tool axes (`zef.h_axes1`) first; `zef_plot_dof_space` overlays source positions.

## Workflow context

Use after Mesh visualization tool is open and a **Parameter:** vector is selected. Parcellation **Plot** uses `src/visualization/time_series_tools/`, not this folder.

## Usage instructions

1. Open Figure tool and Mesh visualization tool; select a parameter vector.
2. Choose an entry under **Graph:** and click **Plot graph**.
3. Or from MATLAB (needs live Figure tool):

```matlab
zef_histogram(zef.sigma(:,1));
zef_plot_dof_space([]);   % dummy arg unused
```

## Important notes

- Input is the currently selected Mesh-vis **Parameter:** vector (`zef_plot_graph` passes it).
- `zef_plot_dof_space` ignores that vector; source interpolation must already have run.
- Filename/function-name mismatch in `zef_logarithmic_histogram.m` is intentional in this tree.

## Developer guidance

New graphs: add `zef_my_graph.m` with a `function` signature and useful `help` text (that help becomes the list label). Keep clearing vs `hold on` behavior explicit. Parent table of parcellation tools: [`../README.md`](../README.md).
