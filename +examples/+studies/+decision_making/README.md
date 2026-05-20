# Decision Making — Focal Epilepsy Source Localization

This module implements a workflow for focal epilepsy source localization that compares **11 inverse methods** and uses **credibility-based clustering** to select the most reliable reconstructions. It demonstrates how Zeffiro Interface can support a clinical-style pipeline: multiple modalities (EEG, MEG, MEEG), multiple methods, and automated combination of results.

## What Will You Learn?

- How the **DataBank** organizes lead fields and reconstructions for different modalities (EEG, MEG, MEEG).
- How to run many inverse methods (MNE, sLORETA, dSPM, MNE-RAMUS, Dipole Scan, Beamformer, IAS variants, EXP-L1) in sequence.
- How to cluster reconstruction results and use credibility data to select the best subset.
- How to produce a final reconstruction and compare methods in tables and plots.

## When to Use This Module

- You work with epilepsy or other focal source localization.
- You want to compare multiple inverse methods and combine them programmatically.
- You have (or can create) a DataBank project with lead fields and measurements.

## Prerequisites

- **DataBank**: Zeffiro’s DataBank must be set up with lead fields for EEG, MEG, and/or MEEG.
- **Patient project**: A `.mat` project file with precomputed lead fields and the expected DataBank structure.
- **Scripts path**: The scripts under `zef.program_path/scripts` must be on the MATLAB path (for `zef_process_training_data_focal_epilepsy`).

## Inverse Methods Used

MNE, sLORETA, MNE-RAMUS, Dipole Scan, Beamformer, IAS (standard and two standardized variants), dSPM, EXP-L1, EXP-L1-sLORETA.

## Workflow Overview

The workflow is split into several scripts. Run them in order:

1. **`zef_parameters_focal_epilepsy`**  
   Load configuration: paths to project and data files, SNR levels, clustering parameters. **Run this first**; it defines variables used by all other scripts.

2. **`zef_create_training_data_focal_epilepsy`**  
   Generate synthetic training data: random dipole positions and orientations, add noise, run all inverse methods, save reconstructions. Produces `training_data_file_name`.

3. **`zef_process_training_data_focal_epilepsy`**  
   Build the credibility dataset from training data. Used when `supervised_clustering = 'on'`. Produces `credibility_data_file_name`.

4. **`zef_find_reconstructions_focal_epilepsy`**  
   Run all inverse methods on the measurements stored in the DataBank and save reconstructions back into the DataBank.

5. **`zef_decision_script_focal_epilepsy`**  
   Main pipeline: retrieve reconstructions, cluster them, compute the final reconstruction, and display results.

## Auxiliary Scripts

| Script | Description |
|--------|-------------|
| `zef_cluster_reconstructions_focal_epilepsy` | GMM clustering on max points and cluster centres; credibility-based selection of methods. |
| `zef_final_reconstruction_focal_epilepsy` | Sums selected reconstructions and extracts the final max point and cluster statistics. |
| `zef_show_results_focal_epilepsy` | Displays a comparison table and distance plots. |
| `zef_rec_maximizer` | Returns the position of the maximum-magnitude dipole in a reconstruction. |
| `zef_set_training_data` | Loads a single training trial into the DataBank for inspection. |

## Configuration

Edit `zef_parameters_focal_epilepsy` to set:

- `project_file_name` — Path to the patient project
- `training_data_file_name` — Where to save training data (empty = do not save)
- `credibility_data_file_name` — Where to save/load credibility data
- `supervised_clustering` — `'on'` to use credibility data, `'off'` for uniform weighting
- `training_data_size`, `snr_vec` — Number of trials and SNR levels for training
- Other clustering and convergence parameters
