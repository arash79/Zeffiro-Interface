# Create dipolar pair — MATLAB files (`m/`)

Not in the default profile INI. Open with `zef_create_dipolar_pair_start`. What the tool is for (tES pair, `current_pattern`): parent [../README.md](../README.md).

| File | Role |
|------|------|
| `zef_create_dipolar_pair_start.m` | **script** — window + button wiring (**Add** / **Plot**). |
| `zef_create_dipolar_pair_init.m` | Default separation, strength, tag, impedance. |
| `zef_create_dipolar_pair_add.m` | Append two points at ±separation/2; names `tag 1`/`tag 2`; `current_pattern` last two entries opposite. |
| `zef_create_dipolar_pair_plot.m` | Draw the pair. |
| `zef_create_dipolar_pair_update_table.m` | Refresh the on-window table. |
| `zef_create_dipolar_pair_update_struct.m` | Copy widgets onto `zef`. |

Layout: [../mlapp/README.md](../mlapp/README.md).
