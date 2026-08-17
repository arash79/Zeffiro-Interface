# tools/plugins/CreateDipolarPair

## Folder purpose

Plugin that appends **two electrode points** (a dipolar pair) to the current sensor set `zef.<current_sensors>_points`, with opposite entries in `zef.current_pattern`. Intended for tES / current-injection setups, not MEG source imaging.

## Main contents

| Path | Role |
|------|------|
| `m/zef_create_dipolar_pair_start.m` | Open window; wire **Add** / **Plot** |
| `m/zef_create_dipolar_pair_add.m` | Append ±separation/2 points and current-pattern entries |
| `m/zef_create_dipolar_pair_plot.m` | Preview the pair |
| `m/zef_create_dipolar_pair_init.m` | Defaults |
| `m/zef_create_dipolar_pair_update_table.m` / `_update_struct.m` | Table ↔ struct sync |
| `mlapp/zeffiro_interface_create_dipolar_pair.mlapp` | App Designer UI |

## Code functionality

- **Add** normalizes orientation, appends two points named `tag 1` / `tag 2`, stores impedance in column 6 when used, and sets `current_pattern` last two entries to `[-1; 1]` scaled by `(1e-6)*strength/separation`.
- Calls `zef_update` afterward.
- Requires `zef.current_sensors` naming an existing sensor prefix with `_points` and `_name_list`.

Does not recompute `zef.L`; remesh / reattach / forward as needed for FEM use.

## Workflow context

Manual bipolar injection pairs for tES/EIT-style workflows. Related: ES Workbench (current optimization), StripTool/DBS (implant geometry), electrode import (`data/electrodes`).

**Not** in the default profile INI — call from MATLAB.

## Usage instructions

```matlab
zef_create_dipolar_pair_start;
% Title: ZEFFIRO Interface: Create Dipolar Pair
% Set center, orientation, separation, strength, tag → Add → optional Plot
```

## Important notes

- Units must match sensor coordinates (typically mm).
- Strength scaling includes `1e-6` — check physical units before interpreting currents.
- Pair is appended; repeated Add grows the sensor list.

## Developer guidance

- Keep pattern sign convention documented when changing Add.
- Pitfall: adding pairs without updating measurements / lead-field electrode indexing consistently.
