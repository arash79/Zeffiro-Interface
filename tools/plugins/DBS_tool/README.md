# tools/plugins/DBS_tool

## Folder purpose

Deep-brain stimulation **probe contact geometry** → current sensor points on `zef.<current_sensors>_points`. Title spelling in the UI may read “Deeb brain…”. **Not** registered on default profile INIs — call the start function manually. Sensor-focused; does not embed FEM strip compartments (contrast `StripTool`).

## Main contents

| File | Role |
|------|------|
| `zef_DBS_strip_struct_start` / `_open` / `_window` | Open GUIDE UI |
| `zef_DBS_strip_struct_init` | Defaults for `strip_struct` |
| `zef_DBS_strip_struct_update` | Build contacts: type 1 Medtronic-style 40-contact / type 2 Abbott Infinity 8-contact |
| `zef_electrode_strip_multiple_probe` | Medtronic-style multi-probe builder |
| `zef_Abbott_infinity_strip_multiple_probe` | Abbott Infinity builder |
| `zef_DBS_update_electrodes` → `zef_DBS_attach_electrodes` | Copy onto sensor point tables (+ radii, impedance) |
| `zef_electrode_strip` | Standalone single-probe constructor (**not** wired to the window) |

`temp.txt`, if present, is leftover scratch — ignore.

## Code functionality

User sets probe center, direction, `strip_type`, `probe_num` → Run builds `electrode_data` → Attach writes sensor points for the active sensor set. No lead-field recompute.

## Workflow context

```
Manual start → GUIDE UI → electrode points on zef
  → later mesh electrode attachment / forward as usual
```

Related: `StripTool` (cylinder strip as compartments + contacts), electrode import (`data/electrodes`, `core.io.electrodes`).

## Usage instructions

```matlab
zef_DBS_strip_struct_start;
% Set geometry / type → Run → Attach electrodes
```

## Important notes

- Not on default **Forward/Multi tools** menus.
- Sensors only — no automatic compartment creation.
- Units must match the project sensor frame (typically mm).

## Developer guidance

- Wire into a profile INI only if the site routinely uses DBS probes.
- Prefer extending the multi-probe builders rather than the unwired `zef_electrode_strip` unless reconnecting the UI.
- Pitfall: attaching contacts without a matching FEM / lead-field type and expecting immediate `zef.L` updates.
