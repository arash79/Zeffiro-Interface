# Lead-field normalization maps (merge time)

Each file is `(L, measurements) = f(lf_bank_index)`. **Merge selected** (`zef_combine_lead_fields`) does `str2func` of the selected file and runs it on each selected bank index. The functions `evalin('base', ...)` the item `zef.lf_bank_storage{index}` and return scaled copies. They do **not** assemble a new lead field and they do **not** `assignin`.

## Dropdown labels

`zef_init_lf_bank_tool` `dir`s this folder, then for each file takes MATLAB `help`, finds `Description:`, and uses `strtrim` of the remainder as the list label. **Keep a `Description:` line** or the dropdown entry is empty. Labels are then **sorted alphabetically**, so `zef.lf_normalization` is an index into that sorted list, not a stable enum.

With the current Description strings the sorted order is:

1. No normalization
2. Normalize Frobenius
3. Normalize maximum data
4. Normalize mean data
5. Scaling
6. Whitening
7. Whitening diagonal identity

After stacking, `zef_combine_lead_fields` additionally rescales the concatenated `L` and measurements by `sqrt(sum_i ||L_i||_F^2) / ||L||_F` when `zef.lf_normalization == 2` (that is, when the sorted selection is **Normalize Frobenius**).

## What each file computes

| File | `Description:` | Body |
|------|----------------|------|
| `zef_lead_field_no_normalization` | No normalization | Return `L` and measurements unchanged. |
| `zef_lead_field_normalize_frobenius` | Normalize Frobenius | `sqrt(n_sensors)*L / ||L||_F` (same factor on measurements). |
| `zef_lead_field_normalize_maximum_data` | Normalize maximum data | Scale by `max(L,'fro')`. |
| `zef_lead_field_normalize_mean_data` | Normalize mean data | `sqrt(n_sensors) / mean(column 2-norms)`. |
| `zef_lead_field_scaling` | Scaling | Multiply by the item’s `scaling_factor` (set when adding to the bank). |
| `zef_lead_field_whitening` | Whitening | Left-multiply by `inv(sqrtm(cov(noise_data')))`. Needs `noise_data`. |
| `zef_lead_field_whitening_diagonal_identity` | Whitening diagonal identity | Same after scaling the noise covariance to unit diagonal. |

Parent merge semantics (first selected item wins sensors / imaging method): [../../README.md](../../README.md).
