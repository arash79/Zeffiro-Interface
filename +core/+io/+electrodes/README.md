# Electrode file parsers (`+core/+io/+electrodes`)

## Folder purpose

EEG/TES (and some EIT) problems need sensor coordinates on the scalp. This package turns a `.csv` or `.dat` file into a numeric matrix and a list of labels. The GUI menu **Import → Import electrodes** is the usual entry; the same parsers are callable from MATLAB without a session. They do **not** attach electrodes to the FEM mesh—attachment and CEM coupling happen later in `zef_build_electrodes` during lead-field assembly.

## Main contents

| Function | Role |
|----------|------|
| `from_csv` | Headered table → N×3 or N×6 positions + labels |
| `from_dat` | Whitespace lines (3/4/6/7 fields) → same outputs |

Related: `core.gui.menu_tool.import_electrodes_callback` (file picker and `zef` writes). Sample files under `data/electrodes/` and project electrode dumps.

## Code functionality

**CSV:** Header required. Columns `x`,`y`,`z` required; `label` optional (default `S1`, `S2`, …); `inner_radius`, `outer_radius`, `impedance` all three or none (partial CEM columns ignored with warning). Validation: CEM convertible to double; `inner_radius >= 0`; `impedance >= 0`; `inner_radius < outer_radius`. The returned N×6 matrix is `[x y z outer inner Z]` so attachment sees a non-empty annulus.

**DAT:** No header. Lines: `x y z` [label] [inner outer impedance]. A 6-column DAT line cannot carry a label (use 7). CEM impedance on DAT must be **strictly positive** (`<= 0` errors); CSV allows `0`. If every parsed CEM column is zero, DAT drops columns 4–6 and returns N×3.

Coordinates and radii are **not converted**—they must already match the project length unit (typically mm). Impedance is ohms.

## Workflow context

```
.dat / .csv → from_dat / from_csv → import_electrodes_callback
  → zef.sensors, s_points / s_name_list → zef_update
  → zef_attach_sensors_volume → zef_build_electrodes + lead field → zef.L
```

Prefix `s` is the default sensor set; if `zef.current_sensors` is `"s2"`, fields are `s2_points` / `s2_name_list`. Point electrodes (N×3) vs CEM (N×6): files list inner then outer; parsers return `[x y z outer inner impedance]` for `zef_attach_sensors_volume` / `zef_cem_electrode`. After Import, `zef_process_meshes` may still rebuild columns 4–6 from Segmentation-tool radius widgets for EEG. Changing coordinates after a lead field exists does not recompute `zef.L`.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));

[pos, names] = core.io.electrodes.from_csv("electrodes.csv");
[pos, names] = core.io.electrodes.from_dat("electrodes.dat");

zef.sensors = pos;
zef.s_points = pos;              % include columns 4–6 if CEM
zef.s_name_list = names;
zef = zef_update(zef);

[pos, names] = core.io.electrodes.from_csv("electrodes.csv", "MISSING_LABEL", "E");
zef = core.gui.menu_tool.import_electrodes_callback(zef);
```

GUI: Menu bar → **Import → Import electrodes** (`uigetfile` for `*.dat` / `*.csv`). Cancel or parse errors leave `zef` unchanged (`errordlg` on parse failure).

## Important notes

- Menu is under Import, not Edit.
- Re-run the forward script after changing electrode geometry that should affect `L`.
- Related: `src/gui/tools/zef_menu_tool.m`, `src/mesh/zef_build_electrodes.m`, `src/sensors/`, `src/forward/lead_field/`.

## Developer guidance

Keep parsers free of `zef` I/O. Document format differences from the implementation when they diverge from comments. Prefer extending validation in one place so GUI and scripts stay consistent.
