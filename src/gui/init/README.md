# Table and dialog init (`src/gui/init`)

**Scripts** (mostly) that write defaults onto `zef` and/or UITable column metadata when a tool or options window opens. They do not open figures (`src/gui/open` does that). `zef_init` in `src/core` is the session-wide dump; this folder is per-widget.

Scripts mutate caller `zef`. Converting one to a function requires updating every `zef_open_*` and `zef_update` call site.

## Segmentation tool

Called from `zef_update` / `zef_build_compartment_table` / sensor builders.

| File | Kind | Required workspace | What it fills |
|------|------|--------------------|---------------|
| `zef_init_fields_compartment_table` | script | `zef_i` (row), `zef_j` (tag index), `zef.aux_field_1` | Columns **Index, On, Name, Visible, Surface nodes, Surface triangles, Merge, Invert normal, Activity**. Activity is `compartment_activity{*_sources+2}`: Bounding box, Inactive, Constrained field, Unconstrained field, Active surface (`*_sources` = that index minus 2) |
| `zef_init_fields_compartment_table_profile` | script | same | Extra columns from enabled Segmentation `parameter_profile` rows |
| `zef_init_compartments` | script | `zef` | Empty table, then compartments from `zeffiro_segmentation.ini` unless `new_empty_project` |
| `zef_init_sensors` | script | `zef` | Reset tags; create default set `'s'` |
| `zef_init_sensors_table` | script | `current_tag` | Filename is historical: writes **Index, Name** on `h_transform_table`, not the sensors table |
| `zef_init_sensors_name_table` | **function** | — | **Index, Name, Visible** on `h_sensors_name_table` |
| `zef_init_sensors_parameter_profile` | script | `current_sensors` | Pad per-sensor profile arrays to point count (`evalin` base) |
| `zef_init_sensor_parameters` | script | `current_sensor_name` | Parameters table: X/Y/Z (and directions / gradients by imaging method) plus Sensors profile rows. Sets `current_parameters='sensor'` |
| `zef_init_transform` | script | `current_tag` | Transform table **Index, Name** |
| `zef_init_transform_parameters` | script | `current_transform` | Scaling, X/Y/Z-shift, Xy/Yz/Zx-rotation, Affine transform. Sets `current_parameters='transform'` |

## Option dialogs (before `zef_open_*` copies handles)

isfield-guarded defaults only — they do not copy widgets.

| File | Settings menu item |
|------|-------------------|
| `zef_init_forward_and_inverse_options` | **Forward and inverse processing options** |
| `zef_init_graphics_options` | **Graphics processing options** (the `cone_lattice_resolution` guard writes `cone_field_lattice_resolution`) |
| `zef_init_gaussian_prior_options` | **Hierarchical prior options** |
| `zef_init_options` | shared / historical catch-all. If `reconstruction_type` is missing it writes **1**; a normal session already has **7** from `zef_init`. |
| `zef_init_parameter_profile` | creates missing `zef.<tag>_<param>` from the profile (does not open the editor) |
| `zef_init_init_profile` | applies `init_profile` rows (`string` / `number` / `evaluate`) |
| `zef_init_profile_table_selection` | **function**; Pre-settings table click → `init_profile_selected` |
| `zef_init_parcellation` | Parcellation defaults + scan `time_series_tools` for `Description:` |
| `zef_init_butterfly_plot` | Butterfly `bf_*` from inverse defaults, then widget String |
| `zef_init_find_synthetic_eit_data` | ROI widget strings from `inv_roi_sphere` |
