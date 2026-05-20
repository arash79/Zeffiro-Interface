# src/gui/tools

## Folder purpose

**GUI tool lifecycle orchestration**: instantiate App Designer exports (or legacy figures), copy widget handles into `zef` as `h_*` fields, attach `MenuSelectedFcn` / `CellEditCallback` / `ValueChangedFcn`, and delegate to `open/` for secondary dialogs.

## Main contents

| File | Opens | Key wiring |
|------|-------|------------|
| `zef_menu_tool.m` | Main menu bar | Project I/O, import/export, edit, multi-tools, settings, `zef_plugin` |
| `zef_segmentation_tool.m` | Compartment/sensor/transform UI | Tables → `zef_update`, selection callbacks |
| `zef_mesh_tool.m` | FEM + forward simulation table | Mesh buttons, `zef_update_mesh_tool` |
| `zef_mesh_visualization_tool.m` | Plot controls | Buttons → `plot/*`, `zef_update_mesh_visualization_tool` |
| `zef_figure_tool.m` | Classic figure + `uiaxes` | Sliders, colormap, `assignin base zef` |
| `zef_tool_start.m` | Generic lazy tool launcher | Dedupes by `ZefTool` tag |
| `zef_parcellation_tool.m` | Parcellation (lazy) | `zef_parcellation_tool_open` chain |
| `zef_update_mesh_tool.m` | — | Sync mesh-tool widgets → `zef` |
| `zef_update_mesh_visualization_tool.m` | — | Sync viz-tool widgets → `zef` |
| `zef_segmentation_tool_toggle.m` | — | Dock/undock segmentation vs menu |
| `zef_reopen_menu_tool.m` | — | Preserve log metadata, rebuild menu |

## Code functionality

Standard pattern:
```matlab
zef_data = zef_mesh_tool_app_exported;
zef = zef_assign_data(zef, zef_data);   % copies all h_* fields
set(zef.h_*, 'MenuSelectedFcn', 'zef = zef_some_callback(zef);');
```

`zef_menu_tool.m` is the largest file: wires every top-level menu and ends with `zef_plugin` to load `profile/*/zeffiro_plugins.ini`.

`zef_tool_start` runs `evalc(['zef =' tool_script '(zef);'])` and stores persistent tool state in `zef.zeffiro_variable_data` for project save.

## Workflow context

Called only from `src/core/zef_start.m` at startup (except lazy parcellation). Menu actions in other tools call `zef_window_visible` to show/hide peers.

## Usage instructions

```matlab
% Tools open automatically with zeffiro_interface
% Reopen menu after plugin INI edit:
zef = zef_reopen_menu_tool(zef);
```

## Important notes

- Tools tag figures with `ZefTool` / `ZefFig` for `zef_arrange_windows`.
- `zef.mlapp == 0` legacy path opens `.fig` from `assets/fig/` instead of App Designer.
- Forward simulation table rows are **evaluated strings** from `zeffiro_forward_simulation.ini` — typos break mesh tool runs.

## Developer guidance

- New menu item: add `uimenu` in `zef_menu_tool.m` with callback ending in `zef_update` where tables change.
- Use `zef_assign_data` to bulk-copy App export fields rather than manual field lists.
- For optional tools, use `zef_tool_start` pattern instead of adding to `zef_start` unconditionally.
