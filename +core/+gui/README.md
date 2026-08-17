# +core/+gui

## Folder purpose

Thin MATLAB package bridge under `core.gui` so the main menu can call electrode import without putting all of `+core` onto `genpath(src)`. Almost all interactive UI still lives in `src/gui`; this package only hosts the menu-tool callback that talks to `core.io.electrodes`.

## Main contents

| Path | Role |
|------|------|
| `+menu_tool/` | Package `core.gui.menu_tool` |
| `+menu_tool/import_electrodes_callback.m` | Import electrodes dialog → parsers → update `zef` |

No other GUI packages exist under `+core/+gui` today.

## Code functionality

`core.gui.menu_tool.import_electrodes_callback(zef)`:

1. Opens `uigetfile` for `.dat` / `.csv` (or cancel → return unchanged `zef`).
2. Dispatches to `core.io.electrodes.from_dat` or `from_csv`.
3. Writes `zef.sensors`, `zef.<prefix>_points`, and `zef.<prefix>_name_list` where `prefix` comes from `zef.current_sensors` (default `"s"`).
4. Calls `zef_update` so tables refresh.
5. On parse failure, shows `errordlg` and leaves `zef` unchanged.

**Inputs:** live `zef` struct (base workspace / tool handle path).  
**Outputs:** updated `zef`.  
**Dependencies:** `core.io.electrodes.*`, MATLAB UI dialogs, `zef_update`.

## Workflow context

- Wired from `src/gui/tools/zef_menu_tool.m` (`ImportelectrodesMenu`).
- Sample layouts: `data/electrodes/*.dat`.
- Mesh attachment and lead-field rebuild happen later (`zef_process_meshes`, electrode builders, forward run) — **not** in this callback.

## Usage instructions

From the GUI: **Import → electrodes** (exact label follows the menu tool).

Programmatically (display required):

```matlab
zef = core.gui.menu_tool.import_electrodes_callback(zef);
```

For headless import, call the parsers directly and assign fields yourself (see `+core/+io/+electrodes`).

## Important notes

- Interactive only — unsuitable for `start_mode','nodisplay'` without replacement.
- Import does **not** recompute `zef.L`.
- Coordinate units must already match the project (typically mm).

## Developer guidance

- Keep new menu callbacks that need package IO under `core.gui.menu_tool`, not as loose scripts in `src/gui`.
- Prefer extending `core.io.electrodes` for format changes; keep this file as orchestration only.
- Pitfall: forgetting to run mesh/electrode attachment after import and wondering why sensors are invisible in the FEM.
