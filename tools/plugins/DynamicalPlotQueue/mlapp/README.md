# DynamicalPlotQueue — App Designer layouts

## Folder purpose

App Designer UI for the **Dynamical plot queue** plugin: edit a table of extra plot commands that run during mesh visualization (static once per draw, dynamical every movie frame).

## Main contents

| File | Role |
|------|------|
| `zeffiro_interface_dynamical_plot_queue_app.mlapp` | Queue editor (menus Add / List / Delete, bank list, description box) |
| `README.md` | This documentation |

Logic: `tools/plugins/DynamicalPlotQueue/m/` — file `zeffiro_interface_dynamical_plot_queue.m` (function `zef_dpq_start`) → `zef_dpq_window`; bank overlays under `m/dynamical_plot_queue_bank/`.

## Code functionality

`zef_dpq_start` / `zeffiro_interface_dynamical_plot_queue` opens this app. There are no Start pushbuttons; menus call `zef_dpq_add`, bank **List** (append enabled static row from `help()`), and `zef_dpq_delete`. Edits write `zef.dynamical_plot_queue_table` only. Visualization later calls `zef_plot_dpq('static'|'dynamical')`.

## Workflow context

**Multi tools → Dynamical plot queue** (default profile). Callback file `zeffiro_interface_dynamical_plot_queue`; entry function `zef_dpq_start`. Title: **ZEFFIRO Interface: Dynamical plot queue**. The window does not draw overlays itself.

## Usage instructions

```matlab
zef = zeffiro_interface_dynamical_plot_queue(zef);   % or zef_dpq_start(zef)
% opens zeffiro_interface_dynamical_plot_queue_app.mlapp
zef_plot_dpq('static', zef);   % after visualization draws
```

1. Open Multi tools → Dynamical plot queue.
2. Add custom rows or List a bank function.
3. Draw / print meshes so the pipeline invokes `zef_plot_dpq`.

## Important notes

- List always appends **static** enabled rows.
- Bank helpers must expose useful `help()` text for List descriptions.

## Developer guidance

- Preserve start entry `zeffiro_interface_dynamical_plot_queue` / `zef_dpq_start`.
- Keep menu Tags and table binding aligned with `zef_dpq_window`.
- New bank files go under `m/dynamical_plot_queue_bank/`, not inside the `.mlapp`.
