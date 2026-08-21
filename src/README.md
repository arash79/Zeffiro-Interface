# src
## Folder purpose

Procedural MATLAB that runs when you start Zeffiro: GUI windows, the `zef` session, mesh and lead-field pipelines, file I/O, and inverse orchestration. Algorithm classes for newer inverse solvers live in `+inverse` at the project root; `src/inverse` bridges them to `zef`. `zeffiro_interface` does `addpath(genpath(src))`, so these files are called as `zef_create_fem_mesh`, not package-qualified names.

## Main contents

| Folder | Role |
|--------|------|
| `core/` | Start, close, waitbars, logging, `zef_update` |
| `gui/` | Menus, tools, callbacks, 3-D plot |
| `mesh/` | Surfaces → tetrahedra, stiffness operators |
| `forward/` | EEG/MEG/EIT/TES/gravity lead fields, DTI, NSE, wave |
| `inverse/` | `zef_inverse_run`, lead-field prep, reconstruction post-process |
| `io/` | `zef_load` / `zef_save`, segmentation import/export |
| `compartments/` | Point-in-tissue tests used while labeling a mesh |
| `sensors/` | Attach electrodes/MEG coils to the volume |
| `parcellation/` | Atlas ROIs on the source space |
| `visualization/` | Time-series helpers used by the figure tool |
| `auxiliary/` | Distances, MRI helpers, one-off analysis |
| `sensitivity/` | `zef_sensitivity_run` |
| `nodisplay/` | Extra path in `'start_mode','nodisplay'` |

## Code functionality

The same functions the buttons call are the scripting API. `zef_update` (`src/core`) copies GUI tables into `zef` fields after a user edit.

Two inverse tracks share `zef.L` and measurements but are not the same code path:

- **Menus (Inverse tools):** `tools/plugins/*` run legacy iterations into `zef.reconstruction`.
- **`zef_inverse_run`:** `src/inverse` → `utilities.cluster.dispatch_inverse` → `+inverse/@*Inverter`.

With the project root on the path, this tree also calls `core.types.ZefSourceModel`, `core.io.electrodes.*`, `inverse.*Inverter` via `zef_inverse_run`, and `utilities.cluster.*` / converters. `src/core` ≠ `+core`.

## Workflow context

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

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode','nodisplay');

% Mesh (same as Mesh tool → Create FEM mesh)
zef = zef_create_finite_element_mesh(zef);

% Lead field (or Mesh tool → Run script / zef_eeg_make_all)
zef = zef_lead_field_matrix(zef);

% Class inverse (not the Inverse-tools plugin buttons)
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');

zef = zef_save(zef, 'my_project.mat');
```

GUI paths are documented in child READMEs from the actual `MenuSelectedFcn` / `ButtonPushedFcn` wiring. Do not assume a menu name from an older screenshot; App Designer exports under `src/gui/apps/` are the label source of truth.

## Important notes

- Root [README.md](../README.md) covers startup and the `zef` field map; `+examples/` has end-to-end scripts.
- See `src/inverse/README.md` and `+inverse/README.md` for the two inverse tracks.

## Developer guidance

Open the child README for the subsystem you are changing. Prefer calling the same functions the GUI buttons call rather than poking `h_*` handles. Keep package APIs (`+core`, `+inverse`, `+utilities`) distinct from this flat `src/` path tree.
