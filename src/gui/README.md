# GUI (`src/gui`)

Everything you click: tool windows, menus, option dialogs, table callbacks, widget→`zef` copy, and the 3-D plot. Mathematics (mesh, lead field, inverse classes) lives elsewhere; this tree opens windows and calls those functions. `zef_start` opens core tools in order: segmentation → figure → mesh → mesh visualization → menu → `zef_update`. The Figure tool is the unified application window; the Menu tool figure stays hidden and hosts the live `uimenu` tree that the left nav flyouts invoke.

## Main contents

| Folder | Open when you need to… |
|--------|-------------------------|
| `tools/` | How each window is created and which button calls what |
| `apps/` | App Designer layout only (`*_app_exported.m` = labels, no logic) |
| `callbacks/` | Add/delete compartment, sensors, transforms, locks, profile apply |
| `update/` | `zef_update_*`: one widget family → `zef` (often replot) |
| `plot/` | Draw into `zef.h_axes1` |
| `init/` | Seed tables and option-dialog defaults from `zef` / profile INIs |
| `open/` | **Settings** dialogs, plus `zef_open_class_inverse` for Inverse-tools **(class solver)** menus |
| `set/` | Apply `zef` to graphics (lights, colors, slider reset) |
| `chrome/` | Theme, layout, window manager, themed controls |

## Code functionality

| Window title | Created by | Typical job |
|--------------|------------|-------------|
| Segmentation tool | `tools/zef_segmentation_tool.m` | Compartments, sensor sets, affine transforms |
| Figure tool | `tools/zef_figure_tool.m` | 3-D axes (`h_axes1`), color sliders, movie |
| Mesh tool | `tools/zef_mesh_tool.m` | Create FEM mesh, Run script |
| Mesh visualization tool | `tools/zef_mesh_visualization_tool.m` | Volume/surfaces, camera, contours |
| Menu bar | `tools/zef_menu_tool.m` | Project / Import / Export / Edit / plugins / Window |
| Parcellation tool | `tools/zef_parcellation_tool.m` | Lazy: **Multi-tools → Parcellation tool** |

Click path: App Designer UIFigure → `tools/*` copies widgets onto `zef.h_*` and sets callbacks → string callbacks run in base workspace → `update/*` or `zef_update` → `plot/*` draws. Figure tool is **not** App Designer (`figure` / `uicontrol` + `assignin`).

Closing a tool usually only sets `Visible='off'`. **Project → Exit** deletes them. **Window → …** tiles or shows hidden tools.

## Workflow context

Exact button and menu labels: `tools/README.md` (verified from App Designer `Text=` and `MenuSelectedFcn`). Most plotters use `evalin('base','zef')`. Functions that take `zef` with `nargout==0` typically `assignin('base','zef',zef)`.

## Usage instructions

```matlab
zef = zeffiro_interface;
zef.h_mesh_tool = zef_window_visible(zef, zef.h_mesh_tool);  % show a hidden tool
zef = zef_update(zef);
```

`start_mode` `'nodisplay'` still constructs hidden figures. For batch work, call the same functions the buttons call rather than poking `h_*`.

## Important notes

- Mixing a local `zef` never assigned back to base makes the next click see stale state.
- Chrome / docking: [`chrome/README.md`](chrome/README.md). Units and `zef` fields: [docs/conventions.md](../../docs/conventions.md), [docs/zef-state.md](../../docs/zef-state.md).

## Developer guidance

New tool: export in `apps/`, wrapper in `tools/`, events in `callbacks/`, sync in `update/`, menu entry in `zef_menu_tool.m` or `zeffiro_plugins.ini`. Always end table mutations with `zef_update` (or matching `zef_update_*`). R2025a+ docking: `chrome/zef_window_manager.m`.
