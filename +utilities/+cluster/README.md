# `utilities.cluster` — class/legacy inverse dispatch and batch jobs

Router between `zef_inverse_run` / `zef_inverse_extract_bundle` and `+inverse` inverter classes (or legacy `zef_*` plugin functions). Local path is what the GUI inverse run uses; cluster path serializes bundles and `batch`es `run_inverse_job`.

See parent `+utilities/README.md` for the call graph. Bundle field list: `SCHEMA.md`.

## Local dispatch

```matlab
bundle = zef_inverse_extract_bundle(zef, "eloreta");  % src/inverse
result = utilities.cluster.dispatch_inverse(bundle);
% result.method_id, .z_inverse, .reconstruction, .reconstruction_information
```

`dispatch_inverse` requires `bundle.method_info` from `inverse_method_registry`. Class path: construct `inverse.*Inverter`, `utilities.inverse.run_frame_loop`, optional smoother/terminate, `zef_postProcessInverseClassObj`. Legacy path: `with_zef_in_base` + `feval(legacy_function)`.

Errors: `utilities.cluster:UnknownInverseMethod`, `MissingLegacyZef`, `UnsupportedExecutionKind`.

## Registry ids (`inverse_method_registry`)

Case-insensitive. Class: `csm`/`dspm`/`sloreta`/`sloreta3d`/`sbl`, `mne`/`wmne`, `eloreta`, `kalman`/`kf`, `beamformer`, `dipolescan`/`dipole_scan`, `ias`, `ramus`, `grouplasso`/`group_lasso`, `halpr`.

Legacy: `legacy_csm`, `legacy_mne`, `legacy_kalman`, `legacy_ias`, `legacy_ramus`, `legacy_dipolescan`, `legacy_beamformer`, `legacy_sl1`, `legacy_relax`, `legacy_sesame`, `legacy_hb`/`legacy_mcmc`, `legacy_music`, `legacy_rap_music`, `legacy_exp`.

## Cluster batch

Needs Parallel Computing Toolbox. `configure_cluster_profile` is **CSC Puhti / `configCluster` specific** (`AdditionalProperties.ComputingProject`, `MemPerCPU`, `WallTime`, …). It is not a Zeffiro INI profile.

```matlab
cluster = utilities.cluster.configure_cluster_profile("project_XXXX", ...
    "MemPerCPU", "8g", "WallTime", "24:00:00", "Partition", "small");

submissions = utilities.cluster.submit_inverse_jobs(cluster, {bundle}, ...
    "BundleDir", fullfile(pwd, "cluster_bundles"), ...
    "ResultDir", fullfile(pwd, "cluster_results"));
% writes inverse_bundle_*.mat and queues @run_inverse_job

[results, summary] = utilities.cluster.collect_inverse_results(submissions);
```

`run_inverse_job(bundle_path, result_path)` loads variable `bundle`, calls `dispatch_inverse`, saves `result` (`-v7.3`). On failure it still writes `result` then rethrows. `opts.EnableProfiler` stores `profilerInfo`.

`create_batch_job` is a generic `parallel.batch` wrapper (any function handle). `run_cluster_job_example` is a deprecated alias of `run_inverse_job`.

`example_workflow.m` is a script (not a function): expects `zef` in base and a live Puhti-style profile.

## Side effects

- Class dispatch opens a `zef_waitbar`.
- `with_zef_in_base` temporarily overwrites base `zef`.
- `submit_inverse_jobs` creates `BundleDir` / `ResultDir` and writes MAT-files.
- `configure_cluster_profile` `saveProfile`s as `opts.ProfileName` (default `"CSCPuhti"`).
