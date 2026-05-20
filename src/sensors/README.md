# src/sensors

## Folder purpose

**Sensor-set management** on `zef`: create tagged sensor structs (EEG/MEG/EIT electrodes), build GUI tables, snap positions to the FEM volume, and evaluate user-defined “get function” strings for custom sensor placement.

## Main contents

| File | Role |
|------|------|
| `zef_create_sensors.m` | Allocate `zef.<tag>_points`, `_directions`, `_imaging_method_name`, … |
| `zef_build_sensors_table.m` | Refresh `h_sensors_table` from `sensor_tags` (script) |
| `zef_attach_sensors_volume.m` | Snap sensor coordinates to outer surface/volume |
| `zef_triangles_2_sensor_boundary.m` | Relabel surface triangles for sensor boundary compartment |
| `zef_fix_sensors_get_functions_array_size.m` | Align `_get_functions` cell length to electrode count |
| `zef_sensor_get_function_eval.m` | `feval` wrapper for placement expression strings |

## Code functionality

Sensors use **dynamic field prefixes** like compartments (`s_points`, `s2_name_list`, …). `zef.current_sensors` selects active set.

`zef_attach_sensors_volume` is called from **every** lead-field `*_make_all` path before FEM assembly — incorrect attachment breaks `zef.L`.

Electrode import via menu uses `+core/+gui/+menu_tool/import_electrodes_callback` (writes `zef.sensors` and active prefix fields).

## Workflow context

| Consumer | Usage |
|----------|--------|
| `src/forward/lead_field/*` | Attachment + imaging method |
| `src/io` | Import/export sensor geometry |
| `+examples/+forward` | `zef_attach_sensors_volume` after mesh |
| Segmentation tool | Sensor tables and transforms |

## Usage instructions

```matlab
zef = zef_create_sensors(zef, 's');
zef = zef_attach_sensors_volume(zef, zef.sensors);
```

GUI: Segmentation tool → sensors table; Edit → Import electrodes.

## Important notes

- CEM columns (inner/outer radius, impedance) extend `_points` to 6 columns when present in import file.
- `zef.imaging_method` must match lead-field type (EEG vs MEG vs EIT).
- Get-function strings are `eval`'d — treat as trusted code only.

## Developer guidance

- New imaging modality: extend `zef_create_sensors` defaults and lead-field attachment rules.
- Keep consistent with `+core/+io/+electrodes` column layout (3 vs 6 columns).
- Document new sensor fields in `zef_init.m` and profile `zeffiro_init.ini`.
