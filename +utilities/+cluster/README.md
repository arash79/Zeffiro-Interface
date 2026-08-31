# `utilities.cluster` — class/legacy inverse dispatch and batch jobs

## Folder purpose

Router between `zef_inverse_run` / `zef_inverse_extract_bundle` and `+inverse` inverter classes (or legacy `zef_*` plugin functions). The **class** local path is what `zef_inverse_run(..., 'execution','local')` uses. Inverse-tools menu buttons do **not** come through here; they call plugin iterations directly. Cluster path serializes bundles and `batch`es `run_inverse_job`. Bundle field list: [`SCHEMA.md`](SCHEMA.md).

## Main contents

Core: `dispatch_inverse`, `inverse_method_registry`, `with_zef_in_base`, `run_inverse_job`, `submit_inverse_jobs`, `collect_inverse_results`, `configure_cluster_profile`.

`+examples/`: `eloreta_workflow.m`, `kalman_workflow.m`, `parameter_sweep.m` (Cartesian Kalman `MethodParams`).

## Code functionality

`dispatch_inverse` requires `bundle.method_info` from the registry. Class path: construct `inverse.*Inverter`, `utilities.inverse.run_frame_loop`, optional smoother/terminate, `zef_postProcessInverseClassObj`. Legacy path: `with_zef_in_base` + `feval(legacy_function)`. Errors: `utilities:cluster:UnknownInverseMethod`, `MissingLegacyZef`, `UnsupportedExecutionKind`.

Registry (case-insensitive). Class: `csm`/`dspm`/`sloreta`/`sloreta3d`/`sbl`, `mne`/`wmne`, `eloreta`, `kalman`/`kf`, `ukfnmm`/`ukf_nmm`, `beamformer`, `dipolescan`/`dipole_scan`, `ias`, `ramus`, `grouplasso`/`group_lasso`, `halpr`. Legacy: `legacy_csm`, `legacy_mne`, `legacy_kalman`, `legacy_ias`, `legacy_ramus`, `legacy_dipolescan`, `legacy_beamformer`, `legacy_sl1`, `legacy_relax`, `legacy_sesame`, `legacy_hb`/`legacy_mcmc`, `legacy_music`, `legacy_rap_music`, `legacy_exp`.

`run_inverse_job(bundle_path, result_path)` loads `bundle`, calls `dispatch_inverse`, saves `result` (`-v7.3`); on failure still writes `result` then rethrows. `opts.EnableProfiler` stores `profilerInfo`.

## Workflow context

Local dispatch sits under `zef_inverse_run`. Cluster batch needs Parallel Computing Toolbox. `configure_cluster_profile` is **CSC Puhti / `configCluster` specific** (`AdditionalProperties.ComputingProject`, `MemPerCPU`, `WallTime`, …)—not a Zeffiro INI profile. Side effects: class dispatch opens `zef_waitbar`; `with_zef_in_base` temporarily overwrites base `zef`; submit creates `BundleDir` / `ResultDir` and writes MAT-files; configure `saveProfile`s as `opts.ProfileName` (default `"CSCPuhti"`).

## Usage instructions

```matlab
bundle = zef_inverse_extract_bundle(zef, "eloreta");
result = utilities.cluster.dispatch_inverse(bundle);
% result.method_id, .z_inverse, .reconstruction, .reconstruction_information

cluster = utilities.cluster.configure_cluster_profile("project_XXXX", ...
    "MemPerCPU", "8g", "WallTime", "24:00:00", "Partition", "small");

submissions = utilities.cluster.submit_inverse_jobs(cluster, {bundle}, ...
    "BundleDir", fullfile(pwd, "cluster_bundles"), ...
    "ResultDir", fullfile(pwd, "cluster_results"));

[results, summary] = utilities.cluster.collect_inverse_results(submissions);
```

## Important notes

Examples under `+examples` within this package (e.g. eLORETA / Kalman workflows).

## Developer guidance

Register new method ids only in `inverse_method_registry`. Keep `SCHEMA.md` aligned with bundle fields. Prefer class path for new solvers; legacy path is for existing plugin functions.
