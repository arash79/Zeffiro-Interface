# Sensors (`src/sensors`)

A **sensor set** is one EEG cap, MEG helmet, EIT electrode array, or similar: positions, optional orientations, names, and how they attach to the volume mesh.

This folder allocates those tagged fields, fills the Segmentation-tool tables, and snaps contacts onto the FEM surface before a lead field is built.

## What you do in the GUI

In **ZEFFIRO Interface: Segmentation tool**:

| Table / menu | Role |
|--------------|------|
| **Sensor sets:** | One row per set (`zef.sensor_tags`). Imaging method, on/off, visibility. Cell edit → `zef_update`. |
| **Sensors:** | Names and per-contact flags for the **current** set (`zef.current_sensors`). |
| **Add sensor set** / **Delete sensor set(s)** | `zef_add_sensors` / `zef_delete_sensor_sets` |
| **Add sensor** / **Delete sensor(s)** | `zef_add_sensor_name` / `zef_delete_sensors` |
| **Import sensors → Points (DAT file)** | `zef_get_sensor_points` then `zef_init_sensors_parameter_profile` |
| **Import sensors → Directions (DAT file)** | `zef_get_sensor_directions` |
| **Import sensor names (DAT file)** | `zef_import_sensor_names` |
| **Toggle visible** | flip visibility on selected name-table rows |
| **Lock on** (sensor sets / names) | `zef.lock_sensor_sets_on` / `zef.lock_sensor_names_on` |

**Import → Import electrodes** (menu bar, not this table) writes `zef.sensors` and the active prefix via `+core/+io/+electrodes`. That is the CSV/DAT electrode path with optional CEM columns.

Mesh visualization **Attach electrodes** (`zef.attach_electrodes`) is a *plot* flag; the geometry snap used by the lead field is `zef_attach_sensors_volume`.

## Attachment (required before `zef.L`)

Every lead-field `*_make_all` path calls `zef_attach_sensors_volume` so contacts sit on the outer surface (or volume, depending on imaging method). Wrong attachment yields a wrong `zef.L`.

`zef_sensor_get_function_eval` runs a per-contact **get function** string (`feval`) when you supply a custom placement expression. Those strings are trusted MATLAB.

`zef_fix_sensors_get_functions_array_size` pads or trims the `_get_functions` cell to the electrode count.

`zef_triangles_2_sensor_boundary` offsets triangle indices onto the stacked sensor-boundary mesh.

## Fields

Prefix like compartments: `s_points`, `s_directions`, `s_name_list`, `s_imaging_method_name`, … `zef.current_sensors` is the active tag. CEM data (inner/outer radius, impedance) extends `_points` to 6 columns when the import file has them. `zef.imaging_method` must match the lead-field type (EEG vs MEG vs EIT).

`zef_build_sensors_table` is a **script**: it writes `h_sensors_table` from `sensor_tags` and expects `zef` in the caller.

## Scripting

```matlab
zef = zef_create_sensors(zef, 's');
zef = zef_attach_sensors_volume(zef, zef.sensors);
```

## Files

| File | Kind | Role |
|------|------|------|
| `zef_create_sensors.m` | function | Default `<tag>_*` |
| `zef_build_sensors_table.m` | **script** | Fill sensors table |
| `zef_attach_sensors_volume.m` | function | Snap to volume/surface |
| `zef_triangles_2_sensor_boundary.m` | function | Triangle index offset |
| `zef_fix_sensors_get_functions_array_size.m` | function | Cell length vs N sensors |
| `zef_sensor_get_function_eval.m` | function | `feval` placement string |

## Developer notes

- New modality: defaults in `zef_create_sensors` + attachment rules in `zef_attach_sensors_volume` + imaging-method list in `zef_init`.
- Keep CSV column layout consistent with `+core/+io/+electrodes` (3 vs 6 columns).
