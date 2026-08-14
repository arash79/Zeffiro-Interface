# `+core/+types` — `ZefSourceModel`

Canonical enumeration for how a current dipole is discretized inside each tetrahedron when `zef_lead_field_matrix` assembles `zef.L`. The Mesh tool / Forward & inverse options dropdown stores an integer 1–6 on `zef.source_model`; this class is the typed form of that integer.

There are no other types in this folder. `core.ZefSourceModel` at `+core/` (not here) is the original enumeration name stored in older `.mat` files. It must remain an enumeration so MATLAB can load those projects; `from()` then maps members onto this class.

## Members and legacy codes

`from()` maps integers (and the strings `"1"`–`"6"`) to members. Invalid input returns `Error`.

| Code | Member | `to_string` |
|------|--------|-------------|
| 1 | `Whitney` | Whitney |
| 2 | `Hdiv` | H(div) |
| 3 | `StVenant` | St.Venant |
| 4 | `ContinuousWhitney` | Continuous Whitney |
| 5 | `ContinuousHdiv` | Continuous H(div) |
| 6 | `ContinuousStVenant` | Continuous St.Venant |

Whitney / H(div) / St.Venant are the three FEM source models implemented under `src/forward/lead_field`. The **Continuous** variants use the same element type with a continuous (nodal) interpolation of the moment. `Error` is a sentinel, not a solver.

`variants()` lists every member including `Error`. `loadobj` maps a saved value through `from()`; if that yields `Error` it becomes **`Hdiv`** (not `Error`), so a corrupt `.mat` still loads a valid source model.

`from()` also accepts member names (`"Hdiv"`), display names (`"H(div)"`), cells, structs with `ValueNames`, and the shim class `core.ZefSourceModel`.

```matlab
m = core.types.ZefSourceModel.from(zef.source_model);  % enum, 1–6, or "1"–"6"
zef.source_model = core.types.ZefSourceModel.Whitney;
core.types.ZefSourceModel.to_string(m);   % e.g. "H(div)"
```

Consumed by `src/forward/lead_field` and the Forward & inverse options dropdown. Parent: [`../README.md`](../README.md).
