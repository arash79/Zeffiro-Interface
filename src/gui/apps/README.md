# src/gui/apps

## Folder purpose

App Designer **layouts** for the main Zeffiro tool windows and Settings dialogs. Widget trees live here; **callbacks are wired in `src/gui/tools`** (main tools) and **`src/gui/open`** (settings). Figure tool is programmatic (`zef_figure_tool`) and is not exported here.

## Main contents

### Main tools (export + source `.mlapp`)

| Export / source | Window | Instantiated by |
|-----------------|--------|-----------------|
| `zef_menu_tool_app.mlapp` + `_exported.m` | Menu tool | `zef_menu_tool.m` |
| `zef_segmentation_tool_app.mlapp` + `_exported.m` | Segmentation tool | `zef_segmentation_tool.m` |
| `zef_mesh_tool_app.mlapp` + `_exported.m` | Mesh tool | `zef_mesh_tool.m` |
| `zef_mesh_visualization_tool_app.mlapp` + `_exported.m` | Mesh visualization | `zef_mesh_visualization_tool.m` |

### Settings / profile dialogs (opened from `src/gui/open`)

| `.mlapp` | Opened by |
|----------|-----------|
| `zef_forward_and_inverse_processing_options.mlapp` | `zef_open_forward_and_inverse_options` |
| `zef_graphics_processing_options.mlapp` | `zef_open_graphics_options` |
| `zef_gaussian_prior_options.mlapp` | `zef_open_gaussian_prior_options` |
| `zef_system_settings.mlapp` | `zef_open_system_settings` |
| `zef_parameter_profile.mlapp` | `zef_open_parameter_profile` |
| `zef_segmentation_profile.mlapp` | `zef_open_segmentation_profile` |
| `zef_init_profile.mlapp` | `zef_open_init_profile` |
| `zef_plugin_settings.mlapp` | `zef_open_plugin_settings` |

## Code functionality

Each export constructs a `uifigure` hierarchy. Tool/open scripts then:

1. Instantiate the app / export.
2. `zef_assign_data` / copy handles onto `zef.h_*`.
3. Attach `ButtonPushedFcn` / `ValueChangedFcn` / menu callbacks.
4. Apply theme/layout via `src/gui/chrome` (`zef_ui_theme`, `zef_ui_shell`, `zef_layout_*`, `zef_ui_ready`).

## Workflow context

```
zef_start → tools instantiate main apps
Settings menu → zef_open_* → dialog mlapps
         → chrome theme/layout/icons
         → callbacks / update / mesh / forward
```

## Usage instructions

```matlab
zef = zeffiro_interface;   % preferred
% or reopen a tool:
zef_mesh_tool;
```

Edit `.mlapp` in App Designer, then re-export if the project still uses `*_exported.m`; keep callback wiring in tools/open.

## Important notes

- Renaming widget `Tag`s breaks `zef.h_*` assignments.
- Unified shell may reparent tool content — layout helpers must tolerate that.
- Remaining GUIDE layout: synthetic EIT under `assets/fig/tools/`.
- Menu runtime is `zef_menu_tool_app_exported.m`.

## Developer guidance

- Change layout here; change behavior in tools/callbacks/update/open.
- After export, diff carefully — MATLAB often rewrites large generated sections.
- Pitfall: putting business logic inside `*_app_exported` instead of tools/chrome.
