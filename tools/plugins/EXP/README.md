# tools/plugins/EXP
## Folder purpose

Exponential / L1–L2 hierarchical MAP (IAS or EM, optional RAMUS coarsening). The default-profile tool is one App Designer window (`zef_exp_app_launch`) that calls shared `exp_iteration`. Asteroid profiles instead open the older GUIDE **EXP IAS RAMUS** window.

## Main contents

- Default start: `common/zef_exp_app_launch.m` → `zef_exp_app_start`
- Default solver: `common/exp_iteration.m`
- Layout: `common/exp_app.mlapp`
- Asteroid start: `exp_ias_multires/m/exp_ias_map_estimation_multires.m`
- Asteroid solver: `exp_ias_multires/m/exp_ias_iteration_multires.m`
- Related GUIDE solvers (not on default menu): `exp_ias_iteration`, `exp_em_iteration`, `exp_em_iteration_multires`

## Code functionality

### Unified app (default INI)

Window title: `ZEFFIRO Interface: Exponential Prior Tool`.

**StartButton** `ButtonPushedFcn`:

```matlab
[zef.reconstruction,zef.reconstruction_information] = exp_iteration(zef);
```

**CreateDecButton** builds `zef.EXP.parameters.exp_multires_*` via `exp_make_multires_dec` (needed if multiresolution is on). **ApplyButton** copies widgets via `zef_exp_init` (there is **no** `zef_exp_init.m` in this tree — the button errors until that helper exists). Numeric `exp_*` ValueChangedFcn uses `num2double` as written.

Estimation type in `zef.EXP.parameters` selects the tag: `EXP IAS`, `EXP EM`, or `EXP sLORETA`, plus ` Multiresolution` when `exp_use_multires` is true.

Each MAP iteration (inside `exp_iteration`) updates the reconstruction `z` then the per-source penalty `gamma` (initialized `beta/theta0` from the inverse-gamma hyperprior, or from the typed `exp_beta` / `exp_theta0` when hypermode is 3):

- `exp_q == 1`: `L1_optimization`, then `gamma = beta / (theta0 + |z|)`.
- otherwise: diagonal-weighted Tikhonov `z = (T_scale .* w) .* L' (L diag(w) L' + I)^{-1} f` with `w = 1/(gamma * σ² * max(f)²)`. Type 3 (sLORETA) sets `T_scale = 1/sqrt(diag(R))`; IAS/EM leave it 1. Then `gamma = beta / (theta0 + |z|^q)`.

Needs (unified `exp_iteration`): `zef.L`, interpolation, `zef.measurements`; SNR `zef.inv_snr` → `S_mat = (10^(-inv_snr/20))^2 * max(f_data.^2) * I`; frames `zef.number_of_frames`, `inv_time_*`, band edges; EXP parameters on `zef.EXP.parameters` (`exp_q`, map / L1 iteration counts, hypermode, optional multires fields).

### GUIDE EXP IAS RAMUS (asteroid / legacy INI)

Window title set in code: `ZEFFIRO Interface: IAS MAP multiresolution (RAMUS) for EP`. GUIDE resource name: `IAS MAP estimation multiresolution`.

**Start** Callback in `exp_ias_map_estimation_multires.fig`:

```matlab
zef_update_exp_ias_multires; [zef.reconstruction,zef.reconstruction_information] = exp_ias_iteration_multires([]);
```

Other GUIDE Start strings (not on the default menu):

- EXP IAS: `exp_ias_iteration([])`
- EXP EM: `exp_em_iteration([])`
- EXP EM RAMUS: `exp_em_iteration_multires([])`

Writes: `zef.reconstruction` and `zef.reconstruction_information`.

## Workflow context

| Profile | Path | Callback |
|---------|------|----------|
| `multicompartment_head` | Inverse tools → **Standardized Hierarchical L1/L2 MAP Inversion (Lasso)** | `zef_exp_app_launch` |
| `_legacy`, `_nse` | Inverse tools → **EXP IAS RAMUS** | `exp_ias_map_estimation_multires` |
| asteroid_radar / asteroid_gravity | Inverse tools → **EXP IAS RAMUS** | `exp_ias_map_estimation_multires` |

`exp_em_map_estimation`, `exp_ias_map_estimation`, and `exp_em_map_estimation_multires` are **not** in any default/asteroid INI; call them from MATLAB if you need those GUIDE windows.

Related class ids `grouplasso` / `group_lasso` are a **different** track. This Start button does not construct `inverse.GroupLassoInverter`. Registry id `legacy_exp` dispatches `exp_iteration`.

## Usage instructions

1. Default profile: Inverse tools → Standardized Hierarchical L1/L2 MAP Inversion (Lasso); optionally CreateDec if multiresolution is on; Start.
2. Asteroid / legacy: Inverse tools → EXP IAS RAMUS; Start runs `exp_ias_iteration_multires`.
3. For other GUIDE windows, call `exp_em_map_estimation`, `exp_ias_map_estimation`, or `exp_em_map_estimation_multires` from MATLAB.

## Important notes

- ApplyButton calls missing `zef_exp_init.m` — errors until that helper exists.
- Numeric ValueChangedFcn uses `num2double` as written.
- Group-lasso class ids are a separate track from this plugin Start.

## Developer guidance

Preserve default callback `zef_exp_app_launch`, asteroid callback `exp_ias_map_estimation_multires`, tags `EXP IAS` / `EXP EM` / `EXP sLORETA` (+ ` Multiresolution`), and registry id `legacy_exp` → `exp_iteration`.
