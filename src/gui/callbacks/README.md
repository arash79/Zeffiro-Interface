# Segmentation-table and menu callbacks (`src/gui/callbacks`)

These files are the **click handlers** for the Segmentation tool tables and a few Settings / Figure-tool items. They are not the Mesh tool (that is `src/gui/tools`) and not `zef_update` (that copies every table into `zef` after a change).

Most are called as **strings** from `zef_menu_tool.m`, evaluated in the base workspace where `zef` lives. Table **selection** callbacks are function handles (`@(h,e) zef_compartment_table_selection(h,e,[])`) and write `zef` via `evalin('base',…)`.

If you only need to add a tissue from a script, you can call the same functions the menus call.

## Compartments (tissues)

The compartment UITable is the list of scalp/skull/brain/… rows. Right-click it (uicontextmenu `h_menu_compartment_table`):

| Item | Function | What happens |
|------|----------|----------------|
| **Add compartment** | `zef_add_compartment` | New tag `cN`, default σ 0.33 S/m, empty surface. Then import a mesh. |
| **Delete compartment(s)** | `zef_delete_compartment` | Only rows with **On** unchecked. Sets Index to NaN; `zef_update` drops the tag. |
| **Lock on** | `zef_toggle_lock_on` | Stops edits while locked. |
| **Import surface mesh** | `zef_get_surface_mesh` (in `helpers/`) | STL / points / triangles into `<tag>_points` / `_triangles`. |

Clicking a row runs `zef_compartment_table_selection`: table rows are **reversed** relative to `zef.compartment_tags`, so row 1 is the last tag. That sets `zef.current_compartment` and `zef.compartments_selected` (used by Delete).

Scripting:

```matlab
zef = zef_add_compartment(zef);          % empty tissue
% then import a surface into zef.cN_points / zef.cN_triangles
zef = zef_update(zef);
```

`zef_delete_all_compartments` is **Project → New**, not the right-click Delete item.

Related: `src/compartments` (`zef_create_compartment`, `zef_compartment_tag`), `src/core/zef_update.m`.

## Sensors and transforms

Same pattern on the sensors and transform tables (context menus wired in `zef_menu_tool`):

| Item | Function |
|------|----------|
| **Add sensor set** / **Delete sensor set(s)** | `zef_add_sensors` / `zef_delete_sensor_sets` |
| **Add sensor** / **Delete sensor(s)** | `zef_add_sensor_name` / `zef_delete_sensors` |
| **Add transform** / **Delete transform(s)** | `zef_add_transform` / `zef_delete_transform` |
| Locks | `zef_toggle_lock_sensor_sets_on`, `_sensor_names_on`, `_transforms_on` |

Mesh tool **Apply transform** is `zef_apply_transform` (applies the affine on the selected transform row to surfaces/sensors). Selection callbacks: `zef_sensors_table_selection`, `zef_sensors_name_table_selection`, `zef_transform_table_selection`.

Electrodes from a file are **Import → Import electrodes**, not these add-sensor items (`+core/+io/+electrodes`).

## Figure tool

| Control | Function |
|---------|----------|
| **Toggle controls** | `zef_toggle_figure_controls` |
| **Toggle edges** | `zef_toggle_edges` |

## Settings / profiles

`zef_apply_parameter_profile`, `zef_apply_init_profile`, `zef_apply_system_settings` (also from `zef_start`). Table selection helpers copy the clicked profile row into `zef.*_selected` so Apply knows which INI row to load.

`zef_add_package` is unused from the default menus (`zef_read_function_call` is only referenced there).

## Geometry and inverse math (not always a button)

These live here because inverse dialogs and meshing call them, not because they are Segmentation menus:

| File | Role |
|------|------|
| `zef_find_gaussian_prior` | SNR (dB) → Gaussian prior variance `theta0` for MNE/IAS/… |
| `zef_find_g_hyperprior` / `zef_find_ig_hyperprior` | Gamma / inverse-gamma hyperpriors |
| `zef_find_relative_resolution` | 4^n face-count multiplier for surface resampling |
| `zef_find_active_compartment_ind` / `zef_find_subdomain_ind` / `zef_find_compartment` | Tag → index |
| `zef_find_adjacent_tetra` / `zef_find_intersecting_triangle` / `zef_find_enclosed_volume` | Mesh queries |
| `zef_find_synthetic_eit_data` | Synthetic EIT voltages |
| `zef_add_bounding_box` | Adds a box compartment via `zef_add_compartment` |
| `zef_delete_original_field` / `zef_delete_original_surface_meshes` | Drop cached originals (also from `zef_init`) |
| `zef_switch_color` / `zef_switch_onoff` | Bulk visible/on toggles |

## Mesh-tool forward table

`zef_forward_simulation_table_selection` stores which cell is selected so **Run script** evals the right INI row (`src/mesh` / Mesh tool README).

## See also

- `src/gui/tools/README.md` — which window owns which menu
- `src/gui/update/README.md` — sliders and option dialogs
- `src/core/README.md` — `zef_update`
