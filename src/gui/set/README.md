# Apply `zef` to graphics (`src/gui/set`)

The inverse of `update/`: push session fields onto figures (colors, lights, sizes). Not the place that *reads* sliders.

**Set position** and **Toggle controls** on the Segmentation tool are wired in `zef_segmentation_tool.m` (`h_set_position`, `h_segmentation_tool_toggle`). Figure-tool **Reset** lives in `tools/zef_set_figure_tool_sliders.m` (`set_mode==0` writes factory slider values).

The Figure-tool **Compartments:** / **Sensors:** lists are `zef_colored_list` widgets (`Trigger=buttondown`). A click runs `zef_set_compartment_color` / `zef_set_sensor_color`, then the caller runs `zef_update`. Details has no swatches (`ShowSwatches=false`). See `src/gui/helpers/README.md`.

| File | Kind | Trigger | What it applies |
|------|------|---------|-----------------|
| `zef_set_compartment_color` | function | Figure **Compartments:** `ButtonDownFcn` | `uisetcolor` → `zef.<tag>_color` (on+visible tags, reverse order). Caller runs `zef_update` |
| `zef_set_sensor_color` | function | **Sensors:** `ButtonDownFcn` | row of `*_color_table` |
| `zef_set_color` | function | legacy compartment list `h_compartment_color` | same write, different list |
| `zef_set_lights` | function | after plot / print | recreate Light objects from `zef.update_lights` codes on `h_axes1` (or passed axes) |
| `zef_set_sliders_plot` | function | end of `zef_plot_volume` / `zef_plot_meshes` | re-apply colormap, ColorScale, transparency κ, zoom, lights so new patches match sliders. Mode 2 = rec transparency only |
| `zef_set_sliders_print` | function | `zef_print_meshes` | same chain on the print figure |
| `zef_set_linear_colorbar_ticks` | function | log reconstruction colorbar | labels = `max_val * 10^((tick-Limits(2))/20)` (undo 20*log10) |
| `zef_set_timepointline` | function | butterfly / volume time click | vertical Tag=`timepointline` |
| `zef_set_position` | function | Segmentation **Set position** | write `segmentation_tool_default_position` to `zeffiro_interface.ini` |
| `zef_set_menu_size` | function | after each `MenuSelectedFcn` | `'expanded'` / `'minimized'` vs measured min height (not `Position(4)==0`) |
| `zef_set_size_change_function` | function | tools at creation | SizeChangedFcn → `zef_window_manager('on_size_changed', src)` |
| `zef_set_figure_current_size` | **script** | Figure-tool resize | store normalized size in `zef.zeffiro_current_size` |
| `zef_set_surface_resolution` | function | before surface patches | refine or `reducepatch` to target face count |
