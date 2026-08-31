# `external/SESAME`

## Folder purpose

Optional git submodule of **SESAME_core** (`hyperprior` branch). The **GUI and Zeffiro-facing inversion** live in `plugins/SESAME/`. This folder is the upstream sampler library if you clone it; the plugin also **ships** `plugins/SESAME/m/inverse_SESAME.m` and will `webread` that file from GitHub **master** only when the plugin copy is missing (`SESAME_core_check`). Empty until `zeffiro_setup` clones the submodule.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | SESAME_core sources (`hyperprior`) |
| This README | How this submodule relates to the plugin |

`.gitmodules`: `https://github.com/i-am-sorri/SESAME_core.git`, branch `hyperprior`. No `startupscript`.

## Code functionality

`zeffiro_setup` `addpath('external/SESAME')` after clone. The Inverse-tools SESAME window does **not** require this path: `SESAME_inversion` calls `inverse_SESAME` resolved from `plugins/SESAME/m` (on `genpath(plugins)`). Registry id `legacy_sesame` dispatches `SESAME_inversion`, not a class inverter.

## Workflow context

```
GUI: plugins/SESAME (asteroid profiles’ Inverse tools → SESAME)
Optional: this submodule for developing against SESAME_core hyperprior
Fallback download: SESAME_core_check → plugins/SESAME/m/inverse_SESAME.m (master)
```

Plugin manual: [`../../plugins/SESAME/README.md`](../../plugins/SESAME/README.md).

## Usage instructions

```matlab
zeffiro_setup("submodules", "SESAME");   % optional core tree
% GUI still:
SESAME_App_run   % or Inverse tools → SESAME on asteroid profiles
```

## Important notes

- Submodule branch is **hyperprior**; `SESAME_core_check` downloads **master** `inverse_SESAME.m` — they can differ.
- Default head profile does **not** register SESAME in `zeffiro_plugins.ini`.
- Vendor license stays with SESAME_core.

## Developer guidance

- Prefer fixing Zeffiro glue in `plugins/SESAME/m` (`SESAME_inversion`, waitbar, `s_ind_1` scatter). Do not edit cloned core here unless you intend a submodule bump.
- Pitfall: deleting `plugins/SESAME/m/inverse_SESAME.m` and expecting the submodule to be picked up automatically — MATLAB will use whichever `inverse_SESAME` is first on the path.
