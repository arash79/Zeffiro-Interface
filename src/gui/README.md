# src/gui

## Folder purpose

The **interactive UI layer** of Zeffiro Interface (~249 `.m` files). Implements App Designer tool shells, menu wiring, event callbacks, widget-to-`zef` synchronization, and 3D plotting. Almost all user-facing behavior outside `tools/plugins` flows through this tree plus `src/core/zef_update.m`.

## Main contents

| Subfolder | Files | Role |
|-----------|-------|------|
| `apps/` | 5 exported classdefs + `.mlapp` sources | App Designer UIFigures (`*_app_exported.m`) — layout only, no business logic |
| `tools/` | 14 | Lifecycle wrappers: create tools, copy `h_*` into `zef`, wire callbacks |
| `callbacks/` | 48 | Discrete actions: add/delete compartment, sensors, transforms, toggles |
| `init/` | 20 | Default fields and UITable seeding from profile INIs |
| `open/` | 8 | Launch modal option dialogs (`zef_open_*`) |
| `update/` | 35 | Push widget values into `zef` (`zef_update_*`) |
| `set/` | 13 | Apply `zef` state to graphics (colors, lights, sliders) |
| `plot/` | 19 | Render into `zef.h_axes1` / butterfly figures |
| `helpers/` | ~90 | Colormaps, interpolation, import helpers, window management |

## Code functionality

**Architecture (handle-oriented MVC):**
```
apps (UIFigure) → tools (wire callbacks, zef.h_*)
  → callbacks / open dialogs
  → update/* + zef_update (widget → zef)
  → plot/* (zef → h_axes1)
```

**Startup** (`zef_start.m`): `zef_segmentation_tool` → `zef_figure_tool` → `zef_mesh_tool` → `zef_mesh_visualization_tool` → `zef_menu_tool` → `zef_update`.

**Workspace contract:** most plotters and callbacks use `evalin('base','zef')` or string callbacks evaluated in base. `zef_figure_tool` explicitly `assignin('base','zef',zef)`.

**Central sync:** `zef_update` reads compartment/sensor/parameter tables via `zef_get_data_compartment_table` and refreshes window titles on all `ZEFFIRO Interface:*` figures.

## Workflow context

| Partner | Interaction |
|---------|-------------|
| `src/core` | `zef_update`, `zef_arrange_windows`, `zef_waitbar`, `zef_plugin` |
| `src/io` | Menu load/save/import calls |
| `src/forward` | Mesh tool runs `zef_*_make_all`; visualization after forward |
| `src/inverse` | Inverse option dialogs set `zef.inv_*` fields |
| `tools/plugins` | Plugin menus attached by `zef_plugin`; callbacks often `eval` plugin start scripts |
| `+core` | `import_electrodes_callback` wired in `zef_menu_tool.m` |

## Usage instructions

```matlab
zef = zeffiro_interface;   % opens all core tools

% Reopen a hidden tool
zef_window_visible(zef, 'zef_mesh_tool', 1);

% Open forward/inverse options
zef_open_forward_and_inverse_options;

% Refresh after programmatic zef edits
zef = zef_update(zef);
```

Key tools: **Segmentation** (compartments/sensors), **Mesh** (FEM + forward table), **Menu** (project I/O, plugins), **Figure** (3D recon), **Mesh visualization** (contour/camera/plot buttons).

## Important notes

- **Figure tool is not App Designer** — built programmatically in `zef_figure_tool.m`.
- **Parcellation** is lazy-loaded via `zef_tool_start`, not at startup.
- Profile INIs (`profile/<name>/`) drive init tables, forward simulation rows, and compartment templates.
- `zef_plot_volume.m.m` is a legacy duplicate filename — prefer `zef_plot_volume.m`.

## Developer guidance

- New tool: export App in `apps/`, wrapper in `tools/`, callbacks in `callbacks/`, sync in `update/`, register menu entry in `zef_menu_tool.m` or plugin INI.
- Always return/assign `zef` from callbacks and call `zef_update` when tables change.
- Plot functions must read `zef` from base or accept `zef` explicitly — do not assume a local `zef` in nested calls.
- See subfolder READMEs (`gui/tools`, `gui/callbacks`, …) for detailed patterns.
