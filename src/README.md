# `src/` — procedural Zeffiro runtime

MATLAB that runs when you start the application: GUI windows, the `zef` session, mesh and lead-field pipelines, file I/O, and inverse orchestration. `zeffiro_interface` does `addpath(genpath(src))`, so these files are called as `zef_create_fem_mesh`, not package-qualified names.

Algorithm **classes** for newer inverse solvers live in `+inverse`. `src/inverse` only packs bundles, filters data, and dispatches. `src/app` is not the `+core` package.

## Main contents

| Folder | Role |
|--------|------|
| `app/` | Start, close, waitbars, logging, `zef_update` |
| `gui/` | Menus, tools, callbacks, chrome, 3-D plot |
| `mesh/` | Surfaces → tetrahedra, stiffness operators, Create FEM wrapper |
| `forward/` | EEG/MEG/EIT/TES/gravity lead fields, DTI, NSE, wave, PCG |
| `inverse/` | `zef_inverse_run`, priors, lead-field prep, reconstruction post-process |
| `io/` | `zef_load` / `zef_save`, segmentation import/export, `zef_inv_import` |
| `compartments/` | Point-in-tissue tests used while labeling a mesh |
| `sensors/` | Attach electrodes/MEG coils to the volume |
| `parcellation/` | Atlas ROIs on the source space |
| `visualization/` | Colormaps, movies, graph_bank, time_series_tools |
| `sensitivity/` | `zef_sensitivity_run` |

## Code functionality

The same functions the buttons call are the scripting API. `zef_update` (`src/app`) copies GUI tables into `zef` fields after a user edit.

Two inverse tracks share `zef.L` and measurements but are not the same code path:

- **Menus (legacy Inverse tools):** most `plugins/*` run `*_iteration` into `zef.reconstruction`.
- **Menus (class solver):** eLORETA, UKF-NMM, HALpR, Group Lasso call `zef_inverse_run` from `zef_open_class_inverse`.
- **`zef_inverse_run`:** `src/inverse` → `utilities.cluster.dispatch_inverse` → `+inverse/@*Inverter`.

With the project root on the path, this tree also calls `core.types.ZefSourceModel`, `core.io.electrodes.*`, `inverse.*Inverter` via `zef_inverse_run`, and `utilities.cluster.*` / converters. `src/app` ≠ `+core`.

## Workflow context

```
zeffiro_interface
  → src/app/zef_start
       opens src/gui/tools (segmentation, figure, mesh, menu)
  → you import anatomy and sensors
  → src/mesh builds tetrahedra
  → src/forward builds zef.L
  → src/inverse or plugins writes zef.reconstruction
  → src/gui/plot draws it
```

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode','nodisplay');

% Mesh (same as Mesh tool → Create FEM mesh)
zef = zef_create_finite_element_mesh(zef);

% Lead field (or Mesh tool → Run script / zef_eeg_make_all)
zef = zef_lead_field_matrix(zef);

% Class inverse (also Inverse tools → eLORETA / UKF-NMM / HALpR / Group Lasso (class solver))
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');

zef = zef_save(zef, 'my_project.mat');
```

GUI paths are documented in child READMEs from the actual `MenuSelectedFcn` / `ButtonPushedFcn` wiring. Do not assume a menu name from an older screenshot; App Designer exports under `src/gui/apps/` are the label source of truth.

## Important notes

- Startup: repository [README.md](../README.md). Field dictionary: [docs/zef-state.md](../docs/zef-state.md). Units: [docs/conventions.md](../docs/conventions.md).
- Two inverse tracks: [`inverse/README.md`](inverse/README.md) and [`../+inverse/README.md`](../+inverse/README.md).
- Worked scripts: [`../+examples/`](../+examples/README.md).

## Developer guidance

Open the child README for the subsystem you are changing. Prefer calling the same functions the GUI buttons call rather than poking `h_*` handles. Keep package APIs (`+core`, `+inverse`, `+utilities`) distinct from this flat `src/` path tree.
