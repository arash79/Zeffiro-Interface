# +examples/+studies/+santtus_peeling_article/+helpers

## Folder purpose

Monte Carlo localization helpers for the Santtu peeling-article study. They drive **legacy plugin** inverse kernels (`zef_find_mne_reconstruction`, `zef_dipoleScan`) over every source × xyz direction, then score peak location / orientation / magnitude / spatial dispersion. This is **not** `utilities.sensitivity.run_monte_carlo` (class `zef_inverse_run` path).

Call as `examples.studies.santtus_peeling_article.helpers.*` with the project root on the path.

## Main contents

| File | Signature (essentials) | Role |
|------|------------------------|------|
| `zef_rec_diff.m` | `(zef, inverse_method, noise_db, diff_type, dispersion_radius)` | For each source and unit axis: synthesize a column of `zef.measurements` via `zef_find_source_legacy`, optional additive noise at `noise_db` dB (must be ≤ 0), set `inv_data_mode='raw'`, call `inverse_method(zef)`, then peak-error metrics. |
| `zef_sensitivity_map_mne.m` | `(project_struct, weighting_type, n_reconstructions, …)` | Opens MNE tool (`zef_minimum_norm_estimation`), sets `mne_type` from `'MNE'` / `'dSPM'` / `'sLORETA'` (default `'sLORETA'`), `mne_prior=2`, then repeats `zef_rec_diff(..., @zef_find_mne_reconstruction, …)`. |
| `zef_sensitivity_map_dipoleScan.m` | `(project_struct, n_reconstructions, …)` | Opens dipole scan (`zef_dipole_start`), then `zef_rec_diff(..., @zef_dipoleScan, …)`. Returns a `hauk_map` struct of per-run metric cells. |

Default metric options (both map builders): `n_reconstructions=10`, `noise_level=-30` dB, `diff_type="L2"` or `"minabs"`, `dispersion_radius=30` (same units as `zef.source_positions`).

## Code functionality

**`zef_rec_diff` outputs** (length `3*n_sources` unless noted):

| Output | Meaning |
|--------|---------|
| `dist_vec` | Distance from true source position to reconstructed peak, then × 1/√3 (same scale as `utilities.sensitivity.compute_metrics`) |
| `angle_vec` | Angle error of the recovered dipole (degrees, `acosd`) |
| `mag_vec` | Peak vector-norm of the reconstruction, then × 1/√3 |
| `dispersion_vec` | Energy-weighted RMS spread inside `dispersion_radius` of the peak |

It allocates `zef.measurements` as `n_sensors × 3 n_sources` and fills it with `zef_find_source_legacy` (legacy Find-synthetic-source path), not `utilities.sensitivity.synthesize_measurements`.

Both map builders loop `for i = 1:n_reconstructions` and store metric cells under `{i}`. Each trial is a full xyz-probe pass through `zef_rec_diff` (independent noise when `noise_level < 0`), not a random location jitter.

## Workflow context

Parent study: `+examples/+studies/+santtus_peeling_article` (`main.m`). Needs a meshed project with `zef.L` and `zef.source_positions`. Distinct from `src/sensitivity/zef_sensitivity_run` (class registry ids).

## Usage instructions

Prefer the study `main(...)` entry. Direct calls:

```matlab
sm = examples.studies.santtus_peeling_article.helpers.zef_sensitivity_map_mne( ...
    zef, 'sLORETA', 10, -30, "L2", 30);

hm = examples.studies.santtus_peeling_article.helpers.zef_sensitivity_map_dipoleScan( ...
    zef, 10, -30, "L2", 30);

[dist, ang, mag, disp] = examples.studies.santtus_peeling_article.helpers.zef_rec_diff( ...
    zef, @zef_find_mne_reconstruction, -30, "L2", 30);
```

## Important notes

- Hard-coded assumptions may match the paper’s mesh/SNR grid.
- Not part of `+tests`.
- Plugin Start functions (`zef_minimum_norm_estimation`, `zef_dipole_start`) mutate `zef`; run on a copy if you need the original session intact.
- `L` must be 3 columns per source (xyz).

## Developer guidance

- Keep paper metrics here; keep solver bugs fixed upstream in `src/` / plugins.
- If you need class inverters or cluster dispatch, use `utilities.sensitivity` instead of duplicating this loop.
- Pitfall: reusing these helpers on a different source model without recomputing `L`.
