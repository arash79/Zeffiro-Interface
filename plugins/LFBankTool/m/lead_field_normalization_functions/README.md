## Folder purpose

Lead-field normalization maps applied at **Merge selected** time in the Multi lead field tool. Each file scales one bank item’s `L` and measurements; none assemble a new lead field or `assignin`.

## Main contents

| File | `Description:` label |
|------|----------------------|
| `zef_lead_field_no_normalization.m` | No normalization |
| `zef_lead_field_normalize_frobenius.m` | Normalize Frobenius |
| `zef_lead_field_normalize_maximum_data.m` | Normalize maximum data |
| `zef_lead_field_normalize_mean_data.m` | Normalize mean data |
| `zef_lead_field_scaling.m` | Scaling |
| `zef_lead_field_whitening.m` | Whitening |
| `zef_lead_field_whitening_diagonal_identity.m` | Whitening diagonal identity |

## Code functionality

Signature: `(L, measurements) = f(lf_bank_index)`. `zef_combine_lead_fields` does `str2func` of the selected file and runs it on each selected bank index. Functions `evalin('base', ...)` the item `zef.lf_bank_storage{index}` and return scaled copies.

| File | Body |
|------|------|
| no_normalization | Unchanged |
| normalize_frobenius | `sqrt(n_sensors)*L / \|\|L\|\|_F` (same on measurements) |
| normalize_maximum_data | Scale by `max(L,'fro')` |
| normalize_mean_data | `sqrt(n_sensors) / mean(column 2-norms)` |
| scaling | Multiply by item `scaling_factor` |
| whitening | Left-multiply by `inv(sqrtm(cov(noise_data')))` |
| whitening_diagonal_identity | Same after scaling noise covariance to unit diagonal |

## Workflow context

Called only from LFBankTool merge. Parent tool README and `../README.md` cover Add / Compute / Merge. After stacking, `zef_combine_lead_fields` may apply an extra Frobenius rescale when `zef.lf_normalization == 2` (Normalize Frobenius in the sorted list).

## Usage instructions

Choose a normalization in the Multi lead field tool dropdown, then Merge. Labels come from MATLAB `help` `Description:` lines; `zef_init_lf_bank_tool` `dir`s this folder and sorts labels alphabetically.

## Important notes

- Keep a `Description:` line or the dropdown entry is empty.
- `zef.lf_normalization` indexes the sorted list, not a stable enum — order can change if Descriptions are renamed.
- Whitening maps need `noise_data` on the bank item.

## Developer guidance

Add a new `.m` with `Description:` / help tags; no INI edit. Do not `assignin` from map functions. Document any post-stack rescale assumptions in the combine function if changing Frobenius behavior.
