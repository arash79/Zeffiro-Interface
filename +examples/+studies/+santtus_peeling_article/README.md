## Folder purpose

Santtu peeling-article sensitivity study: Monte Carlo localization error vs noise for sLORETA / dSPM / MNE / dipole scan on an EEG lead field.

## Main contents

| File / folder | Role |
|---------------|------|
| `main.m` | Function entry `examples.studies.santtus_peeling_article.main` |
| `+helpers/` | Sensitivity maps and localization difference metrics |

## Code functionality

Opens a project (`zeffiro_interface(..., 'open_project', project_path)`) or accepts name-value `zef=`. When `build_lead_field` is true it calls **`zef_eeg_lead_field`** (EEG only), not `zef_lead_field_matrix`. Reconstructions go through `zef_minimum_norm_estimation` then helpers `zef_sensitivity_map_mne` or `zef_sensitivity_map_dipoleScan` (legacy tools). In-memory `zef=` is `assignin('base','zef',...)` because those tools read base `zef`.

Helpers: `zef_rec_diff` (distance/angle/magnitude/dispersion vs true sources), plus the two sensitivity-map wrappers.

## Workflow context

After (or instead of) a saved project with mesh; optionally builds lead field and runs noisy inverse trials. Not `zef_inverse_run`.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));

[stats, L] = examples.studies.santtus_peeling_article.main( ...
    "path/to/project.mat", ...
    "sLORETA", ...
    10, ...
    -30, ...
    "L2", ...
    30, ...
    "use_gpu", false, ...
    "build_mesh", false, ...
    "build_lead_field", true, ...
    "n_of_sources", 10000);
```

Methods: `"sLORETA"` \| `"dSPM"` \| `"MNE"` \| `"Dipole Scan"`. Diff types: `"L2"` \| `"minabs"`. `noise_level_db` ≤ 0.

## Important notes

If `project_path` is empty you must pass `zef=` with a non-empty struct (`MissingProject` otherwise). Requires legacy Inverse-tools plugins on the path.

## Developer guidance

Keep EEG lead-field construction on `zef_eeg_lead_field` unless the study explicitly moves to the generic matrix API. Document new method strings in both `main` and the helpers README.
