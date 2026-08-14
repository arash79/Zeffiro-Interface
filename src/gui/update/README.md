# Widget → `zef` (`src/gui/update`)

Copy a control family into `zef` and, for Figure-tool sliders, mutate the live `axes1` patches. Labels below are `String=` on `uicontrol` in `zef_figure_tool.m` (not App Designer). Settings dialogs are opened from `zef_menu_tool.m`. Mesh visualization lives in `zef_mesh_visualization_tool.m`.

Most files here are **scripts** (workspace `zef`). Slider helpers and a few table rebuilders are **functions**. Converting a script to a function requires updating every string Callback that currently relies on base `zef`.

## Figure-tool sliders

Each slider Callback writes the matching `zef.update_*` / `zef.colorscale_*` field when `gca` is parented to `h_zeffiro`; otherwise it passes `gcf` so a popped-out axes still updates.

| Label | Tag | `zef` field | What is redrawn |
|-------|-----|-------------|-----------------|
| **Color min:** | `colorscale_min_slider` | `colorscale_min_slider` | `axes1` `CLim(1) *= 10^Value`, then contours |
| **Color max:** | `colorscale_max_slider` | `colorscale_max_slider` | `CLim(2) *= 10^(new-old)`, then contours |
| **Colormap:** | `colormapselection` | `update_colormap` | LUT via `zef_colormap` then contrast/brightness |
| Linear / Logarithmic | `colorscaleselection` | `update_colorscale` | `axes1.ColorScale` (`'linear'`/`'log'`). Separate from `zef.inv_scale` (20*log10 of reconstruction in `zef_plot_volume`) |
| **Distance:** | `update_zoom_slider` | `update_zoom` | `CameraViewAngle` |
| **Transp. rec.:** | `transparency_reconstruction_slider` | `update_transparency_reconstruction` | `FaceAlpha` on Tag=`reconstruction`. κ = `1.05^(-100*slider)` |
| **Transp. surf.:** | `transparency_surface_slider` | `update_transparency_surface` | Tag=`surface` |
| **Transp. sens.:** | `transparency_sensor_slider` | `update_transparency_sensor` | Tag=`sensor` |
| **Transp. cones:** | `transparency_cones_slider` | `update_transparency_cones` | Tag=`cones` |
| **Transp. add.:** | `transparency_additional_slider` | `update_transparency_additional` | regexp Tag `additional*` |
| **Brightness:** / **Contrast:** | `update_brightness_slider` / `update_contrast_slider` | both `update_*` | `Colormap` via `((x+b)/(1+b))^(1+c)`. Callbacks call `zef_update_contrast_and_brightness` (filename), not the split helpers |
| **Ambience:** | `update_ambience_slider` | `update_ambience` | `AmbientStrength` on patch children |
| **Diffusion:** | `update_diffusion_slider` | `update_diffusion` | `DiffuseStrength` (lighting, not conductivity) |
| **Specular exp.:** | `update_specular_slider` | `update_specular` | `SpecularStrength` (not SpecularExponent) |
| **Lights:** | `lightsselection` | `update_lights` | Light objects on `axes1` (1 reset ±z, 2 off, 3–5 add ±x/y/z, 6 headlight) |

`zef_update_fig_details` refreshes the **Compartments:** / **Sensors:** / **Details:** list boxes at the bottom (`zef_figure_tool` calls it at the end). Clicking the lists runs `zef_set_*_color` in `src/gui/set`.

`zef_update_contour` redraws Tag=`contour` on reconstruction patches when `zef.show_contour` (Mesh visualization tool). Also called after Color min/max.

## Segmentation / options dialogs

| File | Kind | Trigger | Writes |
|------|------|---------|--------|
| `zef_update_compartment_table_data` | function | `zef_update` | rebuilds `h_compartment_table` (flips `compartment_tags` L–R while filling). Needs `zef_i`, `zef_j`, `aux_field_1` inside the called init script |
| `zef_update_sensors_name_table` | script | name-table `CellEditCallback` | `*_name_list`, `*_visible_list`, permutes points/directions; then `zef_update` |
| `zef_update_parameters` | script | parameters table | transform slot or sensor row, keyed by `current_parameters` |
| `zef_update_transform` | function | transform table | `current_tag` transform arrays; reruns `zef_init_transform` |
| `zef_update_transform_parameters` | script | same table, `evalin` base | transform slot |
| `zef_update_options` | script | legacy options panel | historical catch-all (`mlapp` vs uicontrol) |
| `zef_update_forward_and_inverse_options` | script | **Settings → Forward and inverse processing options** `ValueChangedFcn` | meshing / PML / GPU / `source_model` |
| `zef_update_graphics_options` | script | **Settings → Graphics processing options** | cones / streamlines / `colortune_param` (`cone_alpha` stored as 1−widget) |
| `zef_update_gaussian_prior_options` | script | **Settings → Hierarchical prior options** | `inv_*` (`inv_amplitude_db` negated) |
| `zef_update_parcellation` | function | Parcellation tool | **pushes** `zef` onto widgets (HTML list), not the other way |
| `zef_update_find_synthetic_eit_data` | script | Generate synthetic EIT data | `inv_roi_sphere`, perturbation, noise |
| `zef_update_butterfly_plot` | script | Butterfly **Plot** / **Apply** | `bf_*` |
| `zef_update_source_positions` | function | unit change | returns rescaled positions (mm/cm/m) |
| `zef_update_lead_field_id` | function | lead-field bank events | id / id_max counters (no widget) |
| `zef_update_labeling_priority` | function | Forward/inverse **Labeling priority** menus | `*_labeling_priority` |
| `zef_update_parameter_distributions` | function | after profile apply | tetra-wise `zef.<param>` from compartment scalars |

Do not call a slider updater without the matching `h_*` handle (Figure tool must exist).

## Developer notes

- New slider: `h_*` in `zef_figure_tool`, default in `zef_init`, updater here, **Reset** path in `zef_set_figure_tool_sliders`.
- `zef_update_contrast_and_brightness.m` contains a primary function named `zef_update_contrast`; MATLAB still dispatches on the filename. The split files `zef_update_contrast.m` / `zef_update_brightness.m` are unused by the Figure tool.
