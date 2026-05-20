# +utilities

## Purpose of this folder

Reusable **package utilities** used by cluster jobs, converters, examples, and `src/inverse` orchestration. Not loaded by adding `+utilities` directly—call with qualified names (`utilities.cluster.dispatch_inverse`, etc.) after `addpath(projectRoot)`.

## Contents

| Area | Path | Role |
|------|------|------|
| Cluster | `+cluster/` | `dispatch_inverse`, `submit_inverse_jobs`, `run_inverse_job`, profiles, examples |
| Inverse loop | `+inverse/run_frame_loop.m` | Shared per-frame loop for `+inverse` classes |
| Brainstorm | `+brainstorm2zef/` | Brainstorm → Zeffiro project conversion |
| FreeSurfer | `+fs2zef/` | FS surfaces/segmentation import |
| Duneuro | `+duneuro2zef/` | Duneuro FEM/EEG/MEG import |
| SN / LUT | `+sn2zef/` | Statistical parametric mapping helpers |
| Sensitivity | `+sensitivity/` | Monte Carlo sensitivity driver |
| Plotting | `+plotting/` | Figure helpers for studies |
| I/O | `+io/` | Small shared I/O (e.g. `float_is_int`) |
| Structs | `+structs/` | `copy_fields` and struct helpers |
| Dev | `+dev/` | `lint_mfiles`, `indent_mfiles`, `get_mfile_paths` |

## How this folder fits into the overall workflow

- **Inverse:** `zef_inverse_run` → `utilities.cluster.dispatch_inverse` → `utilities.inverse.run_frame_loop`.
- **Batch:** `submit_inverse_jobs` / `collect_inverse_results` for HPC-style runs.
- **Import pipelines:** external tools (BST, FS, Duneuro) build Zeffiro-compatible projects without GUI.
- **Studies:** `+examples/+studies` and ES workbench call cluster and sensitivity utilities.

## GUI usage

Generally **none** directly—utilities are programmatic. Cluster configuration may be triggered from developer workflows or examples, not main Zeffiro menus.

## Programmatic usage

```matlab
addpath(fileparts(which('zeffiro_interface')));

% Inverse dispatch
[zef, result] = utilities.cluster.dispatch_inverse(bundle, "eloreta", opts);

% Frame loop (advanced)
z_inverse = utilities.inverse.run_frame_loop(inv, L, f_cell, procFile, ...);

% Cluster job
utilities.cluster.submit_inverse_jobs(jobSpecs, profile);

% Converters (see each subfolder README)
utilities.brainstorm2zef.run(...)
```

## Examples

- `+utilities/+cluster/+examples/eloreta_workflow.m`
- `+utilities/+cluster/+examples/kalman_workflow.m`
- `+utilities/+cluster/+examples/parameter_sweep.m`
- `+utilities/+fs2zef/test_unified_pipeline.m`

## Dependencies and assumptions

- Project root on path for `utilities.*` namespace.
- Cluster functions need Parallel Computing Toolbox / cluster profiles where applicable.
- Converters assume external tool outputs on disk (paths in each converter README).
- `run_frame_loop` expects `+inverse` classes on path.

## Notes for developers

- Register new inverse methods in `utilities.cluster.inverse_method_registry.m`.
- Keep bundle layout in sync with `zef_inverse_extract_bundle.m` in `src/inverse`.
- Add converter subpackages under `+utilities/+name2zef` pattern with a top-level `run.m` entry.
