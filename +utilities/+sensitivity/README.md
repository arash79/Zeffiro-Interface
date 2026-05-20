# +utilities/+sensitivity

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

MATLAB sources:
- `aggregate_statistics.m` — **utilities.sensitivity.aggregate_statistics**: Aggregate statistics.
- `compute_metrics.m` — **utilities.sensitivity.compute_metrics**: Compute metrics.
- `method_capability.m` — **utilities.sensitivity.method_capability**: Method capability.
- `run_monte_carlo.m` — **utilities.sensitivity.run_monte_carlo**: Run monte carlo.
- `synthesize_measurements.m` — **utilities.sensitivity.synthesize_measurements**: Synthesize measurements.

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
- ``[stats] = utilities.sensitivity.aggregate_statistics(runs)` with project root and `src` on the path.`
- ``[metrics] = utilities.sensitivity.compute_metrics(z, source_positions, source_indices, diff_type, …)` with project root and `src` on the path.`
- ``[capability] = utilities.sensitivity.method_capability(method_id)` with project root and `src` on the path.`
- ``[results] = utilities.sensitivity.run_monte_carlo(zef, method_id, opts)` with project root and `src` on the path.`
- ``[F] = utilities.sensitivity.synthesize_measurements(L, source_indices, amp, noise_db, …)` with project root and `src` on the path.`

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
