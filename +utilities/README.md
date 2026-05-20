# Utilities

This folder contains supporting code that is not part of Zeffiro Interface’s core: **data import** from external tools (Brainstorm, DUNEuro, FreeSurfer, SimNIBS), **cluster computing** helpers for HPC (e.g. CSC Puhti), and **general-purpose utilities** for paths, structs, figures, EDF import, and development (indentation, linting). Everything here is optional; the main application runs without it.

---

## Table of Contents

1. [Overview](#overview)
2. [Subfolders (packages)](#subfolders-packages)
3. [Top-level utility functions](#top-level-utility-functions)
4. [Quick reference](#quick-reference)

---

## Overview

| Category | Purpose |
|----------|---------|
| **Data import** | Convert meshes, segmentations, sensors, and lead fields from Brainstorm, DUNEuro, FreeSurfer, or SimNIBS into Zeffiro Interface–compatible formats and import scripts. |
| **Cluster** | Configure and run MATLAB batch jobs on the CSC Puhti supercomputer (cluster profile, job creation, example workflow). |
| **General** | Path resolution, struct field copying, figure/colorbar export, EDF loading, lead-field tags, git submodule parsing, and development tools (M-file indentation, linting). |

Each subfolder is a MATLAB package (e.g. `utilities.brainstorm2zef`). Call its entry points from the command line or from scripts; some are also used internally by Zeffiro (e.g. `copy_fields`, `read_gitmodules`, and fs2zef’s use of `float_is_int` and `is_eof`).

**Evaluation notice:** The packages **`+cluster`**, **`+brainstorm2zef`**, and **`+duneuro2zef`** are still under evaluation. They may contain bugs that need to be fixed; feedback and issue reports are welcome.

---

## Subfolders (packages)

### `+brainstorm2zef` — Brainstorm → Zeffiro Interface

Converts [Brainstorm](https://neuroimage.usc.edu/brainstorm/) surface meshes and anatomical data into Zeffiro finite element meshes. Supports automatic compartment detection, atlas (Cube) surfaces, configurable settings, and both GUI and programmatic use.

- **Entry points**
  - **`run(config)`** — Full pipeline: validate environment → load settings → create project → generate mesh → optional save. Returns a results struct. Recommended for scripts and automation.
  - **`zef_bst_plugin_start(pwd)`** — Opens the GUI to choose settings, run script, and run type (fresh start, import compartments, or use project).
  - **`zef_bst_default_fem_mesh_create`** — Run script used by the GUI; can be called directly for backward compatibility.
- **Requirements:** Brainstorm and Zeffiro Interface installed and configured; MATLAB with Java (for GUI).
- **Details:** See `+brainstorm2zef/README.md` for installation, settings, pipeline steps, and examples.

---

### `+cluster` — HPC batch jobs (CSC Puhti)

Utilities for running MATLAB batch jobs on the **CSC Puhti** cluster: profile configuration, job creation, and an example workflow. Uses the MATLAB Parallel Computing Toolbox and CSC’s MATLAB configuration (e.g. `configCluster`).

- **Entry points / main files**
  - **`configure_cluster_profile(account_name, ...)`** — Creates/saves a cluster profile (account, memory, walltime, queue, etc.).
  - **`create_batch_job(cluster, job_fn, pool_size, job_args, ...)`** — Submits a batch job with optional `CurrentFolder`, `AutoAddClientPath`, etc.
  - **`run_cluster_job_example(project_path, output_name, script_cmd)`** — Example job function: load project, run a script (e.g. inverse), save results.
  - **`example_workflow.m`** — End-to-end example: configure profile, create jobs, monitor, fetch outputs.
- **Requirements:** CSC account and Puhti access; Parallel Computing Toolbox; CSC MATLAB tool scripts installed and `configCluster` run once.
- **Details:** See `+cluster/README.md` for prerequisites, queues, and usage.

---

### `+duneuro2zef` — DUNEuro → Zeffiro Interface

Imports [Duneuro](https://www.duneuro.org/) FEM meshes and associated data (EEG/MEG sensors, lead fields, measurements) into Zeffiro Interface. Converts hex meshes to tetrahedral, processes source space and optional resection points, and can run as a single programmatic pipeline or via Zeffiro’s import menu and a `.zef` import file.

- **Entry points**
  - **`import_duneuro_project(config)`** — **Recommended.** Runs conversion, then import via `Duneuro2Zeffiro_import.zef`, then configuration (handled by the `.zef` file). Returns a results struct.
  - **`run(config)`** — Conversion only: mesh, source space, sensors, lead fields, measurements (and optional resection points) from `config.input_folder` to `config.output_folder`.
  - **`Duneuro2Zeffiro_convert()`** — Entry point used by the `.zef` file (line 1); wraps `run()` and skips conversion if outputs already exist.
  - **`Duneuro2Zeffiro_settings`** — Post-import configuration (source modes, mesh processing, interpolation); invoked by the `.zef` file (line 19).
- **Config:** `get_default_config()` returns a config struct; paths, file names, and processing options (EEG/MEG, channels, domain labels) are customizable.
- **Details:** See `+duneuro2zef/README.md` for pipeline steps, `.zef` format, and troubleshooting.

---

### `+fs2zef` — FreeSurfer → Zeffiro Interface

Converts [FreeSurfer](https://www.freesurfer.org/) segmentation data (any `.mgz` in the subject’s `mri/` directory) into Zeffiro-compatible meshes (ASCII and/or STL) and import files. Fully file-driven: you specify which segmentations to process; the pipeline discovers labels and generates the ZEF import script.

- **Entry point**
  - **`run(subject_id, segmentation_files, output_dir, options)`** — Processes the given `.mgz` files (e.g. `"aseg.mgz"`, `["aseg.mgz", "ThalamicNuclei.mgz"]`), extracts meshes per label, optionally adds cortical/skull/skin surfaces, and writes `import_segmentation.zef` and electrodes into `output_dir/ascii/` and `output_dir/mesh/`.
- **Options:** `output_format` ('ascii' | 'stl' | 'both'), `merge_left_right`, `compute_transforms`, `include_surfaces`, `include_skull_skin`, `verbose`, etc.
- **Requirements:** FreeSurfer 7+ (e.g. 8.0); `FREESURFER_HOME` and `SUBJECTS_DIR` set; subject processed with `recon-all`.
- **Import in Zeffiro:** Use `zef_import_segmentation([], 'import_segmentation.zef', 'output_dir/mesh')` (or `.../ascii`), not `zef_import`.
- **Details:** See `+fs2zef/README.md` for API, output layout, and troubleshooting. Top-level utilities `float_is_int` and `is_eof` are used by fs2zef readers.

---

### `+sn2zef` — SimNIBS → Zeffiro Interface

Converts [SimNIBS](https://simnibs.github.io/simnibs/) data for use in Zeffiro Interface. Two workflows:

1. **Volume pipeline** — Segmentation volume (`final_tissues.nii.gz` + LUT) and a FreeSurfer subject → STL surfaces and a ZEF import script (with optional alignment: translation from headers or coregistration).
2. **Mesh pipeline** — Gmsh `.msh` file + tissue listing file → per-compartment STLs and full mesh export (MAT/HDF5).

- **Entry points**
  - **`run(zef, subject_id, outFolder, inflation_parameter, options)`** — Volume pipeline: reads SimNIBS subject in `m2m_<subject_id>`, uses FreeSurfer subject `<subject_id>`, writes STLs and `import_segmentations.zef` to `outFolder`. Options: `alignment_mode` ('translation' | 'coregistration'), `verbose`.
  - **`export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)`** — Mesh pipeline: loads `.msh`, optionally writes STLs, `wholemesh.mat`, and `wholemesh.hdf5` into a timestamped subfolder. Kwargs: `outputFolder`, `stlOutputFormat`, `subjectName`, etc.
- **Supporting:** `export_segmentation_meshes` (volume → STLs, used by `run`), `readSNLUT`, `meshLoadGmsh4`, `run_and_print_command`, `+transforms/compute_simnibs_to_freesurfer_translation`; `extract_SimNIBS_surfaces` for custom marching-cubes extraction.
- **Requirements:** `SIMNIBS_HOME`, `SUBJECTS_DIR`, `FREESURFER_HOME`; for volume pipeline, Brainstorm2Zef’s `zef_bst_get_atlas_surfaces` is used for surface extraction.
- **Details:** See `+sn2zef/README.md` for arguments, outputs, and file layout.

---

## Top-level utility functions

Functions in this directory (not in a subfolder) are called as `utilities.<name>` when used from outside the package (e.g. `utilities.copy_fields`). The following are **used elsewhere in the codebase**:

| Function | Purpose | Used by |
|----------|---------|---------|
| **`copy_fields(from, to, kwargs)`** | Copy all fields from one struct into another; optional `error_on_overwrite`. | `zeffiro_interface.m`, `+examples` scripts |
| **`float_is_int(float)`** | True if all elements are integer-valued (within floating-point precision). | `+fs2zef/+readers` (ASCII segmentation and label files) |
| **`is_eof(in)`** | True if `in` is the string `"-1"` (legacy file-read EOF). | `+fs2zef/+readers` (ASCII segmentation and label files) |
| **`read_gitmodules(gitmodules_file, kwargs)`** | Parse `.gitmodules` into an array of structs (path, abspath, name, url, branch, etc.). | `zeffiro_setup.m` |

The following are **not referenced by other application code**; they are intended for scripts, plotting, or development (command line or ad-hoc use):

| Function | Purpose |
|----------|---------|
| **`abspath(files)`** | Resolve file paths to absolute paths (string array). |
| **`box_plots_with_differing_whiskers_fn(...)`** | Create a figure with box plots whose upper whisker lengths are set per group via outlier limits. |
| **`colorbar_from_figtool_fn(figtool, filename, filetypes, kwargs)`** | Export the Zeffiro Figure tool colorbar as standalone image files (.png, .pdf, .eps). |
| **`copy_dependencies_to_folder(file, target_folder, kwargs)`** | Copy non–built-in dependencies of a file to a folder (via `requiredFilesAndProducts`); optional `folder_whitelist`. |
| **`figure_without_colorbar_fn(figtool, filename, filetypes, resolution)`** | Export a Zeffiro Figure tool figure with colorbars hidden. |
| **`figures_from_folder_without_colorbars(folder, filetypes, resolution)`** | Find all `.fig` under a folder, open each, hide colorbars, export to given formats (uses `figure_without_colorbar_fn`). |
| **`get_mfile_paths(folder)`** | List all `.m` file paths under a folder recursively. |
| **`indent_mfile(filename)`** | Smart-indent a single M-file (requires Java; opens in editor, indents, saves, closes). |
| **`indent_mfiles(folder)`** | Smart-indent all `.m` files under a folder (uses `get_mfile_paths` and `indent_mfile`). |
| **`lf_tag_from_lf_type(lf_type)`** | Map lead-field type code (1–5) to tag: 'EEG', 'MEG', 'gMEG', 'EIT', 'tES'. |
| **`lint_mfiles(folder, kwargs)`** | Run code analyzer on all `.m` files under a folder; throw if unacceptable message IDs or errors are found (kwargs: `UNACCEPTABLE_MESSAGES`, `linter_fn_name`). |
| **`reconstruction_from_edf_fn(path_to_file)`** | Read an EDF file into a reconstruction matrix (channel rows, time columns), sample rate, time step, and column titles for Zeffiro. |

---

## Quick reference

| Task | Where to look |
|------|----------------|
| Import from Brainstorm | `utilities.brainstorm2zef.run()` or GUI `utilities.brainstorm2zef.zef_bst_plugin_start(pwd)`; see `+brainstorm2zef/README.md`. |
| Import from DUNEuro | `utilities.duneuro2zef.import_duneuro_project()` or `run()`; see `+duneuro2zef/README.md`. |
| Import from FreeSurfer | `utilities.fs2zef.run(subject_id, segmentation_files, output_dir)`; then `zef_import_segmentation([], 'import_segmentation.zef', 'output_dir/mesh')`; see `+fs2zef/README.md`. |
| Import from SimNIBS (mesh) | `utilities.sn2zef.run(zef, subject_id, outFolder, inflation, options)`; see `+sn2zef/README.md`. |
| Import from SimNIBS (mesh) | `utilities.sn2zef.export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)`; see `+sn2zef/README.md`. |
| Run jobs on CSC Puhti | Configure profile with `utilities.cluster.configure_cluster_profile`, create jobs with `create_batch_job`, use `example_workflow.m`; see `+cluster/README.md`. |
| Copy struct fields | `utilities.copy_fields(from, to)`. |
| Parse .gitmodules | `utilities.read_gitmodules(gitmodules_file)`. |
| Load EDF for Zeffiro | `[reconstruction, sample_rate, time_step, column_title_vec] = utilities.reconstruction_from_edf_fn(path_to_file)`. |

For detailed options, examples, and troubleshooting, use each subfolder’s **README.md**.
