# `utilities.structs` — copy fields onto `zef`

One function: `copy_fields(from, to)`. Used at startup and in examples to overlay name-value option structs onto a session.

```matlab
zef = utilities.structs.copy_fields(kwargs, zef);
```

Overwrites matching names on `to`. With `"error_on_overwrite", true`, the first colliding field aborts and returns `to_out.copy_fields_error__` (a string) instead of a copied struct — callers must check that field. No other struct utilities live here.
