# DynamicalPlotQueue / m

## Folder purpose

Implements **Multi tools → Dynamical plot queue**: edit a table of overlay scripts that visualization runs as static or frame-wise dynamical hooks. The window only edits `zef.dynamical_plot_queue_table`; playback is `zef_plot_dpq`.

## Main contents

| File / folder | Role |
|---------------|------|
| `zeffiro_interface_dynamical_plot_queue.m` | INI callback; function `zef_dpq_start` |
| `zef_dpq_window.m` | App wiring, bank list, menus |
| `zef_dpq_add.m` / `zef_dpq_delete.m` / `zef_dpq_selection.m` | Table row ops |
| `zef_plot_dpq.m` | Eval enabled rows by type |
| `dynamical_plot_queue_bank/` | Overlay scripts (GMM, sources, resection, …) |

## Code functionality

- Window loads `zeffiro_interface_dynamical_plot_queue_app`, fills bank from `dynamical_plot_queue_bank/*.m` using `help()` text as descriptions.
- Table columns: script name, enabled, `'static'|'dynamical'`, description. Menus Add / List / Delete.
- `zef_plot_dpq(type,zef)` walks the table; for enabled rows matching `type`, `evalin('caller', script)`.
- Called from `zef_plot_meshes`, `zef_plot_volume`, `zef_print_meshes`, `zef_play_cdata` (try/catch).

## Workflow context

After reconstructions or synthetic sources exist, queue bank plots (e.g. `zef_plot_synthetic_source`, `zef_dpq_plot_GMM`, `zef_plot_SESAME_dipoles`) so mesh redraws include overlays without baking them into the mesh tool.

## Usage instructions

1. Open Dynamical plot queue from Multi tools (or INI name `zeffiro_interface_dynamical_plot_queue`).
2. List-menu a bank script or Add a blank row and type a callable name.
3. Set enabled + static/dynamical; edit description/script boxes for the selected row.
4. Redraw / play visualization so `zef_plot_dpq` runs.

## Important notes

- List menu stores enabled as char `'true'`; Add uses logical `true`—`str2num` on column 2 must succeed for both.
- Bank files may declare function names that differ from filenames (e.g. `zef_dpq_plot_GMM.m` → `zef_PlotGMModel`); queue stores the **filename** for `evalin`.
- Some overlays use `h_axes_image` (caller), others `zef.h_axes1` (base).

## Developer guidance

Add new overlays as `*.m` under `dynamical_plot_queue_bank/` with a useful H1 help line. Keep playback logic in `zef_plot_dpq` only. Do not expect the queue window itself to draw meshes.
