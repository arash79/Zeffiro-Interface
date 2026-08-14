# EXP / common — unified App Designer tool

This folder is the **default-profile** Inverse tools entry **Standardized Hierarchical L1/L2 MAP Inversion (Lasso)** (`zef_exp_app_launch`). One window (`exp_app.mlapp`) covers IAS, EM, and sLORETA-style EXP, with optional RAMUS coarsening.

It is **not** `inverse.GroupLassoInverter`. Registry id `legacy_exp` still dispatches `exp_iteration` on the cluster path. Asteroid / `_legacy` profiles open the older GUIDE **EXP IAS RAMUS** window instead (`exp_ias_multires/`).

User-facing menu, Start callback, and SNR formula: [parent README](../README.md).

## Estimation type (`zef.EXP.parameters`)

`exp_iteration` `eval`s every field of `zef.EXP.parameters` after stripping the `exp_` prefix (`q`, `n_map_iterations`, `n_L1_iterations`, `hypermode`, `use_multires`, `estimation_type`, …).

| `estimation_type` | Tag written into `reconstruction_information` | Inner loop |
|-------------------|-----------------------------------------------|------------|
| 1 | EXP IAS | Sequential hyperprior MAP (`L1_optimization` when `q==1`, else weighted L2 `LG_optimization`) |
| 2 | EXP EM | `EM_Lasso` |
| 3 | EXP sLORETA | Same MAP family with an sLORETA-style post-scale |

`use_multires` appends ` Multiresolution` to the tag. **CreateDecButton** must have been run first so `EXP.parameters.exp_multires_*` exist; `exp_make_multires_dec` still **reads** top-level `zef.exp_multires_*`.

## Files

| File | Role |
|------|------|
| `zef_exp_app_launch` | Default INI callback → `zef_tool_start(..., 'zef_exp_app_start', …)` |
| `zef_exp_app_start` | Constructs `exp_app`. **Start** → `exp_iteration`. **Apply** → `zef_exp_init` (no such function in this tree). **CreateDec** writes `EXP.parameters.exp_multires_*` |
| `exp_iteration` | Unified IAS/EM/sLORETA MAP |
| `exp_make_multires_dec` | Random coarse lattices from base `zef.exp_multires_*` |
| `L1_optimization` / `LG_optimization` / `EM_Lasso` | Inner loops |

Numeric `exp_*` ValueChangedFcn in `zef_exp_app_start` uses `num2double` (not a MATLAB function). Documented as written; do not treat Apply as a working inverse.

GUIDE EM/IAS windows that are **not** on the default menu: sibling folders `exp_em/`, `exp_ias/`, `exp_em_multires/`, `exp_ias_multires/`.
