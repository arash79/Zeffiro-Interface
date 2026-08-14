# Electrode file parsers (`+core/+io/+electrodes`)

EEG/TES (and some EIT) problems need sensor coordinates on the scalp. This package turns a `.csv` or `.dat` file into a numeric matrix and a list of labels. The GUI menu **Import → Import electrodes** is the usual entry; the same parsers are callable from MATLAB without a session.

They do **not** attach electrodes to the FEM mesh. After import, `zef.sensors` holds the coordinates. Attachment and complete-electrode-model (CEM) coupling happen later in `zef_build_electrodes` during lead-field assembly (`src/mesh` / `src/forward`).

## How this fits the rest of Zeffiro

```
.dat / .csv file
    → core.io.electrodes.from_dat  or  from_csv
    → core.gui.menu_tool.import_electrodes_callback
    → zef.sensors, zef.s_points, zef.s_name_list
    → zef_update  (segmentation / mesh tools show the sensors)
    → zef_attach_sensors_volume  (when a volume mesh exists)
    → zef_build_electrodes + lead field  → zef.L
```

`from_csv` / `from_dat` have no `zef` argument. The callback is what writes session fields. Prefix `s` is the default sensor set; if `zef.current_sensors` is `"s2"`, fields are `s2_points` and `s2_name_list`.

## File formats

Coordinates and radii are **not converted**. They must already be in the project length unit (typically millimetres, same as the segmentation). Impedance is ohms.

### CSV (`from_csv`)

Header row required. Column names are MATLAB `readtable` variable names, matched case-sensitively:

| Column | Required | Meaning |
|--------|----------|---------|
| `x`, `y`, `z` | yes | Cartesian position |
| `label` | no | Sensor name; default `S1`, `S2`, … |
| `inner_radius`, `outer_radius`, `impedance` | all three or none | CEM disc / gel / contact impedance |

If only some CEM columns are present, they are ignored with a warning. Output is N×3 or N×6.

Validation: CEM values must convert to double; `inner_radius >= 0`; `impedance >= 0`; `inner_radius < outer_radius`.

### DAT (`from_dat`)

No header. Each non-empty line is whitespace-separated with 3, 4, 6, or 7 fields:

```
x y z
x y z label
x y z inner_radius outer_radius impedance
x y z label inner_radius outer_radius impedance
```

Example files in this tree: `data/` electrode dumps and `ProneFreeSurfer/ascii/electrodes.dat`.

Differences from CSV (from the implementation, not from comments):

- A 6-column DAT line cannot carry a label (use 7 columns).
- CEM impedance on a DAT row must be **strictly positive** (`<= 0` errors). CSV allows `0`.
- If every parsed CEM column is zero, DAT drops columns 4–6 and returns N×3 even if some lines were 6-wide.

## GUI

Menu bar (window created by `zef_menu_tool`): **Import → Import electrodes**.

That calls `core.gui.menu_tool.import_electrodes_callback(zef)`:

1. `uigetfile` for `*.dat` / `*.csv`.
2. Parse with `from_dat` or `from_csv`.
3. `zef.sensors = electrode_data` (full 3 or 6 columns).
4. `zef.<prefix>_points` = xyz, plus CEM columns when present.
5. `zef.<prefix>_name_list` = labels.
6. `zef_update`.

Cancel leaves `zef` unchanged. Parse errors show `errordlg` and also leave `zef` unchanged.

## Scripting

```matlab
addpath(fileparts(which('zeffiro_interface')));   % exposes core.*

[pos, names] = core.io.electrodes.from_csv("electrodes.csv");
% or
[pos, names] = core.io.electrodes.from_dat("electrodes.dat");

zef.sensors = pos;
zef.s_points = pos;              % include columns 4–6 if CEM
zef.s_name_list = names;
zef = zef_update(zef);
```

Default labels use prefix `"S"`. Override:

```matlab
[pos, names] = core.io.electrodes.from_csv("electrodes.csv", "MISSING_LABEL", "E");
```

Interactive picker with an existing session:

```matlab
zef = core.gui.menu_tool.import_electrodes_callback(zef);
```

## Point electrodes vs CEM

- **Point** (N×3): Dirichlet / point-sensor model in `zef_build_electrodes`.
- **CEM** (N×6): `inner_radius` is the metal, `outer_radius` the gel; both must be consistent with the scalp mesh scale. Lead-field TES/EEG paths that see 6-column `zef.sensors` build the extra `B` and `C` electrode matrices.

Changing coordinates after a lead field exists does **not** recompute `zef.L`. Re-run the forward script.

## Related code

| Location | Role |
|----------|------|
| `+core/+gui/+menu_tool/import_electrodes_callback.m` | File picker and `zef` writes |
| `src/gui/tools/zef_menu_tool.m` | Wires the Import menu |
| `src/mesh/zef_build_electrodes.m` | FEM coupling |
| `src/sensors/` | Geometry helpers, volume attachment |
| `src/forward/lead_field/` | Consumes `zef.sensors` when assembling `L` |
