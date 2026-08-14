# Dynamical plot queue internals (`m`)

Window, table menus, and `zef_plot_dpq` playback. Overlay implementations live in `dynamical_plot_queue_bank/`. Start file: `zeffiro_interface_dynamical_plot_queue.m` (INI callback; in-file function `zef_dpq_start`). User manual: [parent README](../README.md).

| File | Role |
|------|------|
| `zeffiro_interface_dynamical_plot_queue.m` | Menu callback → `zef_tool_start` → `zef_dpq_window` |
| `zef_dpq_window.m` | App handles, bank list from `help()`, Add / List / Delete menus |
| `zef_dpq_add.m` / `zef_dpq_delete.m` / `zef_dpq_selection.m` | Table row add, drop, and cell-selection sync |
| `zef_plot_dpq.m` | `evalin('caller', script)` for enabled rows of type `'static'` or `'dynamical'` |

Visualization (`zef_plot_meshes`, `zef_plot_volume`, `zef_print_meshes`, `zef_play_cdata`) calls `zef_plot_dpq`, not this window.
