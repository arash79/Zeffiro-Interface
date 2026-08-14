# Cluster inverse examples

How to submit class inverse jobs after you already have a `zef` with `L` and measurements. These are functions, not GUI demos. They need `parallel.Cluster` (Parallel Computing Toolbox). `parameter_sweep` and `configure_cluster_profile` assume a CSC-style `parcluster`.

```matlab
addpath(fileparts(which('zeffiro_interface')));
% zef = ... mesh + lead field + measurements ...
cluster = parcluster;  % or utilities.cluster.configure_cluster_profile(...)

[sub, bundles] = utilities.cluster.examples.eloreta_workflow(zef, cluster);
[sub, bundles] = utilities.cluster.examples.kalman_workflow(zef, cluster, ...
    "MethodParams", struct("method_type", "Basic Kalman filter"));

sweep = struct("noise_level_vec", 30, "evolution_prior_vec", [20 25], "pm_snr_vec", 0);
[sub, bundles] = utilities.cluster.examples.parameter_sweep(zef, cluster, sweep);

[results, summary] = utilities.cluster.collect_inverse_results(sub);
```

Each workflow: `zef_inverse_extract_bundle` → `submit_inverse_jobs`. Defaults write `./cluster_bundles` and `./cluster_results`. `eloreta_workflow` / `kalman_workflow` accept a struct array or cell of `zef` structs (`MethodId` overridable). `parameter_sweep` Cartesian-products `noise_level`, `inv_evolution_prior`, `pm_snr` into Kalman `MethodParams`.
