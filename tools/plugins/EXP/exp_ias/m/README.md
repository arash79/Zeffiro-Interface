# tools/plugins/EXP/exp_ias/m

## Folder purpose

MATLAB sources for legacy GUIDE **EXP IAS MAP** (single-resolution). Start opens `../fig/exp_ias_map_estimation.fig`. Not on the default `multicompartment_head` Inverse menu (unified App Designer EXP/Lasso path). Asteroid / legacy profiles more often use **IAS multires** (`exp_ias_multires`).

## Main contents

| File | Role |
|------|------|
| `exp_ias_map_estimation.m` | Start: open fig + `zef_init_exp_ias` |
| `zef_init_exp_ias.m` | Defaults / widget bind |
| `zef_update_exp_ias.m` | Widgets → `zef` |
| `exp_ias_iteration.m` | Solver (Start → `exp_ias_iteration([])`); tag `'EXP IAS'` |

## Code functionality

IAS-style exponential-prior MAP on `zef.L` + measurements after `zef_processLeadfields` / post-process helpers. Uses `evalin('base','zef…')` (GUIDE-era).

## Workflow context

Siblings: `exp_em` (EM), `exp_ias_multires` / `exp_em_multires`, App Designer `zef_exp_app_launch`. Class cousins: `inverse.IASInverter`.

## Usage instructions

```matlab
exp_ias_map_estimation;  % then Start in the GUIDE UI
```

## Important notes

- Needs `zef.L` and measurements before Start.
- Distinct field namespace from EM / multires plugins.

## Developer guidance

- Prefer porting fixes to App Designer / `+inverse` rather than growing GUIDE callbacks.
- Pitfall: comparing to multires IAS without matching lattices and priors.
