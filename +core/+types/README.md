# `+core/+types` — `ZefSourceModel`

## Folder purpose

Canonical enumeration for how a current dipole is discretized inside each tetrahedron when `zef_lead_field_matrix` assembles `zef.L`. The Mesh tool / Forward & inverse options dropdown stores an integer 1–6 on `zef.source_model`; this class is the typed form of that integer. There are no other types in this folder.

## Main contents

`ZefSourceModel` enumeration and helpers: `from()`, `to_string()`, `variants()`, `loadobj`. Compatibility shim `core.ZefSourceModel` lives at `+core/` (not here) so older `.mat` files still load; `from()` maps those members onto this class.

| Code | Member | `to_string` |
|------|--------|-------------|
| 1 | `Whitney` | Whitney |
| 2 | `Hdiv` | H(div) |
| 3 | `StVenant` | St.Venant |
| 4 | `ContinuousWhitney` | Continuous Whitney |
| 5 | `ContinuousHdiv` | Continuous H(div) |
| 6 | `ContinuousStVenant` | Continuous St.Venant |

Whitney / H(div) / St.Venant are the three FEM source models under `src/forward/lead_field`. **Continuous** variants use the same element type with continuous (nodal) interpolation of the moment. `Error` is a sentinel, not a solver.

## Code functionality

`from()` maps integers and strings `"1"`–`"6"` to members; invalid input returns `Error`. Also accepts member names (`"Hdiv"`), display names (`"H(div)"`), cells, structs with `ValueNames`, and `core.ZefSourceModel`. `variants()` lists every member including `Error`. `loadobj` maps a saved value through `from()`; if that yields `Error` it becomes **`Hdiv`**, so a corrupt `.mat` still loads a valid source model.

## Workflow context

Consumed by `src/forward/lead_field` and the Forward & inverse options dropdown. Parent overview: `+core/README.md`.

## Usage instructions

```matlab
m = core.types.ZefSourceModel.from(zef.source_model);  % enum, 1–6, or "1"–"6"
zef.source_model = core.types.ZefSourceModel.Whitney;
core.types.ZefSourceModel.to_string(m);   % e.g. "H(div)"
```

## Important notes

Keep the root-level `core.ZefSourceModel` enumeration so MATLAB can load older projects; do not remove or rename members without a migration path.

## Developer guidance

Do not add unrelated types to this folder. When adding a source model, update both the enumeration and the lead-field branch that consumes it; keep legacy numeric codes documented in this README.
