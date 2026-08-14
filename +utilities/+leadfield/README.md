# `utilities.leadfield` — integer type to short tag

One function: `utilities.leadfield.lf_tag_from_lf_type(lf_type)`.

```matlab
tag = utilities.leadfield.lf_tag_from_lf_type(1);  % 'EEG'
```

| `lf_type` | Tag |
|-----------|-----|
| 1 | `'EEG'` |
| 2 | `'MEG'` |
| 3 | `'gMEG'` |
| 4 | `'EIT'` |
| 5 | `'tES'` |

`mustBeMember` **rejects** every other integer, including anisotropic codes 6–10 that `zef_lead_field_matrix` accepts. There is **no first-party caller** of this function in the current tree. Lead-field assembly is `src/forward/lead_field/`; do not use this helper as a substitute for `zef.lead_field_type`.
