# DBS tool

Places one or two **deep-brain stimulation probes** (center + direction, probe count, strip type) and copies generated contact geometry onto the current sensor fields (`_points`, electrode radii, impedance).

**Not in the default profile INI.** Call `zef_DBS_strip_struct_start` from MATLAB. Related: `StripTool/` embeds strip **compartments** into the mesh; this tool writes **electrode sensors**.

## How to open it

```matlab
zef = zef_DBS_strip_struct_start(zef);   % zef_tool_start → zef_DBS_strip_struct_open
```

## Buttons (`Callback` in `zef_DBS_strip_struct_window.m`)

| Label | Action |
|-------|--------|
| **Run** | `zef = zef_DBS_strip_struct_update(zef)` — rebuild strip geometry from widgets (`zef.strip_struct.*`) |
| **Attach electrodes** | `zef = zef_DBS_update_electrodes(zef)` → `zef_DBS_attach_electrodes` — `zef.<current_sensors>_points = strip_struct.electrode_data` plus outer/inner radius and impedance columns; `zef.sensors_visual_size` |

Widgets: two probes’ center xyz, direction xyz, strip type, probe number. Geometry helpers: `zef_electrode_strip`, `zef_electrode_strip_multiple_probe`, `zef_Abbott_infinity_strip_multiple_probe`.

## Scripting

```matlab
zef = zef_DBS_strip_struct_update(zef);
zef = zef_DBS_attach_electrodes(zef);
```
