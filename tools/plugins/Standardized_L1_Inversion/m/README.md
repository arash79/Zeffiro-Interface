# Standardized_L1_Inversion / m

MATLAB for sL1 MAP: `zef_sl1_map_estimation` opens the window; `zef_sl1_iteration` is the solver. User manual: parent README.

Related class `inverse.HALpRInverter` is a different track.

## Internals

| File | Role |
|------|------|
| `zef_sl1_map_estimation.m` | INI callback |
| `zef_init_sl1.m` | Window, defaults, **live** Start → `zef_sl1_iteration` |
| `zef_sl1_map_estimation_window.m` | GUIDE dump |
| `zef_update_sl1.m` | Widgets → `sl1_*` |
| `zef_sl1_iteration.m` | Solver (`quadprog`) |
| `zef_l2_l1_optimizer.m` | Inner L2-L1 QP |

## Unpatched (filename ≠ function)

- File `zef_sl1_map_estimation.m` declares `sl1_map_estimation`. MATLAB calls the filename (`zef_sl1_map_estimation` in the INI).
- Dump Start is `zef.reconstruction = sl1_iteration(zef)` (no such function). Init overrides to `zef_sl1_iteration`.
