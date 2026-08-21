# cluster — examples
## Folder purpose

Cluster inverse examples: submit class inverse jobs after you already have a `zef` with `L` and measurements. Functions, not GUI demos. Need `parallel.Cluster` (Parallel Computing Toolbox).

## Main contents

| File | Role |
|------|------|
| `eloreta_workflow.m` | Submit eLORETA jobs |
| `kalman_workflow.m` | Submit Kalman jobs |
| `parameter_sweep.m` | Cartesian product of Kalman MethodParams |

## Code functionality

Each workflow: `zef_inverse_extract_bundle` → `submit_inverse_jobs`. Defaults write `./cluster_bundles` and `./cluster_results`. `eloreta_workflow` / `kalman_workflow` accept a struct array or cell of `zef` structs (`MethodId` overridable). `parameter_sweep` Cartesian-products `noise_level`, `inv_evolution_prior`, `pm_snr` into Kalman `MethodParams`. `parameter_sweep` and `configure_cluster_profile` assume a CSC-style `parcluster`.

## Workflow context

After mesh + lead field + measurements. Results collected with `utilities.cluster.collect_inverse_results`. Parent cluster utilities: `+utilities/+cluster/README.md`.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));
cluster = parcluster;  % or utilities.cluster.configure_cluster_profile(...)

[sub, bundles] = utilities.cluster.examples.eloreta_workflow(zef, cluster);
[sub, bundles] = utilities.cluster.examples.kalman_workflow(zef, cluster, ...
    "MethodParams", struct("method_type", "Basic Kalman filter"));

sweep = struct("noise_level_vec", 30, "evolution_prior_vec", [20 25], "pm_snr_vec", 0);
[sub, bundles] = utilities.cluster.examples.parameter_sweep(zef, cluster, sweep);

[results, summary] = utilities.cluster.collect_inverse_results(sub);
```

## Important notes

These are not unit tests and not the study scripts under `+examples/+studies`. Output dirs default under the current working directory.

## Developer guidance

Keep workflows thin wrappers over `submit_inverse_jobs`. New MethodParams examples should mirror inverter README parameter names.
