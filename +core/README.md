# `+core` — types, electrode I/O, small linear-algebra helpers

## Folder purpose

MATLAB **package** at the repository root (`+core`), not `src/core`. `src/core` starts and updates a Zeffiro session. `+core` holds refactored pieces called as `core.*` once `zeffiro_interface` has `addpath`'d the project root. Do not `addpath('+core')`; add the parent of `+core`.

## Main contents

| Need | Use |
|------|-----|
| Named FEM source models (Whitney, H(div), St. Venant) | `core.types.ZefSourceModel` |
| Load electrodes from disk without a GUI | `core.io.electrodes.from_csv` / `from_dat` |
| Import → Import electrodes menu | `core.gui.menu_tool.import_electrodes_callback` |
| Jacobi / SSOR preconditioner matrices | `core.linalg.preconditioners.*` |

That is the entire package (seven `.m` files). Lead-field assembly, meshing, and inverse solvers are not here.

## Code functionality

Lead-field code in `src/forward/lead_field` branches on `core.types.ZefSourceModel.from(zef.source_model)`. Members: `Whitney`, `Hdiv`, `StVenant`, Continuous* variants, and `Error`. Legacy codes 1–6 map through `from()`. Display names such as `"H(div)"` come from `to_string()`. `core.ZefSourceModel` at the package root is a compatibility shim for older `.mat` files. The Forward & inverse options dialog populates its source-model dropdown from `variants()`.

`core.linalg.preconditioners.jacobi(A)` and `.ssor(A,"coeff",1)` build sparse/dense preconditioner matrices for shared use.

## Workflow context

Electrode import: **Import → Import electrodes** opens a file picker, parses `.dat`/`.csv`, writes `zef.sensors` and `s_points` / `s_name_list`, then `zef_update`. Full format and CEM vs point behaviour: `+io/+electrodes/README.md`. EEG lead-field PCG in `src/forward` still uses its own SSOR/`ichol` path (`zef.lf_param.precond`); package preconditioners are the intended shared implementation, not yet the only call site.

## Usage instructions

```matlab
zef.source_model = core.types.ZefSourceModel.Whitney;
zef = zef_update(zef);
```

Parsers and menu callback: see child READMEs under `+io` and `+gui`.

## Important notes

Session lifecycle remains in `src/core`. Mesh electrode coupling: `src/mesh/zef_build_electrodes.m`. Lead fields that consume `ZefSourceModel`: `src/forward/README.md`.

## Developer guidance

Keep `+core` small and package-callable. Do not move session lifecycle here. Prefer documenting APIs in child READMEs rather than duplicating them at this level.
