# Create dipolar pair

Appends **two electrode points** (a dipolar pair) to the current sensor set `zef.<current_sensors>_points`, with opposite entries in `zef.current_pattern`. For tES / current-injection setups, not MEG inverse.

**Not in the default profile INI.** Call `zef_create_dipolar_pair_start` from MATLAB.

## How to open it

```matlab
zef_create_dipolar_pair_start;   % script
```

Title: **ZEFFIRO Interface: Create Dipolar Pair**. Needs `zef.current_sensors` naming an existing sensor prefix with `_points` and `_name_list`.

## Buttons (`buttonpushedfcn` in `m/zef_create_dipolar_pair_start.m`)

| Handle | Action |
|--------|--------|
| **Add** | `zef_create_dipolar_pair_add` — normalize orientation, append two points at ±separation/2, names `tag 1` / `tag 2`, impedance in column 6; `current_pattern` last two entries `[-1; 1]` scaled by `(1e-6)*strength/separation` |
| **Plot** | `zef_create_dipolar_pair_plot` |

Then `zef_update`. Table refresh: `zef_create_dipolar_pair_update_table`.

## Scripting

```matlab
zef_create_dipolar_pair_add;
```
