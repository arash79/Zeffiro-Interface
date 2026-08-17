# utilities.leadfield

## Folder purpose

Small MATLAB package folder (`+utilities/+leadfield`) that maps numeric **isotropic lead-field type codes** to short string tags for databank / LF-bank labelling. It is a pure helper: no `zef` I/O, no FEM assembly, no file reads. Forward solvers continue to use numeric `zef.lead_field_type` directly in `src/forward/lead_field/`; this package exists so callers that need a stable modality string can share one validated map.

## Main contents

| File | Role |
|------|------|
| `lf_tag_from_lf_type.m` | Map types **1–5** → `'EEG'`, `'MEG'`, `'gMEG'`, `'EIT'`, `'tES'` |
| `README.md` | This documentation |

Package call form:

```matlab
tag = utilities.leadfield.lf_tag_from_lf_type(lf_type);
```

There are no other functions in this package today. Gravity forward types use `zef.gravity_field_type` (1–4) and `zef_lead_field_matrix_gravity` — they are **out of scope** for this mapper.

## Code functionality

`lf_tag_from_lf_type` validates with `arguments` / `mustBeMember(lf_type, [1 2 3 4 5])` and returns:

| `lf_type` | Tag |
|-----------|-----|
| 1 | `'EEG'` |
| 2 | `'MEG'` |
| 3 | `'gMEG'` |
| 4 | `'EIT'` |
| 5 | `'tES'` |

Anisotropic codes **6–10** (twins of 1–5 with anisotropic `sigma`) are **rejected** by `mustBeMember`. Call sites that still have an anisotropic type should map `6→1`, `7→2`, … before calling, if a modality tag is needed. An unknown value outside 1–5 never reaches the final `else` error under normal argument validation; the `else` branch is defensive documentation of the contract.

Implementation notes from the file header:

- No first-party in-repo caller is required for the package to be useful; `src/forward` uses numeric types directly.
- Documented in `src/forward/README.md` and `+utilities/README.md` as the package-qualified form for new code.

## Workflow context

```
zef.lead_field_type (numeric)
        │
        ├─► zef_lead_field_matrix / FEM kernels  (solver path)
        └─► utilities.leadfield.lf_tag_from_lf_type  (string tag path)
```

Intended consumers: LF bank / databank tagging, export metadata, logging. Align meanings with `src/forward/lead_field/zef_lead_field_matrix.m` and profile INI modality rows. Duplicate legacy root helpers (if any) should defer to this package-qualified function rather than growing a second map.

Related packages under `+utilities/`: brainstorm/duneuro/fs import helpers, sensitivity, plotting — none of those replace this type→tag map.

## Usage instructions

```matlab
utilities.leadfield.lf_tag_from_lf_type(1)  % 'EEG'
utilities.leadfield.lf_tag_from_lf_type(2)  % 'MEG'
utilities.leadfield.lf_tag_from_lf_type(3)  % 'gMEG'
utilities.leadfield.lf_tag_from_lf_type(4)  % 'EIT'
utilities.leadfield.lf_tag_from_lf_type(5)  % 'tES'
```

Anisotropic example (call-site remapping):

```matlab
t = zef.lead_field_type;
if t >= 6 && t <= 10
    t = t - 5;   % 6→1 … 10→5
end
tag = utilities.leadfield.lf_tag_from_lf_type(t);
```

Invalid codes (e.g. `0`, `6`, `11`) error via argument validation.

## Important notes

- Only isotropic **1–5** are accepted; anisotropic **6–10** must be remapped at the call site if a tag is required.
- Gravity / radar imaging methods are **not** lead_field_type codes — do not extend this map for gravity kernels.
- Keep string literals exactly as above (`'gMEG'`, `'tES'`) so databank keys stay stable.
- Package lives on the project path as `utilities.leadfield.*` after Zeffiro startup path setup; do not `addpath` the `+leadfield` folder in isolation incorrectly.

## Developer guidance

- When adding a new modality type to the forward dispatcher, update **both** `zef_lead_field_matrix` (and INI) **and** this map (and this README table).
- Prefer package-qualified calls in new code; avoid copying the if/elseif chain into scripts.
- Add a unit test under `+tests` if databank or export code starts depending on these strings.
- Do not accept 6–10 here “for convenience” — that would hide anisotropic vs isotropic distinctions at the tag layer; remapping belongs at the caller.
- If gravity ever needs string tags, add a separate helper (e.g. `gravity_tag_from_gravity_field_type`) rather than overloading this function.
