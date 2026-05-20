# Cluster Utilities

Cluster utilities for running inverse computations on CSC Puhti with a
bundle-based workflow (minimal payload per job).

## Prerequisites

1. Install CSC MATLAB integration scripts and run `configCluster`.
2. Ensure `parcluster` points to the CSC Generic/Slurm profile.
3. Use a valid project account (for `ComputingProject`).

References:
- [CSC MATLAB docs](https://docs.csc.fi/apps/matlab/)
- [CSC Puhti docs](https://docs.csc.fi/computing/systems-puhti/)

## Main API

- `utilities.cluster.configure_cluster_profile`  
  Configures CSC-compatible `AdditionalProperties` (`ComputingProject`,
  `MemPerCPU`, `WallTime`, optional `Partition`, `GPUsPerNode`, etc.).

- `zef_inverse_extract_bundle`  
  Extracts a minimal inverse payload (`L`, `procFile`, framed `F`,
  source positions, method params) from `zef`.

- `utilities.cluster.submit_inverse_jobs`  
  Saves bundles and submits one batch job per bundle via
  `utilities.cluster.run_inverse_job`.

- `utilities.cluster.collect_inverse_results`  
  Collects `result.mat` files and returns status summaries.

- `zef_inverse_run`  
  Unified entry point with `execution = "local" | "cluster"`.

## Quick Start

```matlab
% 1) Configure profile
c = utilities.cluster.configure_cluster_profile( ...
    "project_2002680", ...
    "MemPerCPU", "8g", ...
    "WallTime", "24:00:00", ...
    "Partition", "small");

% 2) Extract bundle
bundle = zef_inverse_extract_bundle(zef, "dspm");

% 3) Submit + collect
sub = utilities.cluster.submit_inverse_jobs(c, {bundle});
[results, summary] = utilities.cluster.collect_inverse_results(sub);
```

## Notes

- `run_cluster_job_example` is retained only as a deprecated wrapper.
- Legacy CSC scripts under `CSC_Cluster_Kalman` are deprecated in favor of
  `utilities.cluster.examples.*`.
- Bundle and result schemas are documented in `SCHEMA.md`.
