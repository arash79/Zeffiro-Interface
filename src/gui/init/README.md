# Table and dialog init (`src/gui/init`)

## Folder purpose

**Per-widget and per-dialog defaults** for the GUI: seed missing `zef` fields and UITable column metadata when a tool or options window opens. Distinct from session-wide `src/app/zef_init.m`. Most entries are **scripts** that mutate caller/workspace `zef`.

## Main contents

### Segmentation / sensors / transforms

| File | Role |
|------|------|
| `zef_init_compartments` | Empty table; load compartments from `zeffiro_segmentation.ini` unless `new_empty_project` |
| `zef_init_fields_compartment_table` | Fill compartment table columns (On, Name, Visible, Activity, …) |
| `zef_init_fields_compartment_table_profile` | Extra columns from parameter profile |
| `zef_init_sensors` / `zef_init_sensors_name_table` | Sensor set defaults and name table |
| `zef_init_sensor_parameters` / `zef_init_sensors_parameter_profile` | Parameters table for current sensor |
| `zef_init_transform` / `zef_init_transform_parameters` | Transform stack defaults |

### Option dialogs (before `zef_open_*`)

| File | Settings menu |
|------|----------------|
| `zef_init_forward_and_inverse_options` | Forward and inverse processing options |
| `zef_init_graphics_options` | Graphics processing options |
| `zef_init_gaussian_prior_options` | Hierarchical prior options |
| `zef_init_parameter_profile` / `zef_init_init_profile` | Profile field creation / apply |
| `zef_init_profile_table_selection` | GUIDE-style `CellSelectionCallback` for the Pre-settings profile table: writes unique selected rows to `zef.init_profile_selected` so Add/Delete in `zef_open_init_profile` know the insert/remove row. Does not edit table Data. |
| `zef_init_parcellation` | Parcellation defaults + scan time-series tools |
| `zef_init_butterfly_plot` | Butterfly plot defaults |
| `zef_init_find_synthetic_eit_data` | Synthetic EIT ROI widget strings |

## Code functionality

Scripts typically: `if ~isfield(zef, …)` set defaults; build table `ColumnName` / `Data`; sometimes `eval` dynamic `<tag>_*` fields. They **do not** open figures — `src/gui/open` does that after init.

**Activity codes** on compartments: Bounding box, Inactive, Constrained/Unconstrained field, Active surface (via `*_sources` index into `compartment_activity`).

## Workflow context

```
zef_open_* → zef_init_* → instantiate app → zef_update_* on edits
zef_update / zef_build_compartment_table → zef_init_fields_compartment_table*
```

Profile INIs under `profile/<name>/` supply segmentation and parameter templates.

## Usage instructions

Called automatically when opening tools/dialogs. Programmatic:

```matlab
zef_init_compartments;          % script — zef in workspace
zef = zef_init_sensors_name_table(zef);  % function form where available
```

## Important notes

- Most are **scripts**: converting to functions requires updating every `zef_open_*` call site.

## Developer guidance

- New dialog field: add default in the matching `zef_init_*`, widget in App Designer, sync in `zef_update_*`.
- Keep INI column order aligned with table builders.
- Prefer `isfield` guards so re-opening a dialog does not wipe user values.
