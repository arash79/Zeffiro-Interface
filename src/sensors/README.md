## Folder purpose

A **sensor set** is one EEG cap, MEG helmet, EIT electrode array, or similar: positions, optional orientations, names, and how they attach to the volume mesh. This folder allocates tagged fields, fills Segmentation-tool tables, and snaps contacts onto the FEM surface before a lead field is built.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_create_sensors.m` | function | Default `<tag>_*` |
| `zef_build_sensors_table.m` | function | Fill sensors table from zef (8 columns: Index/Name/Modality/On/Visible/Tags/Points/Directions) |
| `zef_attach_sensors_volume.m` | function | Snap to volume/surface; returns attachment table |
| `zef_fix_sensors_get_functions_array_size.m` | function | Pad/trim `_get_functions` cell |
| `zef_sensor_get_function_eval.m` | function | `feval` placement string |
| `zef_cem_electrode.m` | function | Append CEM radius/impedance columns |
| `zef_pem2cem.m` | function | Expand point-like CEM rows to skin triangles; buried 4-row barycentric contacts error |
| `zef_electrode_struct.m` | function | Boundary edges of attached CEM patches |
| `zef_get_sensor_points.m` / `zef_get_sensor_directions.m` | **script** | Load DAT into the session |

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

`[outer, inner, impedance]` in columns 4–6 is what `zef_cem_electrode` and the Import parsers write. `zef_process_meshes` may overwrite 6-column radii from Segmentation-tool widgets. File values are not copied onto those widgets automatically — lead-field runs then use widget radii unless you copy file values.

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
- Do not pass `zef.sensors` (`N×6`) into `zef_lead_field_eeg_fem` yourself. The FEM treats anything other than **4** columns as PEM, so a 6-column CEM array is silently treated as point electrodes. `zef_lead_field_matrix` passes the attachment table instead. Layout: [docs/conventions.md](../../docs/conventions.md).

## Developer guidance

New modality: defaults in `zef_create_sensors` + attachment rules in `zef_attach_sensors_volume` + imaging-method list in `zef_init`. Keep CSV column layout consistent with `+core/+io/+electrodes` (3 vs 6 columns).
