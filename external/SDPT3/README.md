# `external/SDPT3`

## Folder purpose

Optional **SDPT3** semidefinite / second-order cone solver (git submodule). Used as a **CVX backend**, not as a Zeffiro-native inverse method. Empty until `zeffiro_setup` clones it. No first-party MATLAB in this folder.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | SDPT3 MATLAB sources |
| This README | How Zeffiro expects the submodule to exist |

`.gitmodules`: `https://github.com/sqlp/sdpt3.git`, branch `master`. **No** `startupscript` (unlike CVX / FieldTrip).

## Code functionality

`zeffiro_setup` only `addpath('external/SDPT3')` when clone succeeds. ES Workbench `zef_cvx_linprog` / related wrappers call `cvx_solver('sdpt3')` when `ES_opt_solver` is the SDPT3 list entry. Direct `sqlp` calls from Zeffiro plugins are not the supported path.

## Workflow context

```
zeffiro_setup → addpath external/SDPT3
  → CVX (external/CVX) selects sdpt3
  → plugins/ZeffiroESWorkbench tES LP/SDP
```

Install CVX as well; SDPT3 alone does not provide `cvx_begin`.

## Usage instructions

```matlab
zeffiro_setup("submodules", "SDPT3");
% typical with CVX:
zeffiro_setup("submodules", ["CVX"; "SDPT3"; "SeDuMi"]);
```

## Important notes

- Placeholder directory in a fresh clone is expected.
- Keep vendor license with the cloned tree.
- No Zeffiro `startupscript` — nothing is `run()` from `zef_start_config` for this folder.

## Developer guidance

- Do not vendor-patch SDPT3 inside this repo; bump the submodule commit if a fix is required.
- Pitfall: selecting SDPT3 in ES Workbench without having cloned both CVX and SDPT3.
