# Session lifecycle (`src/core`)

This folder is the shell around a Zeffiro session: start, default fields, the GUI↔`zef` synchronizer, waitbars, logging, window tiling, plugin menus, and shutdown.

It is **not** the `+core` package at the project root. `zeffiro_interface` adds this directory (and `src/gui/helpers`) to the path first so `zef_close_all` can run even during a restart.

## What you do here as a user

You rarely open these files. Starting Zeffiro already runs them:

```
zeffiro_interface
  → zef_start
       apply profile/zeffiro_interface.ini
       zef_window_manager('init')   % standalone windows on MATLAB R2025a+
       zef_init                     % defaults for missing zef fields
       open Segmentation / Figure / Mesh / Mesh visualization / Menu tools
       zef_update
```

After that, almost every table edit in the Segmentation tool ends in `zef_update`. **Project → Exit** calls `zef_close_all`. **Window** menu items call `zef_arrange_windows`.

## `zef_update` (the hub)

`zef_update` copies widget values into `zef` fields. It is a **function**. Call it with `zef` or with no arguments (then it reads/writes the base workspace).

What it actually syncs (from the Segmentation tool tables):

| Table | Direction |
|-------|-----------|
| Compartment table | rows → `zef.compartment_tags` and `<tag>_on`, `_name`, `_visible`, `_merge`, `_invert`, `_sources`, plus parameter-profile columns |
| Sensors table | rows → `zef.sensor_tags` and `<tag>_points`, `_name_list`, imaging method, … |
| Transform table | affine rows → transform fields (via `zef_update_transform`) |
| Parameters table | name/value pairs |
| Project tag / notes | `zef.project_tag`, notes |

Compartment **table rows are stored in reverse order** relative to `zef.compartment_tags`. Column 1 is labeling priority. A NaN priority with **On** true gets the row index as priority. Inactive rows have every `<tag>_*` field removed. After the copy, rows are sorted by priority and `zef_update_compartment_table_data` rewrites the table (CellEditCallback is cleared while Data is replaced so the table does not recurse).

If `h_compartment_table` is missing or invalid (project load before the GUI exists), `zef_update` returns immediately.

## Scripts vs functions

| File | Kind | Notes |
|------|------|--------|
| `zef_start.m` | function | `zef = zef_start(zef)` or no-arg from base |
| `zef_init.m` | **script** | needs `zef` in the caller; copies existing fields aside, fills defaults, copies only *missing* fields back. Defaults include `n_sources=10000`, `source_direction_mode=2` (Normal), `preconditioner=2` (SSOR), `source_model=2` (H(div)), `reconstruction_type=7` (Amplitude smoothed). `zef_init_options` would set `reconstruction_type=1` only if that field were still missing. |
| `zef_update.m` | function | central sync |
| `zef_close_all.m` | function | deletes `ZEFFIRO Interface*` figures; `assignin`/`evalin` clears `zef` from base |
| `zef_close_tools.m` | **script** | deletes tool windows except Segmentation, Figure, Menu |
| `zef_close_figs.m` | **script** | deletes Figure-tool windows, then `zef_figure_tool` |
| `zef_plugin.m` | **script** | reads `profile/<profile>/zeffiro_plugins.ini` |
| `zef_start_new_project.m` | **script** | `zeffiro_interface('zeffiro_restart', true)` then delete compartments |
| `zef_remove_system_fields.m` | **script** | strips machine fields listed in `profile/zeffiro_interface.ini` |
| `zef_waitbar.m` | function | custom progress figure; parented to the menu tool when possible |
| `zef_delete_waitbar.m` | function | delete all waitbar figures |
| `zef_arrange_windows.m` | function | tile / maximize / minimize / close |
| `zef_clipping_plane.m` | function | half-space (or slab) node mask for plots |
| `zef_remove_object_handles.m` | function | strip `h_*` graphics before `.mat` save |
| `zef_add_path.m` | function | recursive `addpath`, skips `+` / `@` / `external/` |
| `zef_gpu_count.m` | function | GPU count, or 0 without Parallel Computing Toolbox |
| `zef_start_log.m` | function | rotating logs under `data/log/` |
| `zef_start_config.m` | generated | overwritten by `zeffiro_setup`; do not hand-edit |

## Window menu (verified labels)

From `zef_menu_tool_app_exported` **Window** menu, wired in `zef_menu_tool.m`:

| Menu path | Call |
|-----------|------|
| **Window → Reset windows** | `zef_reset_windows` |
| **Window → Tools → Maximize / Minimize / Close** | `zef_arrange_windows('maximize'/'minimize'/'close','tools','all')` |
| **Window → Tools → Tile → On-screen / All** | `'tile','tools','on-screen'` / `'all'` |
| **Window → Figures → …** | same with `'figs'` |
| **Window → All → …** | same with `'windows'` |

Protected windows (`zef_window_manager('is_protected')`) are skipped. After tiling, the menu is re-docked via `zef_window_manager('dock_menu')`.

`src/gui/helpers/zef_tile_windows.m` is a second copy of the same tiling logic under a different filename; prefer `zef_arrange_windows`.

## Waitbar

Heavy mesh / lead-field / inverse work calls `zef_waitbar`. The window is a compact standalone `uifigure`. The bar is a `uihtml` rounded fill when that constructor works; otherwise two `uilabel` cells in a 1×2 grid (not MATLAB `waitbar`, not linear `uigauge`). Nested callers pass vectors (`current./max` elementwise); the gauge uses `max(ratio(:))` after clamp to [0,1]. Redraws smaller than about 1% are skipped except 0%, 100%, or a message change. ETA text is refreshed about every 5 s. `close(h)` deletes the window. Menu-tool properties `ZefUseWaitbar` and `ZefAlwaysShowWaitbar` control visibility. `zef_delete_waitbar` is used at shutdown and when a new waitbar is created.

## Plugin menus

`zef_plugin` (script) reads CSV rows `{label, parent Tag, callback}` from `profile/<profile_name>/zeffiro_plugins.ini`. Parent Tags on the menu tool are `inverse_tools`, `forward_tools`, `multi_tools`, and `settings`. Each callback string is suffixed with `; zef_update;`. Accelerators `0–9` then `A–Z` are assigned to those items in order after wiring.

Do not edit `zef_plugin.m` to add a plugin; edit the INI.

## New project / close

**Project → New project from profile** and **New empty project** confirm with `questdlg('Reset all?')` then `zef_start_new_project` (`new_empty_project` 0 vs 1). **Project → Exit** is `zef_close_all`. Close disables `DeleteFcn` on matching figures first so teardown does not re-enter, restores MATLAB `WindowStyle` via `zef_window_manager('restore')`, and unless `zef.zeffiro_restart` is 1, `rmpath`s the whole tree.

## Scripting

```matlab
zef = zeffiro_interface('start_mode','nodisplay');   % still constructs hidden figures
zef = zef_update(zef);                               % after programmatic table edits
zef_arrange_windows('tile','windows','all');
zef_close_all();
```

`zef_init` and `zef_plugin` must see `zef` in the caller/base workspace; they are not functions.

## Developer notes

- `src/core` ≠ `+core`. Package APIs (`core.io.electrodes`, …) live at the project root.
- `zef_update` uses `eval` on dynamic `<tag>_*` names — tags must stay valid MATLAB field names.
- Add global defaults in `zef_init.m` and, if they should be profile-specific, in `profile/*/zeffiro_parameters.ini`.
- Fields that must not be saved belong in the system-field list consumed by `zef_remove_system_fields`.
- Window docking / R2025a standalone behaviour: `src/gui/helpers/zef_window_manager.m`.
