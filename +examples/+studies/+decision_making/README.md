## Folder purpose

Focal-epilepsy decision-making study: build/process training data, find reconstructions in the Data Bank, cluster them, and show results via legacy MNE-tool / GMM plugin callbacks.

## Main contents

| File | Role |
|------|------|
| `zef_parameters_focal_epilepsy.m` | Path and run parameters (workspace vars) |
| `zef_create_training_data_focal_epilepsy.m` | Synthetic training set; opens project / Data Bank |
| `zef_process_training_data_focal_epilepsy.m` | Process training measurements |
| `zef_find_reconstructions_focal_epilepsy.m` | Invert / store reconstructions |
| `zef_decision_script_focal_epilepsy.m` | Cluster + final reconstruction + show |
| `+helpers/` | Clustering / display helpers |

## Code functionality

Scripts expect a loaded `zef` with Data Bank nodes already populated (EEG/MEG lead fields under `zef.dataBank.tree.node_1_*`). They drive **legacy plugin GUIs** via `eval(zef.h_mne_start.Callback)` and similar — plugins for the active profile must be loaded.

`zef_decision_script_focal_epilepsy`: parameters → `zef_dataBank_get_reconstructions(zef, frame_number)` → helpers `zef_cluster_reconstructions_focal_epilepsy`, `zef_final_reconstruction_focal_epilepsy`, `zef_show_results_focal_epilepsy`.

## Workflow context

After mesh, lead field, and Data Bank setup. Helpers live in `+helpers/` (`zef_rec_maximizer` is the only function; the rest are scripts that read workspace `zef` / `z_inverse_*`).

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));

run('+examples/+studies/+decision_making/zef_parameters_focal_epilepsy.m');
run('+examples/+studies/+decision_making/zef_create_training_data_focal_epilepsy.m');
run('+examples/+studies/+decision_making/zef_process_training_data_focal_epilepsy.m');
run('+examples/+studies/+decision_making/zef_find_reconstructions_focal_epilepsy.m');
run('+examples/+studies/+decision_making/zef_decision_script_focal_epilepsy.m');
```

## Important notes

Edit paths in `zef_parameters_focal_epilepsy.m` before any run. The script sets `project_file_name` to a Dropbox path then **overwrites** it to a concatenated `[this_folder/data]/~/Dropbox/...` string that will not resolve. Point `project_file_name` at a real `.mat` **after** the `folder_name` assignment, or put files in `+decision_making/data/`. Also sets `credibility_data_file_name`, `snr_vec = 10`, `training_data_size = 50`, `frame_number = 1`, clustering tolerances, etc.

## Developer guidance

Keep parameter script first in the run order. Prefer helpers that take explicit arguments over new workspace globals when extending the study.
