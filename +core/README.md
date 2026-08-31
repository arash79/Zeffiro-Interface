# `+core` — types, electrode files, Import-electrodes callback

This MATLAB package sits at the repository root. Call it as `core.*` after `zeffiro_interface` has added the **parent** of `+core` to the path. Do not `addpath('+core')`.

It is **not** `src/app`. Session start, `zef_update`, and shutdown live there. `+core` is the small typed API extracted so scripts can name a source model and parse electrode files without opening a window.

| Need | Call |
|------|------|
| Named FEM source models (Whitney, H(div), St. Venant) | `core.types.ZefSourceModel` |
| Load electrodes from disk | `core.io.electrodes.from_csv` / `from_dat` |
| **Import → Import electrodes** | `core.gui.menu_tool.import_electrodes_callback` |

Lead-field assembly, meshing, and inverse solvers are not here.

Lead-field code in `src/forward/lead_field` branches on `core.types.ZefSourceModel.from(zef.source_model)`. Members: `Whitney`, `Hdiv`, `StVenant`, Continuous* variants, and `Error`. Legacy codes 1–6 map through `from()`. Display names such as `"H(div)"` come from `to_string()`. `core.ZefSourceModel` at the package root is a compatibility shim for older `.mat` files. The Forward & inverse options dialog populates its source-model dropdown from `variants()`.

Electrode import: **Import → Import electrodes** opens a file picker, parses `.dat`/`.csv`, writes `zef.sensors` and `s_points` / `s_name_list`, then `zef_update`. Formats and CEM vs point behaviour: [`+io/+electrodes/README.md`](+io/+electrodes/README.md).

```matlab
zef.source_model = core.types.ZefSourceModel.Whitney;
zef = zef_update(zef);
```

Mesh electrode coupling: `src/mesh/zef_build_electrodes.m`. Keep this package small. Do not move session lifecycle here.
