# Focal-epilepsy decision-making study

Scripts expect a loaded `zef` with Data Bank nodes already populated (EEG/MEG lead fields under `zef.dataBank.tree.node_1_*`). They drive **legacy plugin GUIs** via `eval(zef.h_mne_start.Callback)` and similar — plugins for the active profile must be loaded.

## Paths (`zef_parameters_focal_epilepsy.m`)

Edit before any run. The script sets:

- `project_file_name = '~/Dropbox/ResearchData/PerEpi_material/Patients/p0803.mat'` then **overwrites** it to `[this_folder/data]/~/Dropbox/...` (concatenated). That default will not resolve. Point `project_file_name` at a real `.mat` **after** the `folder_name` assignment, or put files in `+decision_making/data/`.
- `credibility_data_file_name` → `.../data/credibility_dataset_p0857_10dB`
- `training_data_file_name` starts empty then becomes `.../data/` (trailing folder only)

Also sets `snr_vec = 10`, `training_data_size = 50`, `frame_number = 1`, clustering tolerances, etc. These become workspace variables for the other scripts.

## How to run (order)

```matlab
addpath(fileparts(which('zeffiro_interface')));

% 1. Parameters (workspace vars)
run('+examples/+studies/+decision_making/zef_parameters_focal_epilepsy.m');

% 2. Synthetic training set (opens project if zef missing; zef_start_dataBank)
run('+examples/+studies/+decision_making/zef_create_training_data_focal_epilepsy.m');

% 3. Process / find reconstructions as needed
run('+examples/+studies/+decision_making/zef_process_training_data_focal_epilepsy.m');
run('+examples/+studies/+decision_making/zef_find_reconstructions_focal_epilepsy.m');

% 4. Cluster + show (uses zef_dataBank_get_reconstructions)
run('+examples/+studies/+decision_making/zef_decision_script_focal_epilepsy.m');
```

`zef_decision_script_focal_epilepsy` is a script: parameters → `zef_dataBank_get_reconstructions(zef, frame_number)` → helpers `zef_cluster_reconstructions_focal_epilepsy`, `zef_final_reconstruction_focal_epilepsy`, `zef_show_results_focal_epilepsy`.

Helpers live in `+helpers/` (`zef_rec_maximizer` is the only function; the rest are scripts that read workspace `zef` / `z_inverse_*`).
