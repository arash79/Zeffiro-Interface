# `+core` — types, electrode I/O, small linear-algebra helpers

This is a MATLAB **package** at the repository root (`+core`), not `src/core`. `src/core` starts and updates a Zeffiro session. `+core` holds a few refactored pieces that the rest of the application calls as `core.*` once `zeffiro_interface` has `addpath`'d the project root.

Do not `addpath('+core')`. Add the parent of `+core`.

## What is here, and why

| You need… | Use |
|-----------|-----|
| Named FEM source models (Whitney, H(div), St. Venant) | `core.types.ZefSourceModel` |
| Load electrodes from disk without a GUI | `core.io.electrodes.from_csv` / `from_dat` |
| The Import → Import electrodes menu | `core.gui.menu_tool.import_electrodes_callback` |
| Jacobi / SSOR preconditioner matrices | `core.linalg.preconditioners.*` |

That is the entire package (seven `.m` files). Lead-field assembly, meshing, and inverse solvers are **not** here.

## Source models

Lead-field code in `src/forward/lead_field` branches on

```matlab
core.types.ZefSourceModel.from(zef.source_model)
```

Members: `Whitney`, `Hdiv`, `StVenant`, plus `Continuous*` variants and `Error`. Legacy numeric codes 1–6 still map through `from()`. Display names such as `"H(div)"` come from `to_string()`. `core.ZefSourceModel` at the package root is a compatibility shim so older `.mat` files still load.

The Forward & inverse options dialog populates its source-model dropdown from `variants()`.

```matlab
zef.source_model = core.types.ZefSourceModel.Whitney;
zef = zef_update(zef);
```

## Electrodes

Full format, GUI path, and CEM vs point-electrode behaviour: [+io/+electrodes/README.md](+io/+electrodes/README.md).

Short version: **Import → Import electrodes** (not Edit) opens a file picker, parses `.dat`/`.csv`, writes `zef.sensors` and `s_points` / `s_name_list`, then `zef_update`.

## Preconditioners

`core.linalg.preconditioners.jacobi(A)` and `.ssor(A,"coeff",1)` build sparse preconditioner matrices. EEG lead-field PCG in `src/forward` still uses its own SSOR/`ichol` path (`zef.lf_param.precond`); these package functions are the intended shared implementation, not yet the only call site.

## See also

- Session lifecycle: `src/core/README.md`
- Lead fields that consume `ZefSourceModel`: `src/forward/README.md`
- Mesh electrode coupling: `src/mesh/zef_build_electrodes.m`
