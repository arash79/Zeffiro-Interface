# Apply `zef` → graphics (`src/gui/set`)

## Folder purpose

Helpers that **push `zef` state onto graphics objects** (figure tool axes, colorbars, lights, window geometry). Opposite direction from `src/gui/update` (widgets → `zef`).

## Main contents

| File | Role |
|------|------|
| `zef_set_size_change_function` | Hook `SizeChangedFcn` → `zef_change_size_function` |
| `zef_set_sliders_plot` / `zef_set_sliders_print` | Init time/colorscale sliders for plot vs print |
| `zef_set_compartment_color` / `zef_set_sensor_color` | Patch/line colors from table selections |
| `zef_set_lights` | Scene lighting from slider vector |
| `zef_set_surface_resolution` / `zef_set_timepointline` | Mesh/time UI helpers |
| `zef_set_position` | Segmentation tool window placement |
| `zef_set_figure_current_size` | Figure-tool window geometry bookkeeping |

## Code functionality

Called after plot creation or when the user changes a color/light control that should immediately affect existing patch objects. Uses `zef.h_axes1`, `zef.h_zeffiro`, and findobj on tagged graphics.

## Workflow context

Used heavily from `zef_figure_tool`, `zef_menu_tool`, and post-resize hooks. Plotters in `src/gui/plot` create geometry; `set/` adjusts appearance without rebuilding meshes.

## Usage instructions

```matlab
zef_set_lights(zef);           % typical pattern after slider change
zef_set_compartment_color(zef);
```

Usually invoked from callbacks, not typed by end users.

## Important notes

- Requires valid figure handles (`h_zeffiro`, `h_axes1`) — call after figure tool exists.
- Print vs plot slider init differ (`zef_set_sliders_print` for publication snapshots).

## Developer guidance

- Keep color application consistent with compartment table columns (RGB in `zef`).
- New figure-tool chrome: add a `zef_set_*` rather than embedding graphics code in update scripts.
- Coordinate with `zef_change_size_function` in `src/gui/chrome` for responsive layouts.
