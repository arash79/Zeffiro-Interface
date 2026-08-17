# `utilities.plotting` — paper-style figure export

## Folder purpose

Helpers used by `+examples/+studies` to dump Figure-tool windows without colorbars, or to draw custom whisker box plots. Not wired to a Zeffiro menu.

## Main contents

| Function | Role |
|----------|------|
| `figure_without_colorbar_fn` | Hide colorbars on an open figure; `exportgraphics` |
| `figures_from_folder_without_colorbars` | Recurse `*.fig` under a folder |
| `colorbar_from_figtool_fn` | Standalone colorbar from Figure tool (`rightColorbar` tag) |
| `box_plots_with_differing_whiskers_fn` | Grouped box plots with per-group upper whisker limits |

## Code functionality

`figure_without_colorbar_fn` sets every colorbar `Visible=false` then exports (side effect: source figure stays without visible colorbars). Allowed suffixes: `.pdf`, `.eps`, `.png`. `colorbar_from_figtool_fn` also allows those three; filename stem must be a valid MATLAB variable name. Box-plot helper takes `data_cells`, `outlier_limits`, and tick labels.

## Workflow context

Paper/study figure export after interactive Figure-tool work, or standalone statistical plots. Not part of mesh / lead-field / inverse computation.

## Usage instructions

```matlab
utilities.plotting.figure_without_colorbar_fn(fig, "out/fig1", [".png"; ".pdf"], 400);

utilities.plotting.figures_from_folder_without_colorbars("paper_figs", [".png"; ".pdf"], 400);

utilities.plotting.colorbar_from_figtool_fn(figtool, "cbar", [".png"], "fontsize", 20);

[fig, ax] = utilities.plotting.box_plots_with_differing_whiskers_fn( ...
    data_cells, outlier_limits, x_tick_labels, "x", "y");
```

## Important notes

Exporting without colorbars mutates visibility on the source figure. Resolution argument (e.g. 400) is passed through to `exportgraphics` where applicable.

## Developer guidance

Keep study-specific styling in callers; keep this package limited to reusable export/plot helpers. Do not wire these to the menu bar unless a product requirement appears.
