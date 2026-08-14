# EXP

Exponential / L1–L2 hierarchical MAP (IAS or EM, optional RAMUS coarsening). The default-profile tool is one App Designer window (`zef_exp_app_launch`) that calls shared `exp_iteration`. Asteroid profiles instead open the older GUIDE **EXP IAS RAMUS** window.

Related class ids `grouplasso` / `group_lasso` are a **different** track. This Start button does not construct `inverse.GroupLassoInverter`. Registry id `legacy_exp` dispatches `exp_iteration`.

## Menu

| Profile | Path | Callback |
|---------|------|----------|
| `multicompartment_head` | Inverse tools → **Standardized Hierarchical L1/L2 MAP Inversion (Lasso)** | `zef_exp_app_launch` |
| `_legacy`, `_nse` | Inverse tools → **EXP IAS RAMUS** | `exp_ias_map_estimation_multires` |
| asteroid_radar / asteroid_gravity | Inverse tools → **EXP IAS RAMUS** | `exp_ias_map_estimation_multires` |

`exp_em_map_estimation`, `exp_ias_map_estimation`, and `exp_em_map_estimation_multires` are **not** in any default/asteroid INI; call them from MATLAB if you need those GUIDE windows.

## Unified app (default INI)

Window title: `ZEFFIRO Interface: Exponential Prior Tool`.

**StartButton** `ButtonPushedFcn`:

```matlab
[zef.reconstruction,zef.reconstruction_information] = exp_iteration(zef);
```

**CreateDecButton** builds `zef.EXP.parameters.exp_multires_*` via `exp_make_multires_dec` (needed if multiresolution is on). **ApplyButton** copies widgets via `zef_exp_init` (there is **no** `zef_exp_init.m` in this tree — the button errors until that helper exists). Numeric `exp_*` ValueChangedFcn uses `num2double` as written.

Estimation type in `zef.EXP.parameters` selects the tag: `EXP IAS`, `EXP EM`, or `EXP sLORETA`, plus ` Multiresolution` when `exp_use_multires` is true.

## GUIDE EXP IAS RAMUS (asteroid / legacy INI)

Window title set in code: `ZEFFIRO Interface: IAS MAP multiresolution (RAMUS) for EP`. GUIDE resource name: `IAS MAP estimation multiresolution`.

**Start** Callback in `exp_ias_map_estimation_multires.fig`:

```matlab
zef_update_exp_ias_multires; [zef.reconstruction,zef.reconstruction_information] = exp_ias_iteration_multires([]);
```

Other GUIDE Start strings (not on the default menu):

- EXP IAS: `exp_ias_iteration([])`
- EXP EM: `exp_em_iteration([])`
- EXP EM RAMUS: `exp_em_iteration_multires([])`

## Needs (unified `exp_iteration`)

- `zef.L`, interpolation, `zef.measurements`
- SNR: `zef.inv_snr` → `S_mat = (10^(-inv_snr/20))^2 * max(f_data.^2) * I`
- Frames: `zef.number_of_frames`, `inv_time_*`, band edges
- EXP parameters on `zef.EXP.parameters` (`exp_q`, map / L1 iteration counts, hypermode, optional multires fields)

## Writes

- `zef.reconstruction` and `zef.reconstruction_information`

## Files

- Default start: `common/zef_exp_app_launch.m` → `zef_exp_app_start`
- Default solver: `common/exp_iteration.m`
- Layout: `common/exp_app.mlapp`
- Asteroid start: `exp_ias_multires/m/exp_ias_map_estimation_multires.m`
- Asteroid solver: `exp_ias_multires/m/exp_ias_iteration_multires.m`
