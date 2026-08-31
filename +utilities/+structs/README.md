# +utilities/+structs

## Folder purpose

Tiny struct-merge helpers used when applying name-value option structs onto a `zef` / project struct at startup and in examples. Keeps field-copy logic out of `zeffiro_interface.m`.

## Main contents

| File | Role |
|------|------|
| `copy_fields.m` | `utilities.structs.copy_fields(to, from, error_on_overwrite)` |

## Code functionality

```matlab
to_out = utilities.structs.copy_fields(to, from)
to_out = utilities.structs.copy_fields(to, from, true)  % error on overwrite
```

Behavior:

1. Shallow-copies every field from `from` into `to`.
2. If `error_on_overwrite` is true and a field already exists on `to`, returns a **new** struct containing only `copy_fields_error__` (does not return a partial merge of `to`).
3. Nested structs are replaced wholesale — no deep merge.

**Callers:** `zeffiro_interface.m`; `+examples/+meshing/zef_meshing_example.m`; `+examples/+forward/lead_field_example.m`.

## Workflow context

Used early in session construction when CLI/name-value options overlay defaults. Related but separate: profile INI loading and `zef_init` field defaults under `src/app`.

## Usage instructions

```matlab
opts.inv_snr = 30;
zef = utilities.structs.copy_fields(zef, opts);
% strict mode:
out = utilities.structs.copy_fields(zef, opts, true);
if isfield(out, 'copy_fields_error__')
    error(out.copy_fields_error__);
end
```

## Important notes

- Shallow copy only.
- Overwrite-error path discards the original `to` contents in the returned value — always check the error field before using the result as `zef`.
- Not a general “structdiff” or JSON merge utility.

## Developer guidance

- Keep this package minimal; add deep-merge only with explicit tests and a new function name.
- Prefer `error_on_overwrite=false` at the public `zeffiro_interface` boundary unless documenting conflicts.
- Pitfall: treating `copy_fields_error__` as a normal `zef` field and passing it into solvers.
