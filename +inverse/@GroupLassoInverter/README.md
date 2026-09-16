# inverse.GroupLassoInverter

Group LASSO penalizes the ℓ₂ norm of each 3-component source together, so a location is either on (all three components) or off, rather than shrinking axes independently. The MAP loop calls `LG_optimization` in `src/inverse`.

Registry ids: `grouplasso`, `group_lasso`. Inverse tools → Group Lasso opens a class-inverter dialog. Related legacy GUI remains EXP / Lasso.

## Main contents

| File | Role |
|------|------|
| `GroupLassoInverter.m` | `estimation_type` (IAS/EM/Standardized), hyperpriors, L1 iteration counts |
| `initialize.m` | `noise_cov` + dynamic `SNR_variable` |
| `invert.m` | MAP loop calling `LG_optimization`; updates `gamma = β/(θ₀ + ‖z‖₂)` |

## Code functionality

**Dependencies:** `src/inverse/LG_optimization.m` must be on the MATLAB path (`genpath(src)` from `zeffiro_interface`).

**Inputs:** `run_frame_loop` calls `invert` once per frame with a single measurement column. `procFile`, `source_direction_mode`, and `source_positions` are unused here (kept for the shared inverter signature). `size(L,2)` must be a multiple of 3. Partial NaNs in a MAP iterate are replaced by the mean of finite `|z|` (one warning); an all-NaN iterate errors.

**Key defaults:** `estimation_type="IAS"`, `hyperprior_mode="Sensitivity weighted"`, `beta=3`, `theta0=1e-10`, `n_map_iterations=25`, `n_L1_iterations=5`.

## Workflow context

```
zef_inverse_run(zef,'grouplasso') → run_frame_loop → GroupLassoInverter → LG_optimization
```

GUI-related: EXP App / Standardized L1–L2 Lasso menus call legacy `exp_iteration` / SL1 paths, not necessarily this class.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'grouplasso', 'execution', 'local');
```

## Important notes

- Heavy dependency on EXP common optimizers — keep plugins on path even for “class-only” scripts.

## Developer guidance

- When migrating EXP GUI to class API, map estimation_type strings carefully.
- Prefer extending `LG_optimization` over copying IRLS loops into `invert.m`.
