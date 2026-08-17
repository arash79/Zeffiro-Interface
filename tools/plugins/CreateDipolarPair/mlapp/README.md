# CreateDipolarPair — App Designer layouts

## Folder purpose

App Designer UI for the **Create Dipolar Pair** plugin, which appends two electrode points (a bipolar injection pair) to the current sensor set for tES / current-injection setups.

## Main contents

| File | Role |
|------|------|
| `zeffiro_interface_create_dipolar_pair.mlapp` | Create Dipolar Pair window (Add / Plot, separation, strength, orientation) |
| `README.md` | This documentation |

MATLAB logic lives in `tools/plugins/CreateDipolarPair/m/` (`zef_create_dipolar_pair_add`, `_plot`, `_update_table`, `_init`, …).

## Code functionality

`zef_create_dipolar_pair_start` opens this app, copies public properties onto `zef` as `h_*`, and wires **Add** → `zef_create_dipolar_pair_add` and **Plot** → `zef_create_dipolar_pair_plot`. Add normalizes orientation, appends `tag 1` / `tag 2` into `zef.<current_sensors>_points`, and sets opposite `current_pattern` entries scaled by strength/separation.

## Workflow context

Not registered on the default profile INI — call from MATLAB after a sensor prefix (`zef.current_sensors`) with `_points` / `_name_list` exists. For tES/EIT bipolar construction, not MEG inverse.

## Usage instructions

```matlab
zef_create_dipolar_pair_start;   % opens zeffiro_interface_create_dipolar_pair.mlapp
% Title: ZEFFIRO Interface: Create Dipolar Pair
```

Edit the layout only in MATLAB App Designer. Prefer the start script over opening the `.mlapp` directly for production runs.

## Important notes

- Single `.mlapp` — keep widget Tags aligned with the start script’s `h_*` copies.
- Add extends live sensor arrays; confirm `current_sensors` before pressing Add.

## Developer guidance

- Preserve start entry `zef_create_dipolar_pair_start` for any future INI registration.
- Document strength/separation units next to the `(1e-6)` scale in `_add` if physics conventions change.
- Put new controls in the parent plugin README, not only here.
