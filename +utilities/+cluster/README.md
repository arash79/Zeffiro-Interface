# +utilities/+cluster

## Folder purpose

**Distributed and local inverse execution**: serialize a minimal `bundle` from `zef`, dispatch to `+inverse` classes or legacy plugin functions, run batch/cluster jobs, and collect results. Bridges `zef_inverse_run` in `src/inverse` with Parallel Computing Toolbox workflows.

## Main contents

| File | Role |
|------|------|
| `dispatch_inverse.m` | Core router: class path → `utilities.inverse.run_frame_loop`; legacy → `with_zef_in_base` + plugin func |
| `inverse_method_registry.m` | Maps `method_id` → class name, legacy function, `execution_kind` |
| `run_inverse_job.m` | Worker: load bundle `.mat`, run dispatch, save `result.mat` |
| `submit_inverse_jobs.m` / `collect_inverse_results.m` | Batch submit and gather |
| `configure_cluster_profile.m` | Set CSC cluster `AdditionalProperties` |
| `create_batch_job.m` | Job array helper |
| `with_zef_in_base.m` | Temporarily assign `legacy_zef` to base for legacy solvers |
| `example_workflow.m` / `run_cluster_job_example.m` | Developer demos |
| `+examples/` | `eloreta_workflow.m`, `kalman_workflow.m`, `parameter_sweep.m` |
| `SCHEMA.md` | Bundle struct field documentation |

## Code functionality

**Bundle** (from `zef_inverse_extract_bundle`): `L`, `F`, `procFile`, `source_positions`, `source_direction_mode`, `common_inverse_parameters`, optional `legacy_zef`, GPU flags.

**Class dispatch:** instantiate `inverse.*Inverter`, `withPropertiesFromZef`, `run_frame_loop`.

**Legacy dispatch:** requires `bundle.legacy_zef` embedded full struct; calls e.g. `zef_CSM_iteration` in base workspace.

**Errors:** `utilities.cluster:UnknownInverseMethod`, `MissingLegacyZef` (see `InverseFailureModesTest`).

## Workflow context

```
zef_inverse_run → zef_inverse_extract_bundle → dispatch_inverse
  → local: immediate result
  → cluster: submit_inverse_jobs → run_inverse_job on workers
```

`+tests` extensively covers dispatch; `+examples/+studies` may use sensitivity batching.

## Usage instructions

```matlab
[zef, result] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');

% Cluster (after configure_cluster_profile)
jobs = utilities.cluster.submit_inverse_jobs(jobSpecs, profile);
utilities.cluster.collect_inverse_results(jobs, outDir);

% Examples
run('+utilities/+cluster/+examples/eloreta_workflow.m');
```

## Important notes

- Legacy cluster jobs need full `zef` in bundle — large files.
- Registry must list both `method_id` and `legacy_*` for parity testing.
- `parameter_sweep.m` assumes CSC `parcluster` — not portable to all HPC sites.
- Class methods share `run_frame_loop` — do not duplicate frame logic in cluster code.

## Developer guidance

- Register every new `+inverse` class in `inverse_method_registry.m` with `execution_kind = "class"`.
- Keep bundle schema backward compatible or version the struct.
- Test with `runtests('tests.InverseDispatchTest')` after registry edits.
- Document new method IDs in `+inverse/README.md` and relevant plugin README.
