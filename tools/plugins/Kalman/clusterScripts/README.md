# Kalman `clusterScripts/` — deprecated batch wrappers

Not the Inverse-tools **Start** button. The live cluster API is `utilities.cluster` (`run_inverse_job`, `dispatch_inverse`, examples `kalman_workflow`).

| File | Role |
|------|------|
| `createJob_runJob.m` | Warns and returns. Message: use `utilities.cluster.examples.kalman_workflow`. |
| `run_cluster_job.m` | Forwards to `utilities.cluster.run_inverse_job(bundle_path, result_path, "EnableProfiler", ...)`. |
| `runKalmanScript.m` | Interactive batch: optional Carsten synth data, opens Data Bank / Kalman / MNE / Find synthetic source / Parcellation, writes measurements and reconstructions into the Data Bank. Needs `zef.save_file_path` files. |

Prefer `+utilities/+cluster/+examples/kalman_workflow.m` for new cluster jobs. Registry ids `kalman` / `kf` select `inverse.KalmanInverter`, which is **not** `zef_KF` and has no DTI `Q`.
