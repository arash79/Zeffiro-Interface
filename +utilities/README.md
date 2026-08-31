# `+utilities` — converters, cluster inverse, shared helpers

## Folder purpose

MATLAB package glue that is **not** the GUI runtime. The package name `utilities.*` is a stable public API ([ADR-004](../docs/adr/ADR-004-utilities-package-name.md)). Internally it hosts three kinds of modules:

| Kind | Packages |
|------|----------|
| Domain I/O (anatomy converters) | `fs2zef`, `sn2zef`, `brainstorm2zef`, `duneuro2zef` |
| Inverse runtime | `cluster`, `inverse` (frame loop), `sensitivity` |
| True utilities | `io`, `structs`, `dev` |

Call as `utilities.*` after `zeffiro_interface` (or `addpath` of the project root). Do not `addpath('+utilities')`.

Inverse formulas: [docs/methods.md](../docs/methods.md). Bundle fields: [`+cluster/SCHEMA.md`](+cluster/SCHEMA.md).

## Main contents

| Package | Role |
|---------|------|
| `utilities.cluster` | `dispatch_inverse`, batch submit/collect, registry |
| `utilities.inverse` | `run_frame_loop` for class inverters |
| `utilities.fs2zef` / `sn2zef` / `brainstorm2zef` / `duneuro2zef` | Anatomy converters (`run` / `import_*`) |
| `utilities.sensitivity` | Monte Carlo on inverse methods |
| `utilities.structs` | `copy_fields` (startup name-value args → `zef`) |
| `utilities.io` | `float_is_int`, `is_eof`, `read_gitmodules` |
| `utilities.dev` | Lint / indent for maintainers |

## Code functionality

`zef_inverse_run` extracts a bundle in `src/inverse`, then `utilities.cluster.dispatch_inverse(bundle)` either constructs `inverse.*Inverter` + `utilities.inverse.run_frame_loop` + post-process, or `feval`s a legacy function with `zef` in base. Register method ids in `+cluster/inverse_method_registry.m`. Batch/HPC: `submit_inverse_jobs`, `collect_inverse_results`, plus `configure_cluster_profile`, `run_inverse_job`, `with_zef_in_base` (Parallel Computing Toolbox; MATLAB cluster profiles, not Zeffiro INI profiles).

Converters write a Zeffiro-style folder (surfaces, `import_segmentation.zef`, often `electrodes.dat`). Entry points: `utilities.fs2zef.run`, `sn2zef.run`, `brainstorm2zef.run` / `zef_bst_plugin_start`, `duneuro2zef.run` / `import_duneuro_project`.

## Workflow context

Nothing here is a menu item except where a converter has its own plugin start (Brainstorm). Cluster inverse is the backend of `zef_inverse_run`. After conversion, start Zeffiro with `'import_to_new_project'` pointing at the `.zef`, then mesh as usual. Child converter READMEs cover flags, coordinates, and outputs—not Zeffiro startup.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));

[zef, run_result] = zef_inverse_run(zef, "eloreta", "execution", "local");

utilities.cluster.submit_inverse_jobs(...)
utilities.cluster.collect_inverse_results(...)

utilities.fs2zef.run(...)   % see +fs2zef/README.md for arguments
```

## Important notes

- SimNIBS `meshLoadGmsh4.m` is vendor code; do not re-attribute it. FreeSurfer environment helpers live under `+fs2zef/+environment`.
- Verified registry ids: see `+inverse/README.md`. Examples: `+utilities/+cluster/+examples/`.

## Developer guidance

Add new method ids only via the registry. Keep converter specifics in their child READMEs. Parent map for maintainers: this file; class solvers: `+inverse/README.md`; bundle extraction: `src/inverse/README.md`.
