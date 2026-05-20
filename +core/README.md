# +core

## Purpose of this folder

Refactored MATLAB **package** at the project root (not `src/core/`). Provides typed source models, electrode file parsers, one GUI menu callback, and standalone preconditioner builders. Available when `zeffiro_interface` executes `addpath(projectRoot)`.

## Contents

| Path | Symbols | Role |
|------|---------|------|
| `+types/ZefSourceModel.m` | `core.types.ZefSourceModel` | Enum: Whitney, H(div), St. Venant (+ continuous variants); `from`, `variants`, `to_string`, `loadobj` |
| `ZefSourceModel.m` | `core.ZefSourceModel` | **Compatibility shim** for old `.mat` saves → delegates to `core.types` |
| `+io/+electrodes/from_csv.m` | `core.io.electrodes.from_csv` | CSV electrodes (+ optional CEM columns) |
| `+io/+electrodes/from_dat.m` | `core.io.electrodes.from_dat` | Whitespace `.dat` electrodes |
| `+gui/+menu_tool/import_electrodes_callback.m` | `core.gui.menu_tool.import_electrodes_callback` | File picker → parsers → `zef.sensors` / `s*_points` → `zef_update` |
| `+linalg/+preconditioners/jacobi.m` | `core.linalg.preconditioners.jacobi` | Jacobi preconditioner matrix |
| `+linalg/+preconditioners/ssor.m` | `core.linalg.preconditioners.ssor` | SSOR preconditioner matrix |

## How this folder fits into the overall workflow

- **Forward:** `src/forward/lead_field/*` branches on `core.types.ZefSourceModel.from(zef.source_model)` when assembling `zef.L`.
- **GUI:** `zef_init_options` / `zef_update_forward_and_inverse_options` bind `zef.h_source_model` to enum variants.
- **Import:** Edit menu calls `import_electrodes_callback` instead of legacy import helpers.
- **Preconditioners:** implemented here but lead-field PCG in `src/forward` still uses inline SSOR/`ichol` until wired.

## GUI usage

- **Edit → Import electrodes** → `core.gui.menu_tool.import_electrodes_callback(zef)` (see `src/gui/tools/zef_menu_tool.m`).
- **Forward & inverse options** → source model dropdown synced via `core.types.ZefSourceModel`.

## Programmatic usage

```matlab
addpath(fileparts(which('zeffiro_interface')));  % exposes core.*

% Source model
model = core.types.ZefSourceModel.from(2);   % Hdiv
allModels = core.types.ZefSourceModel.variants();

% Electrodes (no zef)
[pos, labels] = core.io.electrodes.from_csv("electrodes.csv");

% With existing zef (opens uigetfile)
zef = core.gui.menu_tool.import_electrodes_callback(zef);

% Preconditioner (sparse A)
prec = core.linalg.preconditioners.ssor(A, "coeff", 1);
```

## Examples

```matlab
% After zeffiro_interface
zef.source_model = core.types.ZefSourceModel.Whitney;
zef = zef_update(zef);

% See +examples/+forward/lead_field_example.m for typed lead-field usage
```

## Dependencies and assumptions

- Project root on path (package folder `+core` must not be `addpath`'d directly).
- `import_electrodes_callback` requires `zef_update` from `src/core`.
- Electrode parsers: MATLAB `readtable` / `readlines`; CSV needs `x,y,z` columns; DAT allows 3/4/6/7 columns per line.
- `zef.current_sensors` sets prefix for `s_points` / `s2_points` style fields.

## Notes for developers

- Add new **types** under `+types`, new **file I/O** under `+io`, new **menu hooks** under `+gui/+menu_tool`.
- Keep `core.ZefSourceModel` shim if enum location changes again.
- Wire `core.linalg.preconditioners` into `zef.lf_param.precond` paths in `src/forward` when replacing duplicated SSOR code.
