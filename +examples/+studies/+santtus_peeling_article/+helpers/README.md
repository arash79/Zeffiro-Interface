# +examples/+studies/+santtus_peeling_article/+helpers

## Folder purpose

Helper functions for the Santtu peeling-article Monte Carlo study: reconstruction difference metrics and sensitivity-map builders for dipole scan / MNE comparisons.

## Main contents

| File | Role |
|------|------|
| `zef_rec_diff.m` | Difference / error measure between reconstructions or localization estimates |
| `zef_sensitivity_map_dipoleScan.m` | Sensitivity map helper for dipole-scan path |
| `zef_sensitivity_map_mne.m` | Sensitivity map helper for MNE path |

## Code functionality

Called from the study’s `main` / driver scripts to score localization error vs noise and to build sensitivity visualizations. Inputs are study-specific (`zef`, lead fields, true dipole parameters) — see file headers.

## Workflow context

Parent study: `+examples/+studies/+santtus_peeling_article`. Uses `zef_eeg_lead_field` and classic inverse methods; not a general-purpose plugin.

## Usage instructions

Run via the study `main(...)` entry; do not expect menu wiring.

## Important notes

- Hard-coded assumptions may match the paper’s mesh/SNR grid.
- Not part of `+tests`.

## Developer guidance

- Keep paper metrics here; keep solver bugs fixed upstream in `src/` / plugins.
- Pitfall: reusing sensitivity helpers on a different source model without recomputing `L`.
