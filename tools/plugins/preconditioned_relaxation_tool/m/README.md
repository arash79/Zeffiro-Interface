# Preconditioned relaxation — MATLAB files (`m/`)

Inverse tools → **Preconditioned relaxation tool**. Find a stored preconditioner first, then iterate the normal equations. This is **not** an `inverse.*Inverter`. Registry id `legacy_relax` dispatches `zef_relax_iteration`. User-facing Start / Find buttons: parent [../README.md](../README.md).

| File | Role |
|------|------|
| `zef_relax_inversion_tool.m` | **script** INI callback. Loads `zef_relax.mlapp`, wires **Start iteration** and **Find preconditioner**. |
| `zef_update_relax_inversion_tool.m` | Widgets → `zef.relax_*` (SNR, frames, iteration type, …). |
| `zef_relax_find_preconditioner.m` | Builds `zef.relax_preconditioner` and `relax_preconditioner_permutation`. Does not invert. |
| `zef_relax_iteration.m` | Uses those two fields; writes `zef.reconstruction` (tag `Relaxation`). Argument `[]` is the historical void from the fig callback. |

Layout: [../mlapp/README.md](../mlapp/README.md).
