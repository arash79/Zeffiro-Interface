# tools/plugins/EXP/exp_ias_multires/m

## Folder purpose

MATLAB sources for the legacy GUIDE **EXP IAS MAP + RAMUS multiresolution** inverse tool. The sibling `../fig` folder holds `exp_ias_map_estimation_multires.fig`. Registered on asteroid and legacy/NSE head profiles as Inverse-tools entry **EXP IAS RAMUS**.

## Main contents

| File | Role |
|------|------|
| `exp_ias_map_estimation_multires.m` | Start: open fig + `zef_init_exp_ias_multires` |
| `zef_init_exp_ias_multires.m` | Defaults `exp_multires_*` + `exp_ias_multires_*`; empty lattices until built |
| `zef_update_exp_ias_multires.m` | Widget values → `zef` |
| `exp_ias_iteration_multires.m` | Multiresolution IAS solver; tag `'EXP IAS Multiresolution'` |

## Code functionality

**Start path:** open GUIDE UI → init defaults → user builds multires lattices (via EXP common helpers) → update → Start runs iteration.

**Solver (`exp_ias_iteration_multires`):**

1. Uses `zef.L`, measurements, SNR/time/band, and **`zef.exp_multires_dec`** (from `EXP/common/exp_make_multires_dec`).
2. Runs IAS-style updates across resolution levels (`n_levels`, per-level `n_iter` padded if short).
3. GPU branch checks `gpuDeviceCount` (not `zef.gpu_count`).
4. Writes reconstruction + `reconstruction_information`.

## Workflow context

| Profile INI | Menu registration |
|-------------|-------------------|
| `profile/asteroid_gravity/zeffiro_plugins.ini` | EXP IAS RAMUS → this start script |
| `profile/asteroid_radar/zeffiro_plugins.ini` | same |
| `profile/multicompartment_head_legacy` / `_nse` | same |
| `profile/multicompartment_head` (default) | Uses App Designer Lasso/EXP path instead |

Siblings: `exp_ias` (single-res), `exp_em_multires` (EM multires), `EXP/common` (lattice builders).

## Usage instructions

From a matching profile’s Inverse-tools menu: **EXP IAS RAMUS**.

Programmatic:

```matlab
exp_ias_map_estimation_multires;  % then build lattices in UI, Start
```

Build lattices first (plugin common helper / UI button — see `tools/plugins/EXP/common`).

## Important notes

- Starting without `exp_multires_dec` lattices fails or yields incomplete results.
- Field prefixes differ from EM multires — do not copy parameters blindly between plugins.
- GUIDE + `evalin('base')` session model.

## Developer guidance

- Keep lattice construction in `EXP/common`; keep IAS updates here.
- When changing GPU detection, align with modern `zef.use_gpu` / `zef.gpu_count` patterns used elsewhere.
- Pitfall: comparing results to `inverse.IASInverter` without matching priors, SNR mapping, and multires schedule.
