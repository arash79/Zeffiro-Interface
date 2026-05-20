# +inverse/@GroupLassoInverter

## Purpose of this folder

Object-oriented inverse solvers (`inverse.*Inverter`) sharing `inverse.CommonInverseParameters`; orchestrated from `src/inverse` and `+utilities/+cluster`.

## Contents

MATLAB sources:
- `GroupLassoInverter.m` — **inverse.GroupLassoInverter.GroupLassoInverter**: Inverse solver class implementing GroupLasso reconstruction.
- `initialize.m` — **inverse.GroupLassoInverter.initialize**: Estimates priors, noise covariance, or regularization from multi-frame data.
- `invert.m` — **inverse.GroupLassoInverter.invert**: Runs one inverse reconstruction step for a single measurement frame.

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
- ``inverse.GroupLassoInverter.GroupLassoInverter(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.`
- ``[self] = inverse.GroupLassoInverter.initialize(self, L, f_data)` with project root and `src` on the path.`
- ``[[z_vec, self]] = inverse.GroupLassoInverter.invert(self, f_data, L, procFile, …)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.
Programmatic: `zef_inverse_run(zef, 'eloreta')` or `inverse.ELORETAInverter().computeInversionWithZI(zef)`.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
