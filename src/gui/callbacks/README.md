# src/gui/callbacks

## Folder purpose

Click, selection, and apply handlers for Segmentation tables, Settings profile dialogs, a few Figure-tool toggles, plus geometry/prior helpers used by mesh and inverse code. Complements `src/gui/update` (widget → field sync) and `src/core/zef_update.m` (bulk table sync).

## Main contents

### Compartments / segmentation

`zef_add_compartment`, `zef_delete_compartment`, `zef_delete_all_compartments`, `zef_add_bounding_box`, `zef_compartment_table_selection`, `zef_toggle_lock_on`

### Sensors / transforms

Add/delete: `zef_add_sensors`, `zef_delete_sensor_sets`, `zef_add_sensor_name`, `zef_delete_sensors`, `zef_add_transform`, `zef_delete_transform`, `zef_apply_transform`  
Selection / locks: `zef_sensors_table_selection`, `zef_sensors_name_table_selection`, `zef_transform_table_selection`, `zef_toggle_lock_sensor_sets_on`, `_sensor_names_on`, `_transforms_on`

### Figure tool

`zef_toggle_figure_controls`, `zef_toggle_edges` (wired from `zef_figure_tool`; controls toggle re-runs `zef_figure_tool_layout`)

### Profiles / settings

Apply: `zef_apply_parameter_profile`, `zef_apply_init_profile`, `zef_apply_system_settings`  
Table selection: `zef_parameter_profile_table_selection`, `zef_segmentation_profile_table_selection`, `zef_system_settings_table_selection`, `zef_plugin_settings_table_selection`

### Mesh tool

`zef_forward_simulation_table_selection` (script table for Run script)

### Inverse priors (not menu-only)

`zef_find_gaussian_prior`, `zef_find_g_hyperprior`, `zef_find_ig_hyperprior` — used by IAS/RAMUS/HBSampler/EXP and `+inverse` IAS/RAMUS inverters

### Geometry helpers

`zef_find_active_compartment_ind`, `zef_find_relative_resolution`, `zef_find_adjacent_tetra`, `zef_find_intersecting_triangle` (uses `zef_3by3_solver`), `zef_find_subdomain_ind`, plus thinner helpers (`zef_find_compartment`, `zef_find_enclosed_volume`, `zef_find_object_handles`)

### Legacy / misc

`zef_switch_color`, `zef_switch_onoff`, `zef_delete_original_field`, `zef_delete_original_surface_meshes`, `zef_find_synthetic_eit_data`, `zef_add_package` (unused from default menus)

## Code functionality

Typical pattern: read selection / button state from `zef.h_*` → mutate `zef` fields / tables → often `zef_update` or `assignin('base','zef',zef)`. String `MenuSelectedFcn` / `ButtonPushedFcn` callbacks assume base-workspace `zef`.

## Workflow context

```
zef_menu_tool / zef_segmentation_tool / zef_figure_tool / zef_open_*
    → callback in this folder
    → zef fields / tables
    → zef_update or tool-local update
```

Electrode **file** import is not here — see `core.gui.menu_tool.import_electrodes_callback`.

## Usage instructions

Prefer the same entry points the GUI uses (do not invent parallel CRUD):

```matlab
% Examples (display session):
zef_add_compartment;
zef_apply_transform;
zef_toggle_figure_controls;
```

## Important notes

- Delete paths usually require the relevant **On** flag unchecked; selection row order may be reversed vs tag order.
- Prior helpers are shared with class inverters — changing formulas affects both GUI plugins and `+inverse`.
- `zef_find_synthetic_eit_data` opens a legacy `.fig`; menu strings may still say `find_synthetic_eit_data`.

## Developer guidance

- Wire new menu items in `src/gui/tools`; put slider sync in `src/gui/update`; keep bulk table sync in `src/core/zef_update`.
- Document geometry helper callers when moving files — lead field and mesh postprocess depend on several `zef_find_*` routines.
- Pitfall: treating this folder as “UI only” and breaking inverse priors or mesh predicates.
