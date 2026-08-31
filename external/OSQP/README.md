# `external/OSQP`

## Folder purpose

Optional **OSQP MATLAB** quadratic-program solver (git submodule `osqp-matlab`). Reserved as an alternative QP engine. First-party inverse and ES Workbench code does **not** currently call `osqp` by name; the folder exists so `zeffiro_setup` can put OSQP on the path when a future or local wrapper `which`s it. Empty until cloned. Not Zeffiro-owned source.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | OSQP MATLAB interface |
| This README | Why the submodule exists |

`.gitmodules`: `https://github.com/osqp/osqp-matlab.git`, branch `master`. No `startupscript`.

## Code functionality

`zeffiro_setup` `addpath('external/OSQP')` after a successful clone. No `run()` of a vendor startup file. There is no `zef_osqp_*` wrapper in `plugins/` at the time this README was written — confirm with `grep` before assuming a GUI path.

## Workflow context

```
.gitmodule OSQP → zeffiro_setup → zef_start_config addpath
  → optional local/experimental QP code
```

tES optimization in production uses MATLAB Optimization Toolbox and/or CVX (SDPT3/SeDuMi), plus optional Gurobi/MOSEK wrappers in ES Workbench — not this tree.

## Usage instructions

```matlab
zeffiro_setup("submodules", "OSQP");
```

## Important notes

- Empty placeholder is expected.
- Do not rewrite OSQP’s own documentation here.
- Cloning OSQP does not change Inverse-tools menus.

## Developer guidance

- If you add an OSQP backend, wrap it in first-party `zef_*` code and mention the caller in this README and in `plugins/ZeffiroESWorkbench/m/README.md`.
- Pitfall: assuming ES Workbench “QP” dropdown equals this submodule.
