# inverse.GroupLassoInverter

## Folder purpose

Class package for **group-LASSO MAP** (ℓ₂ over 3-DOF source blocks) via `LG_optimization` from the EXP plugin common library. Registry ids: `grouplasso`, `group_lasso`. Not wired to a dedicated Inverse-tools menu button as a class; related GUI path is EXP / Lasso plugins.

## Main contents

| File | Role |
|------|------|
| `GroupLassoInverter.m` | `estimation_type` (IAS/EM/Standardized), hyperpriors, L1 iteration counts, multires flags |
| `initialize.m` | `noise_cov` + dynamic `SNR_variable` |
| `invert.m` | MAP loop calling `LG_optimization`; updates `gamma = β/(θ₀ + ‖z‖₂)` |

Constructor currently forces `use_multiresolution = false`. A `make_multires_dec` helper may reference RAMUS property names incorrectly if enabled.

## Code functionality

**Dependencies:** `tools/plugins/EXP/common/LG_optimization.m` must be on the MATLAB path (plugins path is added by `zeffiro_interface`).

**Inputs:** Unlike single-column inverters, this path often passes **matrix** `f_data` (all frames) into optimization helpers — match the signature expected by `invert.m`.

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

- Multiresolution support is **disabled / incomplete** in the constructor — do not rely on `use_multiresolution=true` without fixing `make_multires_dec`.
- Heavy dependency on EXP common optimizers — keep plugins on path even for “class-only” scripts.
- No dedicated `ClassVsLegacyTest` entry may exist yet for this id.

## Developer guidance

- Fix or remove broken multires hooks before advertising them in docs or menus.
- When migrating EXP GUI to class API, map estimation_type strings carefully.
- Prefer extending `LG_optimization` over copying IRLS loops into `invert.m`.
