# src

## Purpose of this folder

Main **procedural runtime** for Zeffiro Interface (~557 `.m` files). Loaded with `addpath(genpath(zef.code_path))` from `zeffiro_interface.m`. Holds the `zef_*` API, GUI tools, FEM mesh pipeline, forward lead fields, inverse **orchestration**, I/O, and visualization. Algorithm cores for refactored inverses live in `+inverse`; this tree wires them to `zef`.

## Contents

| Subfolder | Files (approx.) | Responsibility |
|-----------|-----------------|---------------|
| `core/` | 16 | `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars |
| `gui/` | 249 | App Designer exports, tools, callbacks, `zef_update_*`, plotting |
| `mesh/` | 61 | FEM creation, refinement, barycentric operators, surface tools |
| `forward/` | 109 | Lead fields (`lead_field/`), DTI, NSE, wave models, PCG |
| `inverse/` | 14 | `zef_inverse_run`, bundles, filtering, post-process to `zef.reconstruction` |
| `io/` | 20 | `zef_load`/`zef_save`, segmentation import, export |
| `compartments/` | 8 | Compartment tables, point-in-compartment tests |
| `sensors/` | 6 | Sensor geometry and attachment |
| `parcellation/` | 11 | Atlas/ROI parcellation |
| `visualization/` | 27 | Time-series scaling, graph bank |
| `sensitivity/` | 1 | `zef_sensitivity_run` bridge |
| `auxiliary/` | 35 | Distance-to-mesh, MRI helpers, analysis scripts |
| `constants/` | 0 | Placeholder README (stencil constants documented only) |
| `nodisplay/` | 0 | Extra path in nodisplay mode (placeholder) |

## How this folder fits into the overall workflow

```
zeffiro_interface
  → addpath(genpath(src))
  → zef_start → zef_segmentation_tool, zef_mesh_tool, zef_menu_tool, …
  → zef_update  (sync GUI ↔ zef)
```

**Forward:** `src/forward/lead_field/zef_lead_field_matrix.m` dispatches on `core.types.ZefSourceModel` → fills `zef.L`.

**Inverse:** `src/inverse/zef_inverse_run.m` extracts bundle → `utilities.cluster.dispatch_inverse` → `+inverse` classes.

**Plugins:** `tools/plugins` on separate path; menus via `zef_plugin` + `profile/*/zeffiro_plugins.ini`.

## GUI usage

Startup chain (`zef_start.m`):

1. `zef_segmentation_tool` — compartments, sensors, transforms  
2. `zef_figure_tool` — 3D visualization  
3. `zef_mesh_tool` — FEM mesh and forward table  
4. `zef_menu_tool` — file/import/export/edit/tools/plugins  

Callbacks live in `gui/callbacks/`; state sync in `gui/update/`; central refresh `core/zef_update.m`.

## Programmatic usage

```matlab
zef = zeffiro_interface('start_mode','nodisplay');

% Mesh + lead field (simplified)
zef = zef_create_fem_mesh(zef);
zef = zef_process_meshes(zef);
zef = zef_lead_field_matrix(zef);

% Inverse orchestration
[zef, r] = zef_inverse_run(zef, 'mne');

% I/O
zef = zef_load(zef, projectFile);
zef = zef_save(zef, projectFile);
```

Key public APIs: see subfolder READMEs (`src/gui`, `src/forward`, `src/inverse`, …).

## Examples

- Bundled: `data/default_project.mat` via `zeffiro_interface('open_project', …)`  
- Package examples: `+examples/+meshing`, `+forward`, `+inverse`  
- Lead field: `+examples/+forward/lead_field_example.m`

## Dependencies and assumptions

- Entire tree on path via `genpath` (flat `zef_*` names).
- `zef` struct in base workspace with GUI handles `h_*` when in display mode.
- Calls into `core.*`, `inverse.*`, `utilities.*` require project root on path.
- GPU/parallel flags on `zef` affect forward and inverse paths.

## Notes for developers

- **Do not confuse** `src/core` with `+core` package at repo root.
- New GUI features: App Designer export in `gui/apps/`, wire in `gui/tools/`, callback in `gui/callbacks/`, sync in `gui/update/`.
- New inverse methods: implement in `+inverse`, register, call via `zef_inverse_run`—avoid new per-frame loops in `src/inverse` unless orchestration only.
- Subfolder `README.md` files document local `zef_*` entry points.
