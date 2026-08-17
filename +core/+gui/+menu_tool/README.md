# +core/+gui/+menu_tool

## Folder purpose

Package `core.gui.menu_tool`: the **Import electrodes** menu callback that bridges the Menu tool to `core.io.electrodes` parsers without putting all of `+core` on `genpath(src)`.

## Main contents

| File | Role |
|------|------|
| `import_electrodes_callback.m` | `uigetfile` → `from_dat`/`from_csv` → update `zef` → `zef_update` |

## Code functionality

`core.gui.menu_tool.import_electrodes_callback(zef)`:

1. File picker for `*.dat` / `*.csv` (cancel → unchanged `zef`).
2. `core.io.electrodes.from_dat` or `from_csv`.
3. Writes `zef.sensors`, `zef.<prefix>_points` (xyz; if 6 columns, append CEM radius/impedance), `zef.<prefix>_name_list`.
4. Prefix = `zef.current_sensors` or `"s"`.
5. `zef_update`. Parse failures → `errordlg`, `zef` unchanged.

Does **not** attach electrodes to the FEM (`zef_process_meshes` / `zef_build_electrodes` come later) and does **not** rebuild `zef.L`.

## Workflow context

Wired from `src/gui/tools/zef_menu_tool.m` (`ImportelectrodesMenu`). Formats: `+core/+io/+electrodes`. Samples: `data/electrodes/*.dat`.

## Usage instructions

GUI: **Import → Import electrodes**.

```matlab
zef = core.gui.menu_tool.import_electrodes_callback(zef);
```

Headless: call parsers directly and assign fields (no `uigetfile`).

## Important notes

- Interactive only.
- Coordinates must already match the project frame (typically mm).

## Developer guidance

- Keep format rules in `core.io.electrodes`; keep this file as orchestration.
- Pitfall: expecting sensors to appear in the FEM volume immediately after import.
