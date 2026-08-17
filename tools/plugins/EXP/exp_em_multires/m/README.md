# tools/plugins/EXP/exp_em_multires/m

## Folder purpose

Legacy GUIDE **EXP EM MAP + multiresolution** sources. Companion fig under `../fig`. Uses shared EXP multires lattices (`exp_multires_*` / `EXP/common`).

## Main contents

| File | Role |
|------|------|
| `exp_em_map_estimation_multires.m` | Start: open fig + init |
| `zef_init_exp_em_multires.m` | Defaults / bind |
| `zef_update_exp_em_multires.m` | Widgets → `zef` |
| `exp_em_iteration_multires.m` | Multires EM solver |

## Code functionality

Same EM family as `exp_em`, but iterates across resolution levels using `zef.exp_multires_dec` (build via EXP common helpers first). Tag / `reconstruction_information` identify the multires EM run.

## Workflow context

Profile-dependent Inverse-tools entry. Sibling: `exp_ias_multires`. Default head profile prefers App Designer EXP/Lasso.

## Usage instructions

```matlab
exp_em_map_estimation_multires;  % build lattices, then Start
```

## Important notes

- Without lattices, results are incomplete/fail.
- Field prefixes differ from IAS multires — do not copy parameters blindly.

## Developer guidance

- Keep lattice builders in `EXP/common`; keep EM updates here.
- Pitfall: mixing EM multires parameters with IAS multires INI defaults.
