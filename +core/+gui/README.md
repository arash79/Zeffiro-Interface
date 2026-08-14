# `+core/+gui` — package-tree menu callbacks

Almost all GUI code is still under `src/gui`. This package exists so electrode import can call `core.io.electrodes.*` without duplicating parsers on the `src` path.

Today that is only **`+menu_tool/import_electrodes_callback.m`**.

## GUI path

Menu bar (window from `zef_menu_tool`): **Import → Import electrodes** (not Edit). That `MenuSelectedFcn` calls `core.gui.menu_tool.import_electrodes_callback`.

The callback opens `uigetfile` for `*.dat` / `*.csv`, parses, writes `zef.sensors` / `zef.<prefix>_points` / `zef.<prefix>_name_list`, then `zef_update`. It does **not** attach electrodes to the FEM mesh; that happens later in `zef_process_meshes` / `zef_build_electrodes`.

## Scripting

```matlab
zef = core.gui.menu_tool.import_electrodes_callback(zef);
```

Formats: [../+io/+electrodes/README.md](../+io/+electrodes/README.md). Callback details: [+menu_tool/README.md](+menu_tool/README.md).
