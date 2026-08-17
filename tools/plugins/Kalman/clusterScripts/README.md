# Kalman / clusterScripts

## Folder purpose

Legacy / lab **batch and cluster helpers** for Kalman workflows. Not the Inverse tools → Kalman GUI (`zef_kf_start`). Two wrappers are deprecated in favor of `utilities.cluster`; one script drives a local synth→KF/MNE→Data Bank loop.

## Main contents

| File | Role |
|------|------|
| `run_cluster_job.m` | Deprecated → `utilities.cluster.run_inverse_job` |
| `createJob_runJob.m` | Deprecated stub → `utilities.cluster.examples.kalman_workflow` |
| `runKalmanScript.m` | Interactive batch: synth sources, Data Bank L, KF or MNE, save |

## Code functionality

- `run_cluster_job(bundle_path, result_path, profiler_on)` warns and forwards to `utilities.cluster.run_inverse_job` with `EnableProfiler`.
- `createJob_runJob` only emits a deprecation warning and returns.
- `runKalmanScript`: optional load of `carsten_synth_source_data.mat`; opens Data Bank / KF / MNE / FSS / parcellation; loops (~50) switching Data Bank hashes (`node_5` / `node_7`), `zef_generate_time_sequence`, `zef_find_source` → `zef.measurements`, then `zef_KF` or `zef_find_mne_reconstruction`, pushes entries via `zef_dataBank_addButtonPress`, parcellation time series, `savefig`.

## Workflow context

Cluster path: package an inverse job bundle and run on a worker via the utilities API. Lab script path: assumes an already-started Zeffiro session with `zef.save_file_path`, Data Bank nodes, and synth-source assets present.

## Usage instructions

- Prefer: `utilities.cluster.run_inverse_job(...)` or `utilities.cluster.examples.kalman_workflow`.
- For local experiments only: open Zeffiro, ensure Data Bank hashes and synth MAT exist, then run `runKalmanScript` (edit `inv_type` / SNR / KF widget values in-script).
- Do not use these files as the menu StartButton for Kalman.

## Important notes

- Hard-coded Data Bank hashes, frame counts, and SNR (`zef.KF.inv_snr`, filter_type `'3'`, etc.) are experiment-specific.
- `runKalmanScript` mutates GUI app Values and expects `zef.KF` / `find_synth_source` apps open.
- Deprecated functions always `warning` with id `plugins.Kalman.clusterScripts:Deprecated`.

## Developer guidance

New cluster code belongs under `+utilities/+cluster`, not here. Keep this folder as thin compatibility or delete callers once migrated. If updating `runKalmanScript`, parameterize paths/hashes instead of embedding node ids.
