# `external/CVX`

## Folder purpose

Optional **CVX** convex-optimization toolbox (git submodule). Zeffiro does not ship CVX source in a fresh clone. After clone, `zeffiro_setup` `addpath`s this folder and runs `cvx_startup.m` via generated `src/app/zef_start_config.m`. First-party MATLAB here is none — do not treat files that appear after clone as Zeffiro-owned.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | CVX modeling language + solvers |
| `cvx_startup.m` | `.gitmodules` `startupscript`; run once per MATLAB session after `addpath` |
| This README | Zeffiro integration only — not a CVX user guide |

Submodule URL / branch: repository-root `.gitmodules` (`https://github.com/SeSodesa/CVX.git`, branch `15-gitmodules-to-use-https`).

## Code functionality

No Zeffiro functions live here. ES Workbench (`plugins/ZeffiroESWorkbench/m`) calls `zef_cvx_linprog`, `zef_cvx_quadprog`, and `zef_cvx_semidefprog` when the user picks CVX backends. Those wrappers issue `cvx_solver('sdpt3')` or `'sedumi'` and a `cvx_begin` / `cvx_end` model. SDPT3 and SeDuMi themselves are sibling submodules (`external/SDPT3`, `external/SeDuMi`); CVX must be able to find them on the path.

`zeffiro_setup` writes, for a successful clone:

```matlab
if isequal(zef.zeffiro_restart, 0), addpath('external/CVX'); end;
run ( 'external/CVX/cvx_startup.m' );
```

`addpath` is the **folder itself**, not `genpath(external)`.

## Workflow context

```
.gitmodule CVX + startupscript
  → zeffiro_setup("submodules","CVX")  or  "all"
  → zef_start_config.m
  → zeffiro_interface
  → plugins/ZeffiroESWorkbench (LP/QP/SDP via CVX)
  → optional EXP / tES study scripts that which() CVX
```

Parent map: [`../README.md`](../README.md). Solver GUI: [`../../plugins/ZeffiroESWorkbench/README.md`](../../plugins/ZeffiroESWorkbench/README.md).

## Usage instructions

```matlab
zeffiro_setup("submodules", "CVX");
% or
zeffiro_setup("submodules", "all");
```

Then start Zeffiro so `zef_start_config` runs. Verify:

```matlab
which cvx_begin   % should resolve under external/CVX after setup
```

Do not `addpath(genpath('external'))` by hand.

## Important notes

- Empty directory until clone is **expected**.
- Vendor license and docs stay with CVX; this file only describes Zeffiro wiring.
- ES Workbench may still offer MATLAB `linprog` / `quadprog` when CVX is absent.
- `cvx_startup` is skipped if the file is missing after a failed clone.

## Developer guidance

- Keep `startupscript = external/CVX/cvx_startup.m` in `.gitmodules` in sync with the vendor tree.
- New CVX-backed methods belong in first-party wrappers (`zef_cvx_*`), not as edits inside this submodule.
- Pitfall: committing cloned CVX objects into Zeffiro’s own git history; the submodule pointer is the source of truth.
