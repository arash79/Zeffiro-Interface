## Folder purpose

Hierarchical L1 MAP with `quadprog` (interior-point). Use it for sparse reconstructions when you want an L1 source prior and MATLAB Optimization Toolbox, as opposed to the EXP Lasso app.

## Main contents

- Start: `m/zef_sl1_map_estimation.m` → `zef_init_sl1`
- Solver: `m/zef_sl1_iteration.m`

## Code functionality

**Start** (`zef.h_sl1_start`) Callback (window constructor and `zef_init_sl1`):

```matlab
zef_update_sl1; [zef.reconstruction, zef.reconstruction_information] = zef_sl1_iteration(zef);
```

Type popup: `None`; `sLORETA`; `Column maximum` → `zef.sl1_type` 1–3. Type 1 leaves the L1 iterate as `zef_l2_l1_optimizer` returned it. Type 2 multiplies by `1./sqrt(diag(R))` with `R = (p L') (L p L' + σ² I)^{-1} L` and `p = 0.5 |z| θ` (sLORETA-style). Type 3 divides by `max(|L|)'` per column. Hyperprior: spatially balanced / constant (`zef.sl1_hyperprior`). Each MAP step updates `θ = (θ0 + |z|) / β` then re-solves the L1 QP (`quadprog` interior-point-convex, max iterations `ceil(2*sqrt(n_sources))`).

Needs: `zef.L`, interpolation, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.sl1_snr` → `10^(-sl1_snr/20)`; frames `zef.sl1_number_of_frames`, `sl1_time_*`, band edges; MAP iterations `zef.sl1_n_map_iterations`; Optimization Toolbox (`quadprog` / `linprog`).

Writes: `zef.reconstruction` after post-process / peak-norm; `zef.reconstruction_information` with tag `sl1`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Standardized Hierarchical L1 MAP Inversion (quadprog)** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | **not in those INIs** |

INI callback: `zef_sl1_map_estimation` (file `m/zef_sl1_map_estimation.m`). Window title: `ZEFFIRO Interface: Standardized Hierarchical L1 MAP estimation`.

Related class id `halpr` (`inverse.HALpRInverter`) is a **different** track — this Start button calls `zef_sl1_iteration`, not `+inverse`. Registry id `legacy_sl1` dispatches the plugin function.

## Usage instructions

1. Open Inverse tools → Standardized Hierarchical L1 MAP Inversion (quadprog) on the default profile.
2. Choose type (None / sLORETA / Column maximum) and hyperprior; set MAP iterations.
3. Press Start.

## Important notes

- Only registered on `multicompartment_head` by default (not legacy / NSE / asteroid INIs).
- Distinct from EXP Lasso app and from `halpr` / `inverse.HALpRInverter`.
- Requires Optimization Toolbox (`quadprog`).

## Developer guidance

Preserve callback `zef_sl1_map_estimation`, Start override in `zef_init_sl1`, tag `sl1`, and registry id `legacy_sl1`. Do not conflate with `halpr`.
