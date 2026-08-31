## Folder purpose

A table of extra plot commands that run **during** mesh visualization. Each row is `{script_or_function, enabled, 'static'|'dynamical', description}`. `zef_plot_dpq(type)` walks enabled rows of that type and `evalin('caller', row{1})` so overlays (synthetic arrows, GMM, strips, resection, …) appear on the current axes.

The visualization pipeline is expected to call `zef_plot_dpq('static')` / `zef_plot_dpq('dynamical')`. This window only **edits** `zef.dynamical_plot_queue_table`.

## Main contents

- Start file: `zeffiro_interface_dynamical_plot_queue` → `zef_dpq_window`
- Bank overlays: `m/dynamical_plot_queue_bank/*.m`
- Layout under `mlapp/`

## Code functionality

There are no `ButtonPushedFcn` pushbuttons; the UI is menus + list (`zef_dpq_window.m`):

| Control | Action |
|---------|--------|
| Menu **Add** | `zef_dpq_add` — append a blank/custom row |
| Menu **List** | append the selected bank function (`m/dynamical_plot_queue_bank/*.m`) as a **static** enabled row; description from `help()` |
| Menu **Delete** | `zef_dpq_delete` |
| Table edit | writes `zef.dynamical_plot_queue_table` |
| Bank list | `help()` text into the description box |

Bank examples: `zef_plot_synthetic_source`, `zef_plot_3D_arrow_reconstructed_source`, `zef_dpq_plot_GMM`, `zef_plot_strip(s)`, `zef_dpq_plot_resection`, `zef_dpq_wireframe_plot`, `zef_plot_SESAME_dipoles`. **List** appends a bank file as a **static** enabled row (description from `help()`). Visualization (`zef_plot_volume` / `zef_plot_meshes` / `zef_print_meshes`) then calls `zef_plot_dpq('static')` or `'dynamical'` so those overlays appear on `h_axes1` / the print figure. A **dynamical** row re-runs every movie frame; **static** runs once per draw.

## Workflow context

**Multi tools → Dynamical plot queue** (default profile). Callback: `zeffiro_interface_dynamical_plot_queue` → `zef_dpq_window`. Title: **ZEFFIRO Interface: Dynamical plot queue**.

## Usage instructions

```matlab
zef = zeffiro_interface_dynamical_plot_queue(zef);
zef_plot_dpq('static', zef);
```

1. Open Multi tools → Dynamical plot queue.
2. Add custom rows or List a bank function.
3. Draw meshes / print; visualization calls `zef_plot_dpq('static'|'dynamical')`.

## Important notes

- This window only edits the queue table; it does not draw by itself.
- List always appends rows as **static** enabled.
- Dynamical rows re-run every movie frame; static once per draw.

## Developer guidance

Preserve start entry `zeffiro_interface_dynamical_plot_queue`. New bank helpers under `m/dynamical_plot_queue_bank/` should expose useful `help()` text for List descriptions. Keep `zef_plot_dpq` contract with visualization callers.
