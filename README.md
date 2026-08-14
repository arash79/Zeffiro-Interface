# Zeffiro Interface

Zeffiro is a MATLAB application for finite-element modeling of the human head and for solving EEG, MEG, EIT, and TES forward and inverse problems. You import tissue surfaces, build a tetrahedral mesh, compute a lead field (the linear map from sources in the brain to sensors), then reconstruct neural activity or related fields from measurements.

This repository is a working tree of that application. The GUI and most `zef_*` functions live under `src/`. Refactored MATLAB packages (`+core`, `+inverse`, `+utilities`, …) sit at the project root. Session state is a single struct named `zef`, usually in the MATLAB base workspace.

If you have never opened this codebase, start here, then follow the folder READMEs for the stage you care about (mesh, lead field, inverse, GUI, plugins).

## What you need

- MATLAB with a release that supports `arguments` blocks and App Designer `uifigure` windows (R2021a or newer is the practical floor).
- Optional: Parallel Computing Toolbox (mesh labeling and PCG), a CUDA GPU (`zef.use_gpu`), Statistics and Optimization toolboxes (some inverse plugins).
- Git, if you want optional third-party trees under `external/` via `zeffiro_setup`.

You do **not** add `+core` or `+inverse` to the path yourself. Call `zeffiro_interface` from the project root; it adds the root (so `core.*` and `inverse.*` resolve) and `genpath(src)`.

## First launch

From the repository root in MATLAB:

```matlab
zef = zeffiro_interface;
```

That:

1. Adds `src/`, plugin folders, `profile/`, and `assets/` to the path.
2. Runs `zeffiro_setup` unless you skip submodules, which writes `src/core/zef_start_config.m`.
3. Calls `zef_start`, which opens the segmentation, figure, mesh, mesh-visualization, and menu tools.
4. Tries to load `data/default_project.mat` if that file exists. Fresh clones often do not include it; that is expected.

Batch / headless:

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', fullfile(pwd, 'data', 'segmentations', ...
    'multicompartment_head_project', 'import_segmentation.zef'));
```

`start_mode` is `"display"`, `"nodisplay"`, or `"default"`. Hidden windows may still be created in nodisplay. See `help zeffiro_interface` for every name-value argument (`open_project`, `save_project`, `run_script`, GPU flags, and so on).

If MATLAB reports that `zef` already exists in the base workspace, either `zef_close_all` or pass `'zeffiro_restart', true`.

## The `zef` struct

Almost every function reads and writes fields of `zef`. GUI widgets are stored as `zef.h_*`. Tissue compartments are not a nested object: each compartment has a short tag (for example `d1`) and a family of fields `d1_on`, `d1_points`, `d1_triangles`, `d1_sigma`, `d1_sources`, …

Important groups:

| Field | Meaning |
|-------|---------|
| `nodes`, `tetra`, `domain_labels` | Volume FEM mesh after **Create FEM mesh** |
| `reuna_p`, `reuna_t` | Active compartment surfaces after `zef_process_meshes` |
| `sensors`, `s_points`, `s_name_list` | Electrode / sensor geometry |
| `L` | Lead field (sensors × source columns) |
| `reconstruction` | Inverse result |
| `compartment_tags` | Cellstr of tags used to build the dynamic fields |

`zef_update` copies table and widget values into these fields and refreshes window titles. After a scripted change that should appear in the GUI, call it.

`src/core` (lifecycle: start, update, close) is **not** the same as the `+core` package (types, electrode parsers, preconditioners).

## Typical workflow

```mermaid
flowchart LR
  IMP[Import segmentation] --> SURF[Compartment surfaces]
  SURF --> MESH[Create FEM mesh]
  MESH --> LF[Lead field]
  LF --> INV[Inverse]
  INV --> VIZ[Figure tool]
