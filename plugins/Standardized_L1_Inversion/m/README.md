# Standardized_L1_Inversion / m

## Folder purpose

Legacy GUI for **standardized hierarchical L1 MAP** inversion (sparse L2–L1 via `quadprog`). Menu Inverse tools → Standardized Hierarchical L1 MAP Inversion (quadprog). Does not call `inverse.HALpRInverter`.

## Main contents

| File | Role |
|------|------|
| `zef_sl1_map_estimation.m` | INI entry (`zef_sl1_map_estimation`) |
| `zef_init_sl1.m` | Window, defaults, Start callback |
| `zef_sl1_map_estimation_window.m` | GUIDE dump |
| `zef_update_sl1.m` | Widgets → `sl1_*` / `inv_*` |
| `zef_sl1_iteration.m` | Outer MAP / frame loop |
| `zef_l2_l1_optimizer.m` | Inner `quadprog` Lasso lift |

## Code functionality

- Start: `zef_update_sl1; [zef.reconstruction, zef.reconstruction_information] = zef_sl1_iteration(zef)`.
- Iteration uses `sl1_snr`, `sl1_n_map_iterations`, `sl1_type` (2 = sLORETA-style diag(R); 3 = column max), IG hyperprior via `zef_find_ig_hyperprior`, `zef_processLeadfields` / `zef_getFilteredData`.
- `zef_l2_l1_optimizer(L,y,reg_param,options)` solves lifted QP `[z; t]` with `t ≥ |z|` and returns the source half.
- Tag in info: `'sl1'`.

## Workflow context

Needs Optimization Toolbox (`quadprog`), `zef.L`, and measurements. Same place in the pipeline as IAS/MNE: invert → store reconstruction → visualize or cluster.

## Usage instructions

1. Confirm `quadprog` is available.
2. Launch via menu or `zef_sl1_map_estimation`.
3. Set `sl1_hyperprior`, type, SNR, iterations, time/filter; Start.
4. Inspect `zef.reconstruction` and `reconstruction_information`.

## Important notes

- Start callback is `zef_sl1_iteration` (set in the window constructor and again in `zef_init_sl1`).
- Inner QP size is `2 * n_sources`; large lead fields are expensive.

## Developer guidance

Change Lasso formulation only in `zef_l2_l1_optimizer`; keep MAP/frame orchestration in `zef_sl1_iteration`. Mirror IAS field naming (`sl1_*`) when adding widgets. Prefer class inverter for new sparse methods if that API is required.
