# `+config` — fs2zef lookup tables

These tables turn FreeSurfer label **names** into Zeffiro compartment defaults when `generate_zef_import` writes `import_segmentation.zef`. They are not read by `zef_import_segmentation` at GUI import time; they only affect converter output.

| Function | Used by | What it stores |
|----------|---------|----------------|
| `compartment_mappings` | `generate_zef_import` | Keyword → default `sigma` (S/m), `activity` (source flag), `inflate`. Examples in the file: grey 0.33 / 1, white 0.14 / 3, CSF 1.79 / 0, skull 0.0064 / 0 |
| `default_config` | `test_unified_pipeline` only | Parcellation scheme names, `recon_all` flags, retries. **`run` does not read this** |
| `parcellation_schemes` | `test_unified_pipeline` | Desikan-Killiany (`aparc`, id `'36'`) and Destrieux (`aparc.a2009s`, id `'76'`) metadata |

Edit `compartment_mappings` when a new tissue name should get a non-default conductivity. Adding a field to `default_config` will not change `utilities.fs2zef.run` until someone wires it. Parent pipeline: [`../README.md`](../README.md).
