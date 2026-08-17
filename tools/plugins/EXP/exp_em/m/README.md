# tools/plugins/EXP/exp_em/m

## Folder purpose

MATLAB sources for legacy GUIDE **EXP EM MAP** (single-resolution exponential-prior EM). Companion fig: `../fig/exp_em_map_estimation.fig`. Not on the default head Inverse-tools menu.

## Main contents

| File | Role |
|------|------|
| `exp_em_map_estimation.m` | Start: open fig + `zef_init_exp_em` |
| `zef_init_exp_em.m` | Defaults / bind |
| `zef_update_exp_em.m` | Widgets → `zef` |
| `exp_em_iteration.m` | Solver (Start → `exp_em_iteration([])`); tag `'EXP EM'` |

## Code functionality

`zef_processLeadfields` → EM / L1 updates (`L1_optimization` or closed form when `q==2`) → `zef_postProcessInverse` / normalize. GUIDE + base-workspace `zef`.

## Workflow context

See parent `exp_em/README.md`. Multires sibling: `exp_em_multires`. Unified GUI: `zef_exp_app_launch`.

## Usage instructions

```matlab
exp_em_map_estimation;
```

## Important notes

- Requires lead field + measurements.
- Do not mix `exp_em_*` fields with `exp_ias_*` casually.

## Developer guidance

- Keep solver changes aligned with any class/HALpR cousins when sharing L1 code.
- Pitfall: running Start with empty `zef.L`.
