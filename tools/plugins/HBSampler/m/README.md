# tools/plugins/HBSampler/m

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `hb_sampler.m` — **hb_sampler**: Hb sampler.
- `zef_update_mcmc.m` — **zef.inv_hyperprior = get(zef**: Zef.inv hyperprior = get(zef.
- `zef_gibbs_sampler_step.m` — **zef_gibbs_sampler_step**: Zef gibbs sampler step.
- `zef_mcmc.m` — **zef_mcmc**: Zef mcmc.
- `zef_mcmc_window.m` — **zef_mcmc_window**: Zef mcmc window.
- `zef_open_mcmc.m` — **zef_open_mcmc**: Opens the mcmc options dialog.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

Open the corresponding tool or plugin from the Zeffiro menu bar (profile-dependent). Widget callbacks in this folder update `zef` and call `zef_update`.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[zef] = hb_sampler(zef)` with project root and `src` on the path.`
- `Call `zef.inv_hyperprior = get(zef` from MATLAB with the project root on the path.`
- ``[[x, theta]] = zef_gibbs_sampler_step(L, y, x, theta, …)` with project root and `src` on the path.`
- ``[[z, reconstruction_information]] = zef_mcmc(zef)` with project root and `src` on the path.`
- ``[zef] = zef_mcmc_window(zef)` with project root and `src` on the path.`
- ``[zef] = zef_open_mcmc(zef)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
