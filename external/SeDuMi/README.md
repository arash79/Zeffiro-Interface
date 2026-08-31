# `external/SeDuMi`

## Folder purpose

Optional **SeDuMi** SDP/SOCP solver (git submodule). Zeffiro uses it as a **CVX backend** for ES Workbench linear / semidefinite models. Empty until cloned. Not first-party code.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | SeDuMi MATLAB sources |
| This README | Integration notes only |

`.gitmodules`: `https://github.com/sqlp/sedumi.git`, branch `master`. No `startupscript`.

## Code functionality

Successful `zeffiro_setup` adds `addpath('external/SeDuMi')`. `zef_cvx_linprog` (and siblings) set `cvx_solver('sedumi')` when the ES Workbench solver package is SeDuMi. Zeffiro does not wrap SeDuMi’s native `sedumi()` API for inverse imaging.

## Workflow context

Same as SDPT3: CVX modeling layer + SeDuMi numeric engine → `plugins/ZeffiroESWorkbench`. Parent: [`../README.md`](../README.md).

## Usage instructions

```matlab
zeffiro_setup("submodules", "SeDuMi");
```

Clone CVX in the same MATLAB setup if you intend to use ES Workbench CVX methods.

## Important notes

- Empty until clone.
- Vendor license remains SeDuMi’s.
- No startup script in `.gitmodules`.

## Developer guidance

- Keep first-party solver names (`'sedumi'` strings in `zef_cvx_*`) aligned with CVX’s solver id.
- Pitfall: `which sedumi` succeeding while `cvx_begin` is missing — clone CVX too.
