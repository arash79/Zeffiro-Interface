# `utilities.plotting` — paper-style figure export

Helpers used by `+examples/+studies` to dump Figure-tool windows without colorbars, or to draw custom whisker box plots. Not wired to a Zeffiro menu.

```matlab
% Hide colorbars on an open figure and write stem + suffix:
utilities.plotting.figure_without_colorbar_fn(fig, "out/fig1", [".png"; ".pdf"], 400);

% Recurse *.fig under a folder:
utilities.plotting.figures_from_folder_without_colorbars("paper_figs", [".png"; ".pdf"], 400);

% Standalone colorbar from Zeffiro Figure tool (tag rightColorbar):
utilities.plotting.colorbar_from_figtool_fn(figtool, "cbar", [".png"], "fontsize", 20);

% Groups in data_cells; outlier_limits(i) sets the upper whisker for group i:
[fig, ax] = utilities.plotting.box_plots_with_differing_whiskers_fn( ...
    data_cells, outlier_limits, x_tick_labels, "x", "y");
```

`figure_without_colorbar_fn` sets every colorbar `Visible=false` then `exportgraphics` (side effect: source figure stays without visible colorbars). Allowed suffixes: `.pdf`, `.eps`, `.png`. `colorbar_from_figtool_fn` also allows those three; filename stem must be a valid MATLAB variable name.
