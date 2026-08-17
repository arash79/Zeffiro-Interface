# EXP EM multiresolution

## Folder purpose

Legacy GUIDE plugin folder for **exponential-prior EM MAP estimation on RAMUS multiresolution lattices**. It mirrors the structure of `../exp_ias_multires/` (IAS + RAMUS) but runs the EM iteration kernel (`exp_em_iteration_multires`) and uses the `exp_em_multires_*` field namespace. Asteroid / legacy menus typically expose **IAS** multires, not this EM multires entry — treat the folder as a maintained alternate solver UI, not the default Inverse-tools path.

Use it when you specifically need EM hyperparameter updates with coarsened source spaces (`zef.exp_multires_*` from `exp_make_multires_dec`), without switching to the App Designer Lasso tool.

## Main contents

| Path | Role |
|------|------|
| `fig/exp_em_map_estimation_multires.fig` | GUIDE UI resource |
| `fig/README.md` | Figure-folder documentation |
| `m/exp_em_map_estimation_multires.m` | Start script: open fig, title, `zef_init_exp_em_multires` |
| `m/zef_init_exp_em_multires.m` | Bind multires + EM widgets |
| `m/zef_update_exp_em_multires.m` | Widget → `zef.exp_em_multires_*` / shared inv fields |
| `m/exp_em_iteration_multires.m` | EM MAP on lattices; tag `EXP EM Multiresolution` |
| `m/README.md` | MATLAB-side notes |
| `README.md` | This documentation |

Shared dependencies: `../common/exp_make_multires_dec.m`, `L1_optimization.m`, lead-field processing via `zef_processLeadfields`. Sibling single-res EM: `../exp_em/`. Sibling IAS multires (menu'd on asteroid): `../exp_ias_multires/`.

## Code functionality

1. **Open** — `exp_em_map_estimation_multires` loads `exp_em_map_estimation_multires.fig`, sets `zef.h_exp_em_map_estimation_multires`, window name **ZEFFIRO Interface: EM MAP multiresolution (RAMUS) for EP**.
2. **Init** — levels, sparsity, `q`, beta, theta0, SNR, MAP / L1 iteration counts, time–band–frame controls; data-segment enable when measurements are a cell.
3. **Lattices** — solver reads `zef.exp_multires_dec`, `exp_multires_ind`, `exp_multires_n_levels`, `exp_multires_n_decompositions`, `exp_multires_n_iter`, sparsity. Build them with `exp_make_multires_dec` (or an equivalent Create path) **before** Start.
4. **Start** — figure Callback runs `exp_em_iteration_multires([])`.
5. **Solve** — EM schedule on coarsened spaces; SNR from `zef.inv_snr`; writes `zef.reconstruction` and `reconstruction_information` with tag **`EXP EM Multiresolution`**. No `inverse.*Inverter`.

EM vs IAS multires: same lattice fields (`exp_multires_*`), different parameter prefixes (`exp_em_multires_*` vs `exp_ias_multires_*`) and different iteration files. Mixing init fields across EM/IAS will silently use the wrong hyperprior schedule.

## Workflow context

```
Inverse tools (asteroid) → EXP IAS RAMUS → exp_ias_map_estimation_multires   ← typical menu
MATLAB only              → exp_em_map_estimation_multires                    ← this folder
Default head             → zef_exp_app_launch (App Designer, optional multires via EXP.parameters)
```

Under `tools/plugins/EXP/`, this folder sits beside IAS variants and `common/` optimizers. It is **not** wired into `+inverse` classes. Profile INIs for default/asteroid profiles generally **omit** this entry; absence from the menu is expected, not a bug.

Related single-resolution EM GUIDE: `exp_em_map_estimation` (no lattices). Related sampling/MAP RAMUS outside EXP: `tools/plugins/RAMUSSampler`, `RAMUSInversion` (different field namespaces `inv_multires_*`).

## Usage instructions

```matlab
% 1) Lead field + measurements on base zef
% 2) Build EXP multiresolution decompositions
exp_make_multires_dec;   % fills zef.exp_multires_*

% 3) Open EM multires GUIDE
exp_em_map_estimation_multires;

% 4) Adjust exp_em_multires_* widgets → Apply → Start
%    Start → exp_em_iteration_multires([])
```

If Start fails immediately with missing lattice fields, rebuild decompositions; empty `exp_multires_dec` fails similarly to other RAMUS-style solvers that assume precomputed indices.

To compare IAS multires (often the menu path):

```matlab
exp_ias_map_estimation_multires;
```

## Important notes

- Confirm lattice fields exist before Start; do not assume asteroid menus created them for EM.
- Field namespaces: solver-specific `exp_em_multires_*` + shared `exp_multires_*`. Do not overwrite IAS prefixes.
- Base-workspace `zef` required (`evalin` inside iteration).
- Not the default Lasso app; not Group-Lasso class ids.
- GUIDE maintenance only — no new GUIDE features.
- Profile documentation that says “EXP IAS RAMUS” refers to the IAS sibling, not this EM folder.

## Developer guidance

- Prefer documenting **IAS multires** as the supported GUIDE multires path for asteroid profiles; keep EM multires for explicit EM callers and regression parity.
- Share `exp_make_multires_dec` and common L1 helpers; do not duplicate lattice builders inside this folder.
- Align SNR / frame / waitbar behaviour with `exp_em_iteration` (single-res) and `exp_ias_iteration_multires` where contracts overlap.
- If porting to App Designer, map widgets onto `zef.EXP.parameters` and reuse `exp_iteration` / multires flags rather than growing a second EM-only app.
- Update `fig/README.md` and `../README.md` when Start Callback strings or tags change.
