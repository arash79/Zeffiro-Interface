# GUI layer (`src/gui`)

This is everything you click: tool windows, menus, option dialogs, table callbacks, widget→`zef` copy, and the 3-D plot. Mathematics (mesh, lead field, inverse classes) lives elsewhere; this tree opens windows and calls those functions.

`zef_start` opens the core tools in this order: segmentation → figure → mesh → mesh visualization → menu → `zef_update`.

## Windows you actually see

| Window title | Created by | Typical job |
|--------------|------------|-------------|
| **ZEFFIRO Interface: Segmentation tool** | `tools/zef_segmentation_tool.m` | Compartments, sensor sets, affine transforms |
| **ZEFFIRO Interface: Figure tool** | `tools/zef_figure_tool.m` | 3-D axes (`zef.h_axes1`), color sliders, movie |
| **ZEFFIRO Interface: Mesh tool** | `tools/zef_mesh_tool.m` | Create FEM mesh, Run script (forward table) |
| **ZEFFIRO Interface: Mesh visualization tool** | `tools/zef_mesh_visualization_tool.m` | Visualize volume/surfaces, camera, contours |
| Menu bar | `tools/zef_menu_tool.m` | Project / Import / Export / Edit / plugins / Window |
| **ZEFFIRO Interface: Parcellation tool** | `tools/zef_parcellation_tool.m` | Lazy: **Multi-tools → Parcellation tool** |

Closing a tool usually only sets `Visible='off'`. **Project → Exit** (`zef_close_all`) deletes them. **Window → …** tiles or shows hidden tools (`zef_window_manager`, `zef_arrange_windows`, `zef_window_visible`).

Exact button and menu labels: `tools/README.md` (verified from App Designer `Text=` and `MenuSelectedFcn`). Do not invent names from an old screenshot.

## Subfolders (open the child README)

| Folder | Open when you need to… |
|--------|-------------------------|
| `tools/` | How each window is created and which button calls what |
| `apps/` | App Designer layout only (`*_app_exported.m` = labels, no logic) |
| `callbacks/` | Add/delete compartment, sensors, transforms, locks, profile apply |
| `update/` | `zef_update_*`: one widget family → `zef` fields (and often a replot) |
| `plot/` | Draw into `zef.h_axes1` (`zef_plot_volume`, visualize volume/surfaces) |
| `init/` | Seed tables and option-dialog defaults from `zef` / profile INIs |
| `open/` | **Settings** menu: forward/inverse options, graphics, profiles, plugins |
| `set/` | Apply `zef` to graphics (lights, colors, slider reset, menu size) |
| `helpers/` | Window manager, waitbar helpers, colormaps, interpolation, import |

## How a click becomes `zef`

```
App Designer UIFigure (apps/)
  → tools/* copies widgets onto zef.h_* and sets ButtonPushedFcn / MenuSelectedFcn
  → string callbacks run in the base workspace (where zef lives)
  → update/* or zef_update copies values into zef
  → plot/* reads zef from base and draws
```

The Figure tool is **not** App Designer; it is built with `figure` / `uicontrol` in `zef_figure_tool.m` and `assignin('base','zef',zef)` so those string callbacks see the session.

## Scripting vs clicking

`start_mode` `'nodisplay'` still constructs hidden figures. For batch work, call the same functions the buttons call (`zef_create_finite_element_mesh`, `zef_lead_field_matrix`, …) rather than poking `h_*`.

```matlab
zef = zeffiro_interface;
zef.h_mesh_tool = zef_window_visible(zef, zef.h_mesh_tool);  % show a hidden tool
zef = zef_update(zef);
```

## Workspace contract

Most plotters and menu strings use `evalin('base','zef')`. Mixing a local `zef` that is never assigned back to base will make the next click see stale state. Functions that take `zef` and have `nargout==0` typically `assignin('base','zef',zef)`.

## Developer notes

- New tool: export in `apps/`, wrapper in `tools/`, events in `callbacks/`, sync in `update/`, menu entry in `zef_menu_tool.m` or `zeffiro_plugins.ini`.
- Always end table mutations with `zef_update` (or the matching `zef_update_*`).
- `zef_plot_volume.m.m` is a leftover duplicate filename; use `zef_plot_volume.m`.
- R2025a+ docking: `helpers/zef_window_manager.m`.
