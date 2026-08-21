# src/sensors
## Folder purpose

A **sensor set** is one EEG cap, MEG helmet, EIT electrode array, or similar: positions, optional orientations, names, and how they attach to the volume mesh. This folder allocates tagged fields, fills Segmentation-tool tables, and snaps contacts onto the FEM surface before a lead field is built.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_create_sensors.m` | function | Default `<tag>_*` |
| `zef_build_sensors_table.m` | **script** | Fill sensors table (expects `zef` in caller) |
| `zef_attach_sensors_volume.m` | function | Snap to volume/surface; returns attachment table |
| `zef_triangles_2_sensor_boundary.m` | function | Triangle index offset |
| `zef_fix_sensors_get_functions_array_size.m` | function | Pad/trim `_get_functions` cell |
| `zef_sensor_get_function_eval.m` | function | `feval` placement string |

## Code functionality

Prefix fields like compartments: `s_points`, `s_directions`, `s_name_list`, `s_imaging_method_name`, …. `zef.current_sensors` is the active tag. `zef.imaging_method` must match lead-field type.

**Attachment** (required before `zef.L` for EEG/EIT/TES; MEG does **not** attach):

```matlab
zef.sensors_attached_volume = zef_attach_sensors_volume(zef, zef.sensors);
```

`attach_type`: `'mesh'` (FEM / Visualize volume), `'geometry'` (surfaces), `'points'` (CEM name labels).

| Input | Model | Attachment |
|-------|--------|------------|
| N×3 | PEM | Nearest scalp node (or volume node if depth electrodes on) |
| N×6, col4=col5=0 | Buried CEM | Barycentric coords in enclosing tet (4 rows/contact) |
| N×6, col4=0, col5=1 | Point-like CEM | One nearest surface vertex |
| N×6 otherwise | Annular CEM | Triangles with inner (col5) ≤ d < outer (col4) |

`[outer, inner, impedance]` in columns 4–6 is what `zef_cem_electrode` writes. `zef_process_meshes` may overwrite 6-column radii from Segmentation-tool widgets. **Import → Import electrodes** stores `[inner, outer, impedance]` and does **not** fill widgets — lead-field runs then use widget radii unless you copy file values.

## Workflow context

In Segmentation tool: **Sensor sets:** / **Sensors:** tables; Add/Delete set or sensor; Import points/directions/names DAT; Toggle visible; Lock on. **Import → Import electrodes** (menu bar) writes via `+core/+io/+electrodes`. Mesh-vis **Attach electrodes** is a *plot* flag; geometry snap for lead field is `zef_attach_sensors_volume`.

## Usage instructions

```matlab
zef = zef_create_sensors(zef, 's');
zef.sensors_attached_volume = zef_attach_sensors_volume(zef, zef.sensors);
```

Per-contact **get function** strings are trusted MATLAB (`zef_sensor_get_function_eval`).

## Important notes

- Wrong attachment yields a wrong `zef.L`.
- Attachment returns a table — assign it; it does not mutate `zef` in place.

## Developer guidance

New modality: defaults in `zef_create_sensors` + attachment rules in `zef_attach_sensors_volume` + imaging-method list in `zef_init`. Keep CSV column layout consistent with `+core/+io/+electrodes` (3 vs 6 columns).
