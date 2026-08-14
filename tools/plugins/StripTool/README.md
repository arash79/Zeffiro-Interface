# Strip tool

Defines depth-electrode **strips** as extra compartments (optional encapsulation) and can add their contacts to the current sensors. Each strip is a struct in `zef.<current_sensors>_strip_cell`.

**Not in the default profile INI.** Call `zef_strip_tool_start` from MATLAB. DBS_tool is the probe-sensor cousin.

## How to open it

```matlab
zef = zef_strip_tool_start(zef);   % zef_tool_start → zef_strip_tool_open
```

Need a current sensor prefix and a FEM/segmentation context for embedding.

## Buttons (`Callback` in `zef_strip_tool_window.m`)

| Label | Action |
|-------|--------|
| **Add** | `zef_strip_tool_add` — new strip in the list |
| **Embed** | confirm → `zef_strip_tool_embed` — `zef_create_strip` + coordinate transform; `zef_add_compartment` for strip (and encapsulation if on); copies triangles/points/σ onto the new compartment; status `'Embedded'`. After Embed, geometry widgets (tip, orientation, length, conductivity, encapsulation, Embed itself) are **disabled** until you Delete the strip. |
| **Add contacts** | confirm → `zef_strip_tool_add_contacts` |
| **Delete** | confirm → `zef_strip_tool_delete` |
| **Plot** | `zef_strip_tool_plot` |

Most numeric widgets only run `zef_strip_tool_update` (copy into the current strip struct). List box sets `zef.strip_tool.current_strip` and re-inits.

## Scripting

```matlab
zef = zef_strip_tool_add(zef);
zef = zef_strip_tool_embed(zef);
```
