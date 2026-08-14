# `src` — Zeffiro runtime

This folder is the procedural MATLAB that runs when you start Zeffiro: GUI windows, the `zef` session, mesh and lead-field pipelines, file I/O, and inverse *orchestration*. Algorithm classes for the newer inverse solvers live in `+inverse` at the project root; `src/inverse` is the bridge that feeds them `zef`.

`zeffiro_interface` does `addpath(genpath(src))`, so these files are called as `zef_create_fem_mesh`, not `src.mesh.zef_create_fem_mesh`.

## How a session uses this tree

```
zeffiro_interface
  → src/core/zef_start
       opens src/gui/tools (segmentation, figure, mesh, menu)
  → you import anatomy and sensors
  → src/mesh builds tetrahedra
  → src/forward builds zef.L
  → src/inverse or tools/plugins writes zef.reconstruction
  → src/gui/plot draws it
```

`zef_update` (`src/core`) is the hub that copies GUI tables into `zef` fields after a user edit.

## Subfolders (what to open, not a file inventory)

| Folder | Open this README when you need to… |
|--------|--------------------------------------|
| `core/` | Start, close, waitbars, logging, `zef_update` |
| `gui/` | Menus, tools, callbacks, 3D plot |
| `mesh/` | Surfaces → tetrahedra, stiffness operators |
| `forward/` | EEG/MEG/EIT/TES/gravity lead fields, DTI, NSE |
| `inverse/` | `zef_inverse_run`, lead-field prep, reconstruction post-process |
| `io/` | `zef_load` / `zef_save`, segmentation import/export |
| `compartments/` | Point-in-tissue tests used while labeling a mesh |
| `sensors/` | Attach electrodes/MEG coils to the volume |
| `parcellation/` | Atlas ROIs on the source space |
| `visualization/` | Time-series helpers used by the figure tool |
| `auxiliary/` | Distances, MRI helpers, one-off analysis |
| `sensitivity/` | `zef_sensitivity_run` |
| `nodisplay/` | Extra path in `'start_mode','nodisplay'` |

## GUI vs scripting

The same functions the buttons call are the scripting API. Examples:

```matlab
zef = zeffiro_interface('start_mode','nodisplay');

% Mesh (same as Mesh tool → Create FEM mesh)
zef = zef_create_finite_element_mesh(zef);

% Lead field (or use Mesh tool → Run script / zef_eeg_make_all)
zef = zef_lead_field_matrix(zef);

% Class inverse (not the Inverse-tools plugin buttons)
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');

zef = zef_save(zef, 'my_project.mat');
```

GUI paths are documented in the child READMEs from the actual `MenuSelectedFcn` / `ButtonPushedFcn` wiring. Do not assume a menu name from an older screenshot; the App Designer export under `src/gui/apps/` is the label source of truth.

## Two inverse tracks

- **Menus (Inverse tools):** `tools/plugins/*` still run legacy iterations into `zef.reconstruction`.
- **`zef_inverse_run`:** `src/inverse` → `utilities.cluster.dispatch_inverse` → `+inverse/@*Inverter`.

They share `zef.L` and measurements but are not the same code path. See `src/inverse/README.md` and `+inverse/README.md`.

## Packages this tree calls

With the project root on the path:

- `core.types.ZefSourceModel` — Whitney / H(div) / St. Venant in lead-field assembly
- `core.io.electrodes.*` and `core.gui.menu_tool.import_electrodes_callback`
- `inverse.*Inverter` via `zef_inverse_run`
- `utilities.cluster.*`, `utilities.sn2zef`, `utilities.brainstorm2zef`, …

`src/core` ≠ `+core`.

## See also

Root [README.md](../README.md) for startup and the `zef` field map. `+examples/` for end-to-end scripts.
