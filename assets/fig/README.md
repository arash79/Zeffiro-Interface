# `assets/fig`

PNG logos and compass/mesh icons plus the legacy `.fig` layouts under `tools/`. `zeffiro_interface` does `addpath(genpath(..., 'assets', 'fig'))`. Default UI is App Designer (`zef.mlapp == 1`); these `.fig` files are the `zef.mlapp == 0` path and `zeffiro_interface('open_figure', ...)`.

Icons at this level: `zeffiro_logo.png`, `zeffiro_small_logo.png`, `zeffiro_interface_compass.png`, `zeffiro_logo_compass.png`, `zeffiro_mesh_symbol.png`, `zeffiro_symbol_compass.png`, `zeffiro_symbol_mesh.png`. Waitbar and menus may `imread` them by filename — keep names stable.

Parent: [`assets/README.md`](../README.md).
