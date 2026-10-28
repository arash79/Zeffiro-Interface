# Session lifecycle (`src/app`)

Shell around a Zeffiro session: start, default fields, the GUI↔`zef` synchronizer, waitbars, logging, window tiling, plugin menus, and shutdown. It is **not** the `+core` package at the project root. `zeffiro_interface` adds this directory (and `src/gui/chrome`) to the path first so `zef_close_all` can run even during a restart.

## Main contents

| File | Kind | Notes |
|------|------|--------|
| `zef_start.m` | function | `zef = zef_start(zef)` or no-arg from base |
| `zef_init.m` | **script** | startup only: caches, `zef_fill_missing_defaults`, profile reseed. Needs `zef` in the caller |
| `zef_session_defaults.m` | function | default catalog. Does not reseed compartments or sensors |
| `zef_fill_missing_defaults.m` | function | copies catalog values onto fields that are missing |
| `zef_system_field_names.m` | function | machine fields excluded from project files |
| `zef_session_shell_names.m` | function | fields kept when a project replaces the previous one |
| `zef_update.m` | function | central GUI→`zef` sync |
| `zef_close_all.m` | function | deletes `ZEFFIRO Interface*` figures; clears `zef` from base |
| `zef_close_tools.m` | **script** | deletes tool windows except Segmentation, Figure, Menu |
| `zef_close_figs.m` | **script** | deletes Figure-tool windows, then `zef_figure_tool` |
| `zef_plugin.m` | **script** | reads `profile/<profile>/zeffiro_plugins.ini` via `zef_read_profile_cell` |
| `zef_read_profile_cell.m` | function | Cached CSV/INI reader used for profile files (drop-in for `readcell`) |
| `zef_start_new_project.m` | **script** | `zeffiro_interface('zeffiro_restart', true)` then delete compartments |
| `zef_remove_system_fields.m` | function | `zef_data = zef_remove_system_fields(zef, zef_data)` strips names from `zef_system_field_names` |
| `zef_waitbar.m` / `zef_close_waitbar.m` / `zef_delete_waitbar.m` | function | custom progress figure; nested close via `zef_close_waitbar` |
| `zef_arrange_windows.m` | function | tile / maximize / minimize / close |
| `zef_clipping_plane.m` | function | half-space (or slab) node mask for plots |
| `zef_remove_object_handles.m` | function | strip `h_*` graphics before `.mat` save |
| `zef_gpu_count.m` | function | GPU count, or 0 without Parallel Computing Toolbox |
| `zef_ensure_parpool.m` | function | Local `parpool` sized to `n_workers` when PCT is present; no-op without it |
| `zef_start_log.m` | function | rotating logs under `data/log/` |
| `zef_start_config.m` | generated | overwritten by `zeffiro_setup` (comment header + `addpath` / startup lines); do not hand-edit |
| `zef_get_profile_parameters.m` | function | On scalar Segmentation/Free-form param names |

## Code functionality

**Startup:** `zeffiro_interface` → `zef_start` applies `profile/zeffiro_interface.ini`, runs `zef_window_manager('init')`, `zef_init`, opens Segmentation / Figure / Mesh / Mesh visualization / Menu tools, then `zef_update`.

**Project open:** `zef_load` → `zef_merge_project_data` keeps the session shell and drops previous project fields the file does not contain → `zef_fill_missing_defaults` fills catalog gaps. It does not run `zef_init`.

**Defaults in `zef_session_defaults`:** include `n_sources=10000`, `mesh_resolution=3` (examples often use `4.5`), `source_direction_mode=2` (Normal), `preconditioner=2` (CPU SSOR; GPU Jacobi ignores this), `source_model=2` (H(div)), `location_unit=1` (mm), `solver_tolerance=1e-6`, `reconstruction_type=7` (Amplitude smoothed). `zef_init` applies that catalog at startup and then reseeds compartments and sensors from the profile.

**`zef_update`:** copies widget values into `zef`. Call with `zef` or with no arguments (reads/writes base workspace). Syncs compartment, sensors, transform, and parameters tables, plus project tag/notes. Compartment table rows are stored in reverse order relative to `zef.compartment_tags`. Column 1 is labeling priority. A NaN priority with **On** true gets the row index as priority. Inactive rows have every `<tag>_*` field removed. After the copy, rows are sorted by priority and `zef_update_compartment_table_data` rewrites the table. If `h_compartment_table` is missing, returns immediately.

**Waitbar:** compact standalone `uifigure`; nested callers pass vectors (`current./max`); redraws smaller than ~1% are skipped except 0%, 100%, or message change. Menu-tool properties `ZefUseWaitbar` and `ZefAlwaysShowWaitbar` control visibility. The window is a singleton: nested jobs reuse it. Close with `zef_close_waitbar` (never `delete`) so a nested close only drops the nest count and the parent handle stays valid.

**Plugins:** `zef_plugin` reads CSV rows `{label, parent Tag, callback}` from the profile INI. Parent Tags: `inverse_tools`, `forward_tools`, `multi_tools`, `settings`. Each callback is suffixed with `; zef_ui_ready_new_windows; zef_update;`. Accelerators `0–9` then `A–Z` are assigned in order. Do not edit `zef_plugin.m` to add a plugin; edit the INI.

## Workflow context

Almost every Segmentation-tool table edit ends in `zef_update`. **Project → Exit** calls `zef_close_all`. **Window** menu items call `zef_arrange_windows`. **Project → New project from profile** / **New empty project** confirm then `zef_start_new_project` (`new_empty_project` 0 vs 1). Close disables `DeleteFcn` on matching figures first, restores MATLAB `WindowStyle` via `zef_window_manager('restore')`, and unless `zef.zeffiro_restart` is 1, `rmpath`s `src/`, `assets/fig`, `plugins/`, `profile/`, `external/` if present, and the project root.

Window menu (from `zef_menu_tool_app_exported` / `zef_menu_tool.m`): Reset windows → `zef_reset_windows`; Tools/Figures/All → Maximize / Minimize / Close / Tile via `zef_arrange_windows`. Protected windows are skipped; after tiling the hidden menu host is re-stacked via `zef_window_manager('dock_menu')` (unified shell keeps the menu hidden).

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode','nodisplay');   % still constructs hidden figures
zef = zef_update(zef);                               % after programmatic table edits
zef_arrange_windows('tile','windows','all');
zef_close_all();
```

`zef_init` and `zef_plugin` must see `zef` in the caller/base workspace; they are not functions.

## Important notes

- You rarely open these files as a user; starting Zeffiro already runs them.
- `src/app` ≠ `+core`. Package APIs (`core.io.electrodes`, …) live at the project root.
- Field defaults: [docs/zef-state.md](../../docs/zef-state.md). Bootstrap: [docs/architecture.md](../../docs/architecture.md).

## Developer guidance

- `zef_update` uses `eval` on dynamic `<tag>_*` names — tags must stay valid MATLAB field names.
- Add global defaults in `zef_session_defaults.m`. Profile-specific values stay in `profile/*/zeffiro_parameters.ini`. Do not run `zef_init` to fill gaps in an open project.
- Fields that must not be saved belong in `zef_system_field_names` (profile INI column 3 or the fixed list in that function). Project arrays that must disappear when a file omits them belong in `project_payload_names` inside `zef_session_shell_names.m`.
- Window docking / R2025a standalone behaviour: `src/gui/chrome/zef_window_manager.m`.
