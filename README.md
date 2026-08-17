# Zeffiro Interface

## Folder purpose

Repository root for Zeffiro, a MATLAB application for finite-element modeling of the human head and for solving EEG, MEG, EIT, and TES forward and inverse problems. You import tissue surfaces, build a tetrahedral mesh, compute a lead field (sources → sensors), then reconstruct neural activity or related fields from measurements. Session state is a single struct named `zef`, usually in the MATLAB base workspace.

## Main contents

| Path | Role |
|------|------|
| `zeffiro_interface.m` | Startup and CLI name-value arguments |
| `zeffiro_setup.m` | First-time path / toolbox / `zef_start_config` setup |
| `zeffiro_downloader.m` | Fresh-install helper: shallow-clone repo, set profile INI, optional setup |
| `src/` | Procedural `zef_*` runtime: GUI, mesh, forward, I/O |
| `+core/`, `+inverse/`, `+utilities/`, `+plugins/` | Refactored MATLAB packages (call as `core.*`, `inverse.*`, …) |
| `tools/plugins/` | GUI Inverse / Forward / Multi tools plugins |
| `profile/` | INI files for menus and default parameters |
| `data/`, `assets/`, `documentation/` | Example data, GUI assets, typeset manual |
| `+examples/`, `+tests/` | Scripts and unit tests |
| `external/` | Optional git submodules |
| `scripts/` | Maintainer utilities (STL QA, contributing notes) — not on runtime path |

### Root lab / batch scripts (not product entry points)

| File | Role |
|------|------|
| `kalman_primer.m` | Synthesize two-dipole Blackman–Harris measurements on live `zef.L` → `zef.measurements` |
| `kalman_custom_q_driver.m` | Lab Kalman batch: load project + **precomputed Q `.mat`** from disk; runs KF/sLORETA/W **without** relying on `zef_KF`’s diagonal Q |
| `compute_Q.m` | Build process-noise `Q` (diagonal or DTI FA/tractography) from live `zef`; no invert |
| `compartment_wise.m` | Lab batch: ICBM152 projects → parcellation CSVs from sensitivity stats |
| `run_eloreta_shalpr_snr_sweep.m` | Lab SNR sweep: sLORETA / Dipole Scan / eLORETA / SHALpR via `zef_run_inverse_pipeline` |
| `check.m` | Micro-benchmark (`rand` GEMM `timeit`) — no Zeffiro API |

These scripts often use **hard-coded absolute paths** and project filenames from a lab machine; edit before running on a clean clone.

`src/core` (lifecycle: start, update, close) is not the same as the `+core` package.

## Code functionality

`zeffiro_interface` adds the project root (so packages resolve), `genpath(src)`, plugin folders, `profile/`, and `assets/` to the path; runs `zeffiro_setup` unless skipped; calls `zef_start` (opens segmentation, figure, mesh, mesh-visualization, and menu tools); and may load `data/default_project.mat` if present.

Almost every function reads and writes fields of `zef`. GUI widgets are `zef.h_*`. Compartments use short tags (e.g. `d1`) and fields such as `d1_on`, `d1_points`, `d1_sigma`. Key fields after meshing / forward / inverse: `nodes`, `tetra`, `domain_labels`, `reuna_p` / `reuna_t`, `sensors` / `s_points` / `s_name_list`, `L`, `reconstruction`, `compartment_tags`. `zef_update` copies table and widget values into these fields.

## Workflow context

```mermaid
flowchart LR
  IMP[Import segmentation] --> SURF[Compartment surfaces]
  SURF --> MESH[Create FEM mesh]
  MESH --> LF[Lead field]
  LF --> INV[Inverse]
  INV --> VIZ[Figure tool]
```

1. Import anatomy (`.zef` or Import menu). 2. Import electrodes. 3. Mesh tool → **Create FEM mesh**. 4. Forward-simulation table **Run script** (or `zef_eeg_make_all` / `zef_lead_field_matrix`) → `zef.L`. 5. Inverse via GUI plugins (`tools/plugins`) or `zef_inverse_run` / `+inverse` classes. 6. Visualize in Figure / mesh-visualization tools.

Menus under **Inverse tools** still call legacy plugin iterations. Class solvers:

```matlab
[zef, run_result] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');
```

Default profile is `multicompartment_head` (`profile/zeffiro_interface.ini`).

## Usage instructions

Needs MATLAB with `arguments` blocks and App Designer `uifigure` (R2021a+ practical floor). Optional: Parallel Computing Toolbox, CUDA (`zef.use_gpu`), Statistics / Optimization toolboxes.

```matlab
zef = zeffiro_interface;
```

Batch / headless:

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', fullfile(pwd, 'data', 'segmentations', ...
    'multicompartment_head_project', 'import_segmentation.zef'));
```

`start_mode` is `"display"`, `"nodisplay"`, or `"default"`. See `help zeffiro_interface` for all arguments. If `zef` already exists in the base workspace, use `zef_close_all` or `'zeffiro_restart', true`.

Do not add `+core` or `+inverse` to the path yourself—call `zeffiro_interface` from the project root.

## Important notes

- Fresh clones often lack `data/default_project.mat`; that is expected.
- Hidden windows may still be created in nodisplay mode.
- Root lab scripts (`kalman_custom_q_driver.m`, `kalman_primer.m`, `compute_Q.m`, …) use machine-local paths — edit before running.
- Electrode formats: `+core/+io/+electrodes/README.md`. Mesh details: `src/mesh/README.md`. Lead fields: `src/forward/lead_field/README.md`. Inverse: `+inverse/README.md`, `src/inverse/README.md`.
- Worked scripts: `+examples/`. Tests: `runtests('+tests')`.
- Folder-level `README.md` files throughout the tree are the maintainer map; start at this root file, then open the README in the subsystem you need.

## Developer guidance

- Do not `addpath` a `+package` folder; add the project root.
- GUI callbacks should assign `zef` and call `zef_update` when tables change.
- `src/core/zef_start_config.m` is generated by `zeffiro_setup`; do not hand-edit it as source of truth.
- Third-party copies keep original licenses; do not re-attribute them.
- MATLAB `help` for a file is the comment block immediately after `function` / `classdef` (or at the top of a script).
- Parent READMEs give workflow; child READMEs go into implementation.
