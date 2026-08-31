## Folder purpose

MATLAB for Inverse tools → **Preconditioned relaxation tool**. Find a stored preconditioner, then iterate the normal equations. Not an `inverse.*Inverter`. Registry id `legacy_relax` dispatches `zef_relax_iteration`.

## Main contents

| File | Role |
|------|------|
| `zef_relax_inversion_tool.m` | Script INI callback; loads `zef_relax.mlapp`; wires Start / Find preconditioner |
| `zef_update_relax_inversion_tool.m` | Widgets → `zef.relax_*` |
| `zef_init_relax_inversion_tool.m` | Defaults |
| `zef_relax_find_preconditioner.m` | Builds `zef.relax_preconditioner` and `relax_preconditioner_permutation` |
| `zef_relax_iteration.m` | Uses those fields; writes `zef.reconstruction` (tag `Relaxation`) |
| `zef_block_diagonal_preconditioner_uniform_prior.m` / `zef_diagonal_preconditioner_uniform_prior.m` | Preconditioner builders |
| `zef_make_multigrid_dec.m` | Multigrid-style decomposition helper |

Layout: parent `mlapp/`. User-facing Start / Find: parent README.

## Code functionality

**Find preconditioner** does not invert; it stores preconditioner + permutation. **Start iteration** runs `zef_relax_iteration` (argument `[]` is the historical void from the fig callback), using SNR/frames/iteration-type fields under `relax_*`.

## Workflow context

Inverse tools → Preconditioned relaxation tool. Needs `zef.L` and measurements. Related class/registry path may call the same iteration via `legacy_relax`.

## Usage instructions

Open from the menu → **Find preconditioner** → **Start iteration**. Or:

```matlab
zef_relax_inversion_tool
zef = zef_relax_find_preconditioner(zef);
zef = zef_relax_iteration([]);
```

## Important notes

- Iteration expects preconditioner fields already set; Find first.
- Not a class inverter; GUI and registry share the legacy iteration entry point.
- `[]` argument on iteration is historical void.

## Developer guidance

Keep preconditioner builders and iteration contracts aligned (`relax_preconditioner`, permutation). Prefer documenting new iteration types in the parent README and update widget → `relax_*` mapping in `zef_update_relax_inversion_tool`.
