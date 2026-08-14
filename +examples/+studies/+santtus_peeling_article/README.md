# Santtu peeling-article sensitivity study

Function entry (not a script):

```matlab
addpath(fileparts(which('zeffiro_interface')));

[stats, L] = examples.studies.santtus_peeling_article.main( ...
    "path/to/project.mat", ...   % or '' if you pass zef=
    "sLORETA", ...               % "sLORETA" | "dSPM" | "MNE" | "Dipole Scan"
    10, ...                      % n_of_runs
    -30, ...                     % noise_level_db (≤ 0)
    "L2", ...                    % "L2" | "minabs"
    30, ...                      % dispersion_radius
    "use_gpu", false, ...
    "build_mesh", false, ...
    "build_lead_field", true, ...
    "n_of_sources", 10000);
```

If `project_path` is empty you must pass name-value `zef=` with a non-empty struct (`MissingProject` otherwise). Opening a path uses `zeffiro_interface(..., 'open_project', project_path)`.

When `build_lead_field` is true it calls **`zef_eeg_lead_field`** (EEG only), not the generic `zef_lead_field_matrix`. Reconstructions go through `zef_minimum_norm_estimation` then helpers `zef_sensitivity_map_mne` or `zef_sensitivity_map_dipoleScan` (legacy tools). In-memory `zef=` is `assignin('base','zef',...)` because those tools read base `zef`.

Helpers: `zef_rec_diff` (distance/angle/magnitude/dispersion vs true sources), plus the two sensitivity-map wrappers.
