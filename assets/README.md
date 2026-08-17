# GUI assets (`assets/`)

## Folder purpose

Logos, toolbar PNGs, and legacy MATLAB `.fig` layouts. This folder is not on the scientific path: it does not mesh, invert, or import anatomy. `zeffiro_interface` adds `genpath(assets/fig)` so `imread` and `openfig` can find files by name.

## Main contents

Stable icon filenames (waitbars and menus load them by name): `zeffiro_logo.png`, `zeffiro_small_logo.png`, `zeffiro_interface_compass.png`, `zeffiro_logo_compass.png`, `zeffiro_mesh_symbol.png`, `zeffiro_symbol_compass.png`, `zeffiro_symbol_mesh.png`.

Legacy layouts under `fig/tools/` (when `zef.mlapp == 0`): `zeffiro_interface_segmentation_tool.fig`, `zeffiro_interface_mesh_tool.fig`, `zeffiro_interface_figure_tool.fig`, `zeffiro_interface_butterfly_plot.fig`, `zeffiro_interface_parcellation_tool.fig`, `zeffiro_interface_ramus_inversion_tool.fig`, `zef_find_synthetic_source.fig`, `zef_find_synthetic_eit_data.fig`.

## Code functionality

By default `zef.mlapp` is 1 (`zef_init`). Live windows are App Designer exports under `src/gui/apps/` (`zef_segmentation_tool_app_exported`, `zef_mesh_tool_app_exported`, …). The `.fig` files here are legacy layouts used only when `zef.mlapp == 0`. The live Figure tool is still built in `zef_figure_tool.m`, not App Designer. Plugin windows are **not** here—each plugin keeps its own `mlapp/` or `fig/`.

## Workflow context

Assets support GUI chrome and optional legacy GUIDE windows. Scientific workflow (mesh → lead field → inverse) does not depend on this folder beyond icons. Child notes: `fig/README.md`. Live GUI wiring: `src/gui/README.md`.

## Usage instructions

```matlab
zeffiro_interface('open_figure', 'zeffiro_interface_figure_tool.fig');
```

A relative path is resolved under `assets/fig/`. `open_figure_folder` opens every `.fig` in a directory (see `help zeffiro_interface`).

## Important notes

Keep icon filenames stable. Binary `.fig` files do not diff well; edit them in MATLAB GUIDE/Figure tools only. New core tools belong in `src/gui/apps/`, not here.

## Developer guidance

Do not add plugin layouts under `assets/`. Prefer App Designer exports in `src/gui/apps/` for new core tools. Document filename contracts when waitbars or menus load icons by name.
