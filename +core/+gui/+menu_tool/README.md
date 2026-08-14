# `+menu_tool` — Import electrodes

This is the only callback in `+core/+gui`. It exists so **Import → Import electrodes** can call the package parsers `core.io.electrodes.from_dat` / `from_csv` without putting `+core` internals on `genpath(src)`.

`core.gui.menu_tool.import_electrodes_callback(zef)` is wired in `src/gui/tools/zef_menu_tool.m` (`ImportelectrodesMenu`, label **Import electrodes**). It is not under Edit.

1. `uigetfile` for `*.dat` / `*.csv`.
2. Parse with `from_dat` or `from_csv`.
3. Write `zef.sensors`, `zef.<prefix>_points`, `zef.<prefix>_name_list` (`prefix` = `zef.current_sensors` or `"s"`).
4. `zef_update`.

Cancel or parse errors leave `zef` unchanged (`errordlg` on parse failure). The callback does **not** attach electrodes to the FEM mesh; `zef_process_meshes` / `zef_build_electrodes` do that at lead-field time.

```matlab
zef = core.gui.menu_tool.import_electrodes_callback(zef);
```

Formats and CEM columns: [../../+io/+electrodes/README.md](../../+io/+electrodes/README.md). Package overview: [../README.md](../README.md).
