# src/gui/update

## Folder purpose

**Granular widget → `zef` field sync** (and a few **zef → widget** refreshers). Complements the bulk table sync in `src/app/zef_update.m`. Triangle with the rest of the GUI stack: **init → open → update**.

## Main contents

### Figure-tool look / lighting / colormap (~18)

- Colorscale: `zef_update_colorscale`, `_min`, `_max`
- Look: `zef_update_contrast_and_brightness`, `zef_update_zoom`, `zef_update_ambience`, `zef_update_specular`, `zef_update_diffusion`, `zef_update_lights`
- Transparency: `_surface`, `_sensor`, `_cones`, `_reconstruction`, `_additional`

Wired from `zef_figure_tool` slider Callbacks and `zef_set_figure_tool_sliders` / `zef_set_sliders_plot`.

### Figure lists / overlays

`zef_update_fig_details`, `zef_update_contour`

### Option dialogs

`zef_update_forward_and_inverse_options`, `zef_update_graphics_options`, `zef_update_gaussian_prior_options` — ValueChangedFcn from `zef_open_*`

### Segmentation / tables

`zef_update_compartment_table_data` (called from `zef_update`), `zef_get_data_compartment_table` (**script**: copies one compartment-table row onto `zef.<tag>_*` during the `zef_update` loop — needs `zef_i` / `zef_j` / `zef.aux_field_1`; columns 2 On, 3 Name, 4 Visible, 7 Merge, 8 Invert, 9 Activity → `<tag>_sources`), `zef_update_transform`, `zef_update_parameters`, `zef_update_sensors_name_table`

### Parcellation / butterfly / EIT / labeling

`zef_update_parcellation` (**zef → widgets** refresh), `zef_update_butterfly_plot`, `zef_update_find_synthetic_eit_data` (ROI edits; Compute is `zef_synthetic_eit_data`), `zef_update_labeling_priority`

### Pipeline (non-dialog)

`zef_update_lead_field_id`

Tool-local siblings live under `src/gui/tools/` (`zef_update_mesh_tool`, `zef_update_mesh_visualization_tool`) — not this folder.

## Code functionality

Pattern: read `zef.h_<widget>.Value` (or equivalent) → write `zef.<field>` → optional light redraw. Most updaters do **not** re-run a full volume plot; the user still presses Visualize / uses figure refresh paths.

## Workflow context

```
open/create UI (ValueChangedFcn / slider Callback)
  → zef_update_*   (this folder)
  → zef fields
  → optional plot / contour refresh
```

Figure creation also applies theme/layout via `src/gui/chrome` (`zef_ui_theme`, `zef_figure_tool_layout`); those are not replacements for these updaters.

## Usage instructions

```matlab
% Usually invoked by widget callbacks; manual refresh example:
zef_update_colorscale;
```

After changing many segmentation cells, prefer `zef_update` (core) rather than calling every table updater by hand.

## Important notes

- String callbacks need base-workspace `zef`.
- `zef_update_parcellation` pushes state onto controls (inverse of typical slider updaters).
- Not every updater triggers `zef_plot_meshes` — expect a separate visualize step.

## Developer guidance

- One concern per `zef_update_<field_group>`; always read through `zef.h_*`.
- Keep bulk compartment-table logic in `zef_update` + `zef_get_data_compartment_table`.
- When adding a figure slider, wire Callback here **and** document the field in `src/gui/tools` / figure-tool layout helpers.
- Pitfall: duplicating mesh-tool updates here instead of `zef_update_mesh_tool`.
