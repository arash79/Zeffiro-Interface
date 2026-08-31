# EXP IAS multiresolution (`exp_ias_multires`)

## Folder purpose

Legacy **GUIDE** implementation of **EXP IAS MAP with RAMUS-style multiresolution coarsening**. Used by asteroid / `_legacy` / `_nse` profile menus (`exp_ias_map_estimation_multires`). Not an `inverse.*Inverter` class.

## Main contents

| Path | Role |
|------|------|
| `fig/exp_ias_map_estimation_multires.fig` | GUIDE parameter window |
| `m/exp_ias_map_estimation_multires.m` | Opens fig + init |
| `m/zef_init_exp_ias_multires.m` | Default `zef.exp_*` / widget sync |
| `m/zef_update_exp_ias_multires.m` | Widget → `zef` |
| `m/exp_ias_iteration_multires.m` | Solver: lead fields → multires IAS → `zef.reconstruction` |

Sibling: `plugins/EXP/common/` (shared App Designer solver, lattices, L1/EM helpers).

## Code functionality

`exp_ias_iteration_multires` reads base-workspace fields (`zef.exp_multires_*`, `exp_ias_multires_q`, hyperprior knobs, `inv_snr`), calls `zef_processLeadfields`, runs nested multires / decomposition MAP updates (L1 iterations via EXP common helpers), tags `reconstruction_information` as `'EXP IAS Multiresolution'`.

**Inputs:** populated `zef` with `L` path ready (via processLeadfields), multires lattices (`exp_multires_dec` / `_ind`). **Outputs:** reconstruction cell/array + information struct.

## Workflow context

```
INI callback exp_ias_map_estimation_multires → GUIDE fig → Start → exp_ias_iteration_multires
```

Default `multicompartment_head` profile prefers App Designer Lasso (`zef_exp_app_launch`) instead of this GUIDE path. Class relatives: `GroupLassoInverter` / `HALpRInverter` use `LG_optimization` / `L1_optimization` but are not this GUI.

## Usage instructions

```matlab
% With asteroid_gravity / multicompartment_head_legacy / _nse profile:
% Menu → Inverse tools → EXP IAS RAMUS
exp_ias_map_estimation_multires;
```

## Important notes

- Heavy use of `evalin('base','zef…')` — `zef` must live in base.
- GPU check uses `gpuDeviceCount`, not always `zef.gpu_count`.
- Requires multiresolution lattices on `zef` before Start (build via EXP multires helpers / `exp_make_multires_dec`).

## Developer guidance

- Prefer migrating users to `zef_inverse_run` + class inverters; keep this folder for profile compatibility.
- Do not fork L1 math — change `EXP/common` optimizers once.
- When editing GUIDE tags, update init/update findobj lists together.
