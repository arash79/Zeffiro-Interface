# EXP IAS (single-resolution)

## Folder purpose

Legacy GUIDE plugin folder for **exponential-prior IAS MAP estimation without RAMUS coarsening**. It is the single-resolution sibling of `../exp_ias_multires/` (IAS + lattices) and of the EM variants `../exp_em/` and `../exp_em_multires/`. Use this path when you need the older IAS-for-EP window and solver that read/write flat `zef.exp_ias_*` fields rather than the unified App Designer Lasso parameters under `zef.EXP.parameters`.

This folder is **not** the default Inverse-tools entry on `multicompartment_head` (that is `../common/zef_exp_app_launch` → `exp_iteration`). It is also **not** the asteroid INI callback (that is `exp_ias_map_estimation_multires`). Keep it for manual MATLAB launches, older menus, and parity fixes against the multires IAS solver.

## Main contents

| Path | Role |
|------|------|
| `fig/exp_ias_map_estimation.fig` | GUIDE UI resource |
| `fig/README.md` | Figure-folder documentation |
| `m/exp_ias_map_estimation.m` | Start script: `open` fig, title window, `zef_init_exp_ias` |
| `m/zef_init_exp_ias.m` | Bind widgets → `zef.h_exp_ias_*`, seed defaults |
| `m/zef_update_exp_ias.m` | Copy widget values into `zef.exp_ias_*` / shared inv time fields |
| `m/exp_ias_iteration.m` | IAS MAP kernel; writes reconstruction + information |
| `m/README.md` | MATLAB-side notes |
| `README.md` | This documentation |

Shared EXP helpers (not duplicated here): `../common/L1_optimization.m`, `LG_optimization.m`, `exp_iteration.m` (App Designer path), `zef_exp_app_launch.m`.

## Code functionality

Architectural pattern matches other EXP GUIDE tools:

1. **Open** — `exp_ias_map_estimation` loads `exp_ias_map_estimation.fig`, sets `zef.h_exp_ias_map_estimation`, window name **ZEFFIRO Interface: IAS MAP estimation for EP**.
2. **Init / update** — widgets for beta, theta0, SNR, MAP iterations, sampling frequency, band edges, time windows, frames, data segment, Apply / Start / Cancel.
3. **Start** — figure Callback runs `exp_ias_iteration([])` (argument unused; reads base-workspace `zef`).
4. **Solve** — `exp_ias_iteration` uses `zef_processLeadfields`, SNR `zef.inv_snr` → `10^(-inv_snr/20)`, hyperprior fields `exp_ias_q` / `exp_ias_hyper_type` / `exp_ias_beta` / `exp_ias_theta0`, and common L1 / weighted Tikhonov helpers. Tag: **`EXP IAS`**.
5. **Output** — `zef.reconstruction` and `zef.reconstruction_information` (no `inverse.*Inverter`).

Compared with multires IAS: there is no `exp_multires_dec` / level / sparsity stack and no `exp_make_multires_dec` prerequisite. Compared with EM: IAS uses the IAS hyperparameter update schedule (`exp_ias_*`), not `exp_em_*`.

## Workflow context

```
tools/plugins/EXP/
  common/          ← App Designer Lasso + shared optimizers
  exp_ias/         ← this folder (GUIDE, single-res IAS)
  exp_ias_multires/← asteroid GUIDE IAS + RAMUS
  exp_em/          ← GUIDE EM single-res
  exp_em_multires/ ← GUIDE EM + RAMUS (usually unmenu'd)
```

| Profile / entry | Typical path |
|-----------------|--------------|
| Default head | Inverse tools → Standardized Hierarchical L1/L2 MAP (Lasso) → `zef_exp_app_launch` |
| Asteroid / `_legacy` / `_nse` | Inverse tools → EXP IAS RAMUS → `exp_ias_map_estimation_multires` |
| Manual EXP IAS (no RAMUS) | Call `exp_ias_map_estimation` from MATLAB |

Class registry relatives (`ias`, `halpr`, `grouplasso`) are separate tracks; this Start button does not construct those classes. Registry id `legacy_exp` dispatches the broader App Designer `exp_iteration`, not this GUIDE script alone.

## Usage instructions

Prerequisites: lead field `zef.L` (or processable sources), `zef.measurements`, sensible `inv_snr` / time–band fields.

```matlab
exp_ias_map_estimation;   % opens GUIDE + init
% Edit widgets → Apply (zef_update_exp_ias) → Start (exp_ias_iteration)
```

Data-segment control enables when `zef.measurements` is a cell. Cancel / Apply / Start handles are stacked for focus order in the start script.

To compare against multires without leaving EXP:

```matlab
exp_ias_map_estimation_multires;   % sibling folder; needs lattices
```

## Important notes

- Base-workspace `zef` is required; the iteration function uses `evalin('base', ...)`.
- Prefer App Designer EXP launch on modern head profiles when the unified Lasso UI covers your case.
- Do not casually copy `exp_em_*` values into `exp_ias_*` fields — update schedules differ.
- GUIDE is deprecated in recent MATLAB; treat this UI as maintenance-only.
- Handle tags and `zef.h_exp_ias_*` names must stay stable for init/update `findobj` lookups.
- Not registered in default/asteroid INIs; absence from menus is expected.

## Developer guidance

- Share algorithmic bugfixes with `exp_ias_iteration_multires` and `EXP/common` rather than forking L1 / Tikhonov kernels.
- Avoid new GUIDE widgets here. If a profile needs IAS-only UI long term, port to App Designer and keep the same `exp_ias_*` (or migrate callers to `zef.EXP.parameters`).
- When changing SNR or frame semantics, keep parity with `exp_ias_iteration` header documentation and the App Designer `exp_iteration` path where tags overlap (`EXP IAS`).
- Document any new menu callback in this README and in `../README.md`.
- Do not add an `inverse.*Inverter` wrapper unless product direction explicitly unifies GUIDE and class APIs.
