# src/gui/apps

## Folder purpose

**Layout-only** App Designer exports for the four main Zeffiro tool windows. These classes define widgets and positions; **callbacks are wired in `src/gui/tools`**. Figure tool is programmatic (`zef_figure_tool`) and is not exported here.

## Main contents

| Export | Window name | Instantiated by |
|--------|-------------|-----------------|
| `zef_menu_tool_app_exported.m` | Menu tool | `zef_menu_tool.m` |
| `zef_segmentation_tool_app_exported.m` | Segmentation tool | `zef_segmentation_tool.m` |
| `zef_mesh_tool_app_exported.m` | Mesh tool | `zef_mesh_tool.m` |
| `zef_mesh_visualization_tool_app_exported.m` | Mesh visualization tool | `zef_mesh_visualization_tool.m` |

Legacy GUIDE `.fig` copies (when `zef.mlapp == 0`) live under `assets/fig/tools/`. Options dialogs opened from `src/gui/open` may use separate `.mlapp` sources not stored beside these four exports.

## Code functionality

Each `*_app_exported` constructs a `uifigure` hierarchy. Tool scripts then:

1. Instantiate the export.
2. `zef_assign_data` / copy handles onto `zef.h_*`.
3. Attach `ButtonPushedFcn` / `ValueChangedFcn` / menu callbacks (often string eval in base workspace).
4. Apply theme/layout via `src/gui/helpers` (`zef_ui_theme`, `zef_layout_*`, `zef_ui_ready`).

## Workflow context

```
zef_start → tools instantiate apps from this folder
         → helpers theme/layout
         → callbacks / update / mesh / forward
```

## Usage instructions

Do not run exports alone for a working session:

```matlab
% Prefer:
zef = zeffiro_interface;
% or reopen a tool:
zef_mesh_tool;
```

Editing UI: open the corresponding `.mlapp` in App Designer if present in the authoring tree, then re-export; keep callback wiring in `src/gui/tools`.

## Important notes

- Exports without tool wiring have no Inverse/Forward behavior.
- Renaming widget `Tag`s breaks `zef.h_*` assignments in tools.
- Figure tool and many plugins use their own UI paths.

## Developer guidance

- Change layout here or in `zef_layout_*`; change behavior in tools/callbacks/update.
- After App Designer export, diff carefully — MATLAB often rewrites large generated sections.
- Pitfall: putting business logic inside `*_app_exported` instead of tools/helpers.
