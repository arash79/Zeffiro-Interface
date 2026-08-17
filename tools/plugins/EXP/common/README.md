# tools/plugins/EXP/common

## Folder purpose

Shared **App Designer** Exponential Prior (EXP) tool used by the default-profile Inverse-tools entry **Standardized Hierarchical L1/L2 MAP Inversion (Lasso)** (`zef_exp_app_launch`). One window covers IAS, EM, and sLORETA-style EXP, with optional RAMUS coarsening.

## Main contents

| File | Role |
|------|------|
| `zef_exp_app_launch.m` | Default INI callback → `zef_tool_start(..., 'zef_exp_app_start', …)` |
| `zef_exp_app_start.m` | Constructs `exp_app`; **Start** → `exp_iteration`; **CreateDec** writes `EXP.parameters.exp_multires_*` |
| `exp_app.mlapp` | App Designer UI |
| `exp_iteration.m` | Unified IAS/EM/sLORETA MAP |
| `exp_make_multires_dec.m` | Random coarse lattices from base `zef.exp_multires_*` |
| `L1_optimization.m` / `LG_optimization.m` / `EM_Lasso.m` | Inner loops |

## Code functionality

`exp_iteration` `eval`s every field of `zef.EXP.parameters` after stripping the `exp_` prefix (`q`, `n_map_iterations`, `n_L1_iterations`, `hypermode`, `use_multires`, `estimation_type`, …).

| `estimation_type` | Tag in `reconstruction_information` | Inner loop |
|-------------------|--------------------------------------|------------|
| 1 | EXP IAS | Sequential hyperprior MAP (`L1_optimization` when `q==1`, else weighted L2 `LG_optimization`) |
| 2 | EXP EM | `EM_Lasso` |
| 3 | EXP sLORETA | Same MAP family with an sLORETA-style post-scale |

`use_multires` appends ` Multiresolution` to the tag. **CreateDecButton** must run first so `EXP.parameters.exp_multires_*` exist; `exp_make_multires_dec` still **reads** top-level `zef.exp_multires_*`.

## Workflow context

Default head-profile EXP entry. Asteroid / `_legacy` profiles open the older GUIDE **EXP IAS RAMUS** window instead (`exp_ias_multires/`). Not `inverse.GroupLassoInverter`. Registry id `legacy_exp` still dispatches `exp_iteration` on the cluster path. Sibling GUIDE folders: `exp_em/`, `exp_ias/`, `exp_em_multires/`, `exp_ias_multires/`.

## Usage instructions

1. Inverse tools → Standardized Hierarchical L1/L2 MAP Inversion (Lasso), or `zef_exp_app_launch`.
2. Set estimation type / SNR / iterations; for multires, **CreateDec** then enable multires.
3. **Start** runs `exp_iteration` into `zef.reconstruction` / `reconstruction_information`.

User-facing menu and SNR formula: [`../README.md`](../README.md).

## Important notes

- Numeric `exp_*` ValueChangedFcn in `zef_exp_app_start` uses `num2double` (not a MATLAB function).
- **Apply** → `zef_exp_init` — no such function in this tree; do not treat Apply as a working inverse.

## Developer guidance

Keep estimation_type tags and inner-loop names aligned with GUIDE solvers in sibling folders. When changing multires field names, update both `EXP.parameters.exp_multires_*` writers and `exp_make_multires_dec` readers of top-level `zef.exp_multires_*`.
