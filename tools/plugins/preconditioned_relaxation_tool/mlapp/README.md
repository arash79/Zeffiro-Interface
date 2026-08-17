# Preconditioned relaxation tool — App Designer layouts

## Folder purpose

App Designer UI for the **Preconditioned relaxation tool**: solve the inverse normal equations with a stored multigrid / diagonal preconditioner (Landweber or PCG), after **Find preconditioner** has filled `zef.relax_preconditioner`.

## Main contents

| File | Role |
|------|------|
| `zef_relax.mlapp` | Preconditioned Iterative Relaxation window (Start iteration, Find preconditioner, iteration type, preconditioner type, SNR / tolerance widgets) |
| `README.md` | This documentation |

Solvers: `tools/plugins/preconditioned_relaxation_tool/m/` (`zef_relax_inversion_tool`, `zef_relax_iteration`, `zef_relax_find_preconditioner`, update helpers).

## Code functionality

`zef_relax_inversion_tool` loads this app and wires **Start iteration** → `zef_update_relax_inversion_tool; [zef.reconstruction, zef.reconstruction_information] = zef_relax_iteration([])` and **Find preconditioner** → `zef_relax_find_preconditioner` (writes `zef.relax_preconditioner` / `_permutation` only). Iteration type: Landweber or PCG; preconditioner: Block diagonal RAMUS / Diagonal RAMUS / Identity. Reconstruction tag: `Relaxation`.

## Workflow context

Inverse tools → **Preconditioned relaxation tool** on head and asteroid profiles (`zef_relax_inversion_tool`). Title: `ZEFFIRO Interface: Preconditioned Iterative Relaxation`. Registry id `legacy_relax` dispatches `zef_relax_iteration`; there is no `inverse.*Inverter`.

## Usage instructions

```matlab
zef_relax_inversion_tool;   % opens zef_relax.mlapp
```

1. Open Inverse tools → Preconditioned relaxation tool.
2. Choose iteration type and preconditioner type; press Find preconditioner.
3. Press Start iteration.

Edit UI only in App Designer.

## Important notes

- Find preconditioner must run before Start.
- PCG’s CG coefficient reuses the name `gamma` and overwrites the Landweber step size for that decomposition.
- Non-convergence prints a string in the command window, not `error()`.

## Developer guidance

- Preserve callback `zef_relax_inversion_tool`, tag `Relaxation`, and registry id `legacy_relax`.
- Keep Start / Find-preconditioner handle names (`h_relax_start_iteration`, `h_relax_find_preconditioner`) aligned with the start script.
- Dropdown Items / ItemsData in this `.mlapp` must stay consistent with `zef_relax_iteration` cases.
