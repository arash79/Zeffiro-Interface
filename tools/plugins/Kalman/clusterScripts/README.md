# Kalman Plugin — Cluster Scripts

Batch processing scripts for running Kalman filter reconstructions on MATLAB Parallel Server (HPC clusters). These scripts enable automated parallel execution of multiple reconstructions with different parameters or datasets.

## File Reference

| File | Function | Description |
|------|----------|-------------|
| `createJob_runJob.m` | `createJob_runJob` | Creates a MATLAB Parallel Server batch job. Configures the cluster profile, sets up the attached files (including the Kalman plugin), defines the task function, and submits the job. |
| `run_cluster_job.m` | `run_cluster_job` | Worker function executed on the cluster node. Loads a Zeffiro project file, runs `zef_KF` (or variant), saves results, and handles errors. Called by the batch job framework. |
| `runKalmanScript.m` | `runKalmanScript` | Template script for cluster-based Kalman filter processing. Configures parameters, iterates over datasets or parameter sweeps, and collects results. |

## Usage

```matlab
% 1. Configure cluster profile
cluster = parcluster('your_cluster_profile');

% 2. Submit batch job
job = createJob_runJob(cluster, project_file, output_dir, params);

% 3. Wait for completion and retrieve results
wait(job);
results = fetchOutputs(job);
```

## Notes

- Ensure the Kalman plugin directory is on the cluster's MATLAB path or included via `AttachedFiles`
- For DTI structural Q on the cluster, the DTI data must be accessible from the worker nodes (shared filesystem or pre-loaded in the project file)
- Each worker needs sufficient memory for the state covariance P (see memory table in the parent README)
