# Peeling-article helpers

Called from `examples.studies.santtus_peeling_article.main`. They are not standalone demos and not `zef_inverse_run`. Each Monte Carlo trial adds noise to measurements, runs a **legacy Inverse-tools plugin** (MNE tool or Dipole Scan), then scores localization error against a known synthetic source.

Parent study README: [../README.md](../README.md). Metrics are related to `utilities.sensitivity.compute_metrics` but these helpers drive the GUI solvers.

```matlab
% Inside main(...): n_runs noisy inverses per method, then a difference map.
zef_sensitivity_map_mne(project_struct, "sLORETA", n_runs, noise_db, diff_type, dispersion_radius);
zef_sensitivity_map_dipoleScan(project_struct, ..., n_runs, noise_db, ...);
```

| Function | Role |
|----------|------|
| `zef_sensitivity_map_mne(project_struct, inverse_method, n_runs, noise_db, diff_type, dispersion_radius)` | Monte Carlo for `"sLORETA"` / `"dSPM"` / `"MNE"` via **Minimum norm estimation tool** callbacks (`zef_minimum_norm_estimation`, `zef_find_mne_reconstruction`) |
| `zef_sensitivity_map_dipoleScan(...)` | Same pattern for Inverse tools → **Dipole Scan** (`zef_dipoleScan`) |
| `zef_rec_diff(zef, inverse_method, noise_db, diff_type, ...)` | Localization metrics on the current `zef.reconstruction` vs the true source (related to `utilities.sensitivity.compute_metrics`) |

Require those plugins on the path and a `zef` with `L`, interpolation, and a known synthetic source (the study’s `main` sets that up with `zef_eeg_lead_field`). `project_struct` is the session struct the study passes through, not a Brainstorm protocol.
