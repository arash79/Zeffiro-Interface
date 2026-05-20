# src/gui/callbacks

## Folder purpose

**Event handlers** for discrete user actions in Zeffiro tools: compartment/sensor/transform CRUD, table selection side effects, profile application, toggles, and geometry helpers used by menus and inverse option dialogs.

## Main contents

Representative groups (48 files total):

| Group | Examples |
|-------|----------|
| Compartment CRUD | `zef_add_compartment`, `zef_delete_compartment`, `zef_delete_all_compartments`, `zef_add_bounding_box` |
| Sensors / transforms | `zef_add_sensors`, `zef_delete_sensors`, `zef_add_transform`, `zef_apply_transform` |
| Table selection | `zef_compartment_table_selection`, `zef_sensors_table_selection`, `zef_forward_simulation_table_selection` |
| Profiles | `zef_apply_parameter_profile`, `zef_apply_system_settings`, `zef_apply_init_profile` |
| Mesh geometry | `zef_find_compartment`, `zef_find_adjacent_tetra`, `zef_find_active_compartment_ind` |
| Inverse helpers | `zef_find_gaussian_prior`, `zef_find_g_hyperprior`, `zef_find_synthetic_eit_data` |
| UI chrome | `zef_toggle_lock_on`, `zef_toggle_edges`, `zef_switch_color` |

## Code functionality

Typical pattern: read `zef.h_*_table` → mutate `zef` or table `Data` → `zef = zef_update(zef)` or targeted `zef_init_*`.

Many callbacks are referenced as **strings** from `zef_menu_tool.m` or table `CellSelectionCallback`, evaluated in base workspace.

## Workflow context

Wired from `src/gui/tools/*_tool.m` and `zef_menu_tool.m`. Forward/inverse pipelines call geometry helpers (`zef_find_compartment`) without GUI.

## Usage instructions

```matlab
zef = zef_add_compartment(zef);   % after segmentation tool open
```

GUI-only for most; geometry helpers callable programmatically with prepared `zef`.

## Important notes

- Callbacks assume `zef` in base or passed consistently — mixing breaks `eval` chains.
- Deleting all compartments is destructive — used by “new empty project” flows.

## Developer guidance

- New callback: function `zef = zef_my_action(zef)`, end with `zef_update` if tables change.
- Wire in tool script with full `zef = ...` assignment in callback string.
- Heavy work should use `zef_waitbar`, not block UI thread indefinitely.
