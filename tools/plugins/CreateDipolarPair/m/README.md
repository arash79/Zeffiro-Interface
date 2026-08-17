# CreateDipolarPair / m

## Folder purpose

Scripts behind the **Create dipolar pair** App Designer tool: define a ± current dipole pair (origin, orientation, strength, separation) and append two sensor points plus a `current_pattern` entry for stimulation / EIT-style setups.

## Main contents

| File | Role |
|------|------|
| `zef_create_dipolar_pair_start.m` | Open app, wire Add/Plot buttons |
| `zef_create_dipolar_pair_init.m` | Default `create_dipolar_pair_*` fields → table |
| `zef_create_dipolar_pair_update_table.m` | Struct → uitable |
| `zef_create_dipolar_pair_update_struct.m` | Uitable → struct |
| `zef_create_dipolar_pair_add.m` | Append sensors + `current_pattern` |
| `zef_create_dipolar_pair_plot.m` | `quiver3` preview on `zef.h_axes1` |

## Code functionality

- Start loads `zeffiro_interface_create_dipolar_pair`, stores handles (`h_create_dipolar_pair*`), sets `buttonpushedfcn` to add/plot scripts, then `zef_create_dipolar_pair_init`.
- Add: normalize orientation; append two rows to `zef.<current_sensors>_points` and `_name_list` offset by ±½ separation along orientation; set `zef.current_pattern` (last two entries opposite, scaled by `1e-6 * strength/separation`); `zef_update`.
- Plot: delete previous `h_create_dipolar_pair_arrow`, draw quiver with color index `create_dipolar_pair_color`.

## Workflow context

Used when building electrode/current patterns for forward or tES workflows. Not a default Inverse-tools INI entry; launch via `zef_create_dipolar_pair_start` or a profile that registers the plugin. Depends on `zef.current_sensors` naming the active sensor set.

## Usage instructions

1. Select/create the sensor modality (`zef.current_sensors`).
2. Run `zef_create_dipolar_pair_start` (workspace `zef` required).
3. Edit table: xyz, orientation, strength (nAm), separation, impedance, tag.
4. Plot to preview; Add to commit points and `current_pattern`.

## Important notes

- Init checks `isfield(zef,'h_create_dipolar_pair_x')` but stores values in `create_dipolar_pair_*` (legacy field-name quirk).
- Add uses `evalin('base', …)` string concatenation for sensor arrays—tag strings must not break quotes.
- Plot only visualizes; it does not write sensors.

## Developer guidance

Keep table column order in sync across update_table / update_struct / add. Prefer App Designer UI in sibling `mlapp/`; this folder is the MATLAB glue. Do not assume the tool appears unless the profile INI lists it.
