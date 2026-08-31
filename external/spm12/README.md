# `external/spm12`

## Folder purpose

Optional **SPM12** neuroimaging toolbox (git submodule). Zeffiro does not use SPM as the FEM or inverse engine. The clone exists so scripts that `which` SPM file I/O or volume helpers can resolve after `zeffiro_setup`. Empty until cloned. Not first-party code.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | SPM12 sources |
| This README | Integration only |

`.gitmodules`: `https://github.com/spm/spm12.git`, branch `master`. No `startupscript`.

## Code functionality

`zeffiro_setup` `addpath('external/spm12')` after clone. No `run(spm …)` from `zef_start_config`. Core mesh / lead field / inverse paths (`src/mesh`, `src/forward`, `+inverse`) do not call `spm_*`.

## Workflow context

```
Optional clone → path for user or converter scripts
  → Zeffiro anatomy still typically comes from .zef / fs2zef / brainstorm2zef
```

FreeSurfer conversion: `utilities.fs2zef`. Brainstorm: `utilities.brainstorm2zef`.

## Usage instructions

```matlab
zeffiro_setup("submodules", "spm12");
```

## Important notes

- Placeholder directory is expected in a fresh clone.
- SPM license and batch GUI remain SPM’s.
- Putting SPM on the path can affect `which` for generic names (`spm.m`).

## Developer guidance

- Do not move Zeffiro volume I/O into this submodule.
- Pitfall: documenting SPM as required for the default multicompartment head demo — it is not.
