# +plugins/+ClassGMM

## Purpose of this folder

Namespaced algorithm support (e.g. ClassGMM, ClassKF) used by GUI plugins and class inverters.

## Contents

MATLAB sources:
- `ClassGMModeling.m` — **plugins.ClassGMM.ClassGMModeling**: Class GMModeling.
- `EstepWeight.m` — **plugins.ClassGMM.EstepWeight**: Estep Weight.
- `FitAdvGMM.m` — **plugins.ClassGMM.FitAdvGMM**: Fit Adv GMM.
- `WeightedCondDensity.m` — **plugins.ClassGMM.WeightedCondDensity**: Weighted Cond Density.
- `estep.m` — **plugins.ClassGMM.estep**: Estep.
- `AdvGMModeling4Rec.m` — **plugins.ClassGMM.function [S,NlogL,optimInfo]...**: Function [S,Nlog L,optim Info]....

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[MethodClassObj] = plugins.ClassGMM.ClassGMModeling(MethodClassObj, reconstruction, zef, args)` with project root and `src` on the path.`
- ``[weight] = plugins.ClassGMM.EstepWeight(log_lh, post, weight)` with project root and `src` on the path.`
- ``[obj] = plugins.ClassGMM.FitAdvGMM(positions, weight, k, varargin)` with project root and `src` on the path.`
- ``[[log_lh, mahalaD]] = plugins.ClassGMM.WeightedCondDensity(positions, mu, weight, Sigma, …)` with project root and `src` on the path.`
- ``[[ll, post, logpdf]] = plugins.ClassGMM.estep(log_lh, prob_th)` with project root and `src` on the path.`
- `Call `plugins.ClassGMM.function [S,NlogL,optimInfo]...` from MATLAB with the project root on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
