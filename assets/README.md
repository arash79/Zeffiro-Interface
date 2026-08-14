# GUI assets (`assets/`)

Logos, toolbar PNGs, and legacy MATLAB `.fig` layouts. This folder is not on the scientific path: it does not mesh, invert, or import anatomy. `zeffiro_interface` adds `genpath(assets/fig)` so `imread` and `openfig` can find files by name.

## What you actually see at startup

By default `zef.mlapp` is 1 (`zef_init`). The windows you click are App Designer exports under `src/gui/apps/` (`zef_segmentation_tool_app_exported`, `zef_mesh_tool_app_exported`, …). The `.fig` files here are the **legacy** layouts used only when `zef.mlapp == 0`.

Plugin windows are **not** here. Each plugin keeps its own `mlapp/` or `fig/` (for example EXP GUIDE `.fig` files under `tools/plugins/EXP/`).

## Icons

Keep these filenames stable; waitbars and menus load them by name:

`zeffiro_logo.png`, `zeffiro_small_logo.png`, `zeffiro_interface_compass.png`, `zeffiro_logo_compass.png`, `zeffiro_mesh_symbol.png`, `zeffiro_symbol_compass.png`, `zeffiro_symbol_mesh.png`.

## Opening a `.fig` from MATLAB

```matlab
zeffiro_interface('open_figure', 'zeffiro_interface_figure_tool.fig');
```

A relative path is resolved under `assets/fig/`. `open_figure_folder` opens every `.fig` in a directory (see `help zeffiro_interface`).

## Layout files under `fig/tools/`

| File | Legacy window |
|------|----------------|
| `zeffiro_interface_segmentation_tool.fig` | Segmentation tool when `mlapp==0` |
| `zeffiro_interface_mesh_tool.fig` | Mesh tool |
| `zeffiro_interface_figure_tool.fig` | Figure tool (the live Figure tool is still built in `zef_figure_tool.m`, not App Designer) |
| `zeffiro_interface_butterfly_plot.fig` | Butterfly plot |
| `zeffiro_interface_parcellation_tool.fig` | Parcellation |
| `zeffiro_interface_ramus_inversion_tool.fig` | RAMUS |
| `zef_find_synthetic_source.fig` / `zef_find_synthetic_eit_data.fig` | Synthetic source / EIT data |

New core tools belong in `src/gui/apps/`, not here. Binary `.fig` files do not diff well; edit them in MATLAB GUIDE/Figure tools only.

Child notes: [`fig/README.md`](fig/README.md). Live GUI wiring: [`src/gui/README.md`](../src/gui/README.md).
