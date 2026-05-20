# src/core

## Folder purpose

Application **lifecycle and shell** for Zeffiro Interface. This folder is **not** the `+core` MATLAB package at the repo root. It owns startup (`zef_start`), default field initialization (`zef_init`), the central GUI↔struct synchronizer (`zef_update`), shutdown (`zef_close_all`), logging, waitbars, window tiling, and plugin menu registration (`zef_plugin`).

`zeffiro_interface.m` adds this directory to the path **before** anything else so `zef_close_all` is available during restart guards.

## Main contents

| File | Type | Role |
|------|------|------|
| `zef_start.m` | function | Opens core tools, applies system settings, detects GPU, calls `zef_init` and `zef_update` |
| `zef_init.m` | script | Seeds hundreds of default `zef` fields (mesh, inverse, GUI, reconstruction) |
| `zef_update.m` | function | Pulls compartment/sensor/parameter tables from GUI into `zef`; refreshes window titles |
| `zef_close_all.m` | function | Deletes Zeffiro figures, clears base workspace, removes paths (unless restart) |
| `zef_close_tools.m` / `zef_close_figs.m` | scripts | Close auxiliary tool/figure windows before save |
| `zef_start_log.m` | function | Rotating session logs under `data/log/` |
| `zef_start_new_project.m` | script | Restart + empty compartment table |
| `zef_plugin.m` | script | Reads `profile/<name>/zeffiro_plugins.ini` and attaches `uimenu` callbacks |
| `zef_waitbar.m` | function | Custom progress figure tied to menu-tool settings |
| `zef_arrange_windows.m` | function | Tile/maximize/minimize/close Zeffiro windows |
| `zef_clipping_plane.m` | function | Half-space node mask for volume clipping in plots |
| `zef_remove_object_handles.m` | function | Strip `h_*` graphics handles before `.mat` save |
| `zef_remove_system_fields.m` | script | Remove runtime-only fields using `profile/zeffiro_interface.ini` |
| `zef_add_path.m` | function | Recursive `addpath` helper (skips `+` and `@` folders) |
| `zef_start_config.m` | script | Warning toggles; generated external paths from `zeffiro_setup` |

## Code functionality

**Startup chain:** `zef_start` → `zef_apply_system_settings` (reads `profile/zeffiro_interface.ini`) → `zef_init` → opens `zef_segmentation_tool`, `zef_figure_tool`, `zef_mesh_tool`, `zef_mesh_visualization_tool`, `zef_menu_tool` → `zef_update`.

**`zef_update`** reads `h_compartment_table`, `h_sensors_table`, `h_parameters_table`, project tag/notes, and imaging method selection; writes dynamic per-compartment fields (`<tag>_on`, `_sigma`, `_priority`, …) and per-sensor fields (`<tag>_points`, `_name_list`, …).

**`zef_plugin`** parses CSV rows `label, parent_menu_tag, callback` and creates menu items under `inverse_tools`, `forward_tools`, `multi_tools`, or `settings` on `h_zeffiro_menu`. Each callback is suffixed with `; zef_update;`.

**Scripts** (`zef_init`, `zef_plugin`, …) expect `zef` in the **caller or base workspace**, not as a function argument.

## Workflow context

```
zeffiro_interface → zef_start → [GUI tools] → zef_update (continuous)
                → zef_start_log → data/log/
                → zef_load(default_project.mat)  [optional]
```

Downstream consumers: every GUI callback that mutates tables calls `zef_update`; save/load in `src/io` call `zef_remove_object_handles` / `zef_remove_system_fields`; forward/inverse heavy work calls `zef_waitbar`.

## Usage instructions

```matlab
% Normal startup (handled automatically)
zef = zeffiro_interface;

% After editing compartment table programmatically
zef = zef_update(zef);

% Force new empty project
zef_start_new_project;   % script — needs zef in workspace

% Close everything
zef_close_all();
```

Window menu actions in `zef_menu_tool.m` call `zef_arrange_windows('tile')`, `'maximize'`, etc.

## Important notes

- **`src/core` ≠ `+core`:** package APIs live at project root; this folder is procedural lifecycle only.
- `zef_update` uses `eval` on dynamic compartment field names — field naming conventions must stay stable.
- `zef_tile_windows.m` in `src/gui/helpers` duplicates `zef_arrange_windows`; prefer `zef_arrange_windows`.
- On save, `zef_close_tools` and `zef_close_figs` run first so serialized projects do not embed stale figure handles.

## Developer guidance

- Add new global defaults in `zef_init.m` and mirror them in the appropriate `profile/*/zeffiro_parameters.ini` if they should be profile-specific.
- New plugin menus: edit `profile/<profile>/zeffiro_plugins.ini`, not `zef_plugin.m` logic.
- Any GUI table that edits `zef` should end with `zef_update(zef)` so compartment tags and window titles stay consistent.
- Avoid storing large transient arrays on `zef` without listing them in `zef_remove_system_fields` if they should not be saved.