```

1. **Anatomy.** Import tissue surfaces (**Import → Import data to a new project**, or a `.zef` file via `import_to_new_project`). The segmentation tool lists compartments: on/off, conductivity, whether they contain sources, priority.
2. **Sensors.** **Import → Import electrodes** reads `.dat` or `.csv` into `zef.sensors`. Formats are documented in `+core/+io/+electrodes/README.md`.
3. **Volume mesh.** In the Mesh tool (**ZEFFIRO Interface: Mesh tool**), set **Mesh resolution**, optionally **Resample surf.**, then **Create FEM mesh**. That runs `zef_create_finite_element_mesh`: downsample → `zef_process_meshes` → `zef_create_fem_mesh` → `zef_postprocess_fem_mesh`. Details: `src/mesh/README.md`.
4. **Lead field.** Same window: pick a row in the forward-simulation table (from `profile/<name>/zeffiro_forward_simulation.ini`) and **Run script**, or call `zef_eeg_make_all` / `zef_lead_field_matrix` from MATLAB. Result: `zef.L`. Details: `src/forward/README.md`.
5. **Inverse.** Two tracks, see below.
6. **Visualize.** Figure tool and mesh-visualization tool plot surfaces, volume, reconstruction, and time series.

Worked scripts live under `+examples/` (`+meshing`, `+forward`, `+inverse`). Tests: `runtests('+tests')`.

## Inverse: GUI plugins vs class solvers

The menus under **Inverse tools** launch packages in `tools/plugins/` (MNETool, Kalman, IAS, RAMUS, SESAME, …). Those still call legacy `*_iteration` functions and write `zef.reconstruction`. That is what a GUI user gets today.

The refactored solvers are MATLAB classes under `+inverse/@*Inverter`. You run them with:

```matlab
[zef, run_result] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');
% other registry ids: mne, wmne, kalman, ias, ramus, beamformer, ...
```

`zef_inverse_run` goes through `utilities.cluster.dispatch_inverse`. Most inverse menu buttons are **not** wired to these classes yet. If you add a solver, put the algorithm in `+inverse` and register it; do not add another per-frame loop inside a plugin. See `+inverse/README.md` and `src/inverse/README.md`.

## GUI map

`zef_start` opens these windows (titles from the App Designer exports):

| Window | Role |
|--------|------|
| Segmentation tool | Compartments, sensors, affine transforms |
| Figure tool | Main 3D view |
| Mesh tool | Volume mesh, surface resampling, forward-simulation table |
| Mesh visualization tool | What is drawn (compartments, mesh, reconstruction) |
| Menu bar | Project / Import / Export / Edit / Inverse tools / Forward tools / … |

Plugins attach extra items to Inverse tools, Forward tools, and Multi tools from `profile/<profile>/zeffiro_plugins.ini`. The default profile is `multicompartment_head` (`profile/zeffiro_interface.ini`).

## Where the code lives

| Path | What to read it for |
|------|---------------------|
| `zeffiro_interface.m` | Startup, CLI arguments |
| `src/` | Procedural `zef_*` runtime: GUI, mesh, forward, I/O |
| `src/mesh/` | Surfaces → tetrahedra |
| `src/forward/` | Lead fields, DTI, NSE, wave |
| `src/inverse/` | Orchestration around `zef_inverse_run` |
| `src/gui/` | Tools, callbacks, plotting |
| `+core/` | `ZefSourceModel`, electrode I/O, menu callback |
| `+inverse/` | Class inverters |
| `+utilities/` | Cluster dispatch, Brainstorm/FreeSurfer/SimNIBS converters |
| `tools/plugins/` | GUI inverse and utility plugins |
| `profile/` | INI files that define menus and default parameters |
| `data/` | Example segmentations and electrodes |
| `+examples/`, `+tests/` | Scripts and unit tests |
| `external/` | Optional git submodules; not first-party documentation |

Parent READMEs give the workflow; child READMEs go into the implementation. Do not expect every directory to repeat the same startup story.

## Developer notes

- Do not `addpath` a `+package` folder. Add the project root.
- GUI callbacks should assign `zef` and call `zef_update` when tables change.
- `src/core/zef_start_config.m` is generated by `zeffiro_setup`; do not hand-edit it as source of truth.
- Third-party copies (FreeSurfer readers, SimNIBS `meshLoadGmsh4`, MathWorks GMM helpers) keep their original licenses; do not re-attribute them.
- MATLAB `help` for a file is the comment block immediately after `function` / `classdef` (or at the top of a script).
