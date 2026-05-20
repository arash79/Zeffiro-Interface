# external/spm12

## Purpose of this folder

This folder is responsible for placeholder folders for optional external solver/toolbox submodules within the Zeffiro Interface project.

## Contents

This folder currently contains no tracked source or asset files. It is kept as a placeholder for runtime or optional dependency content.

## How this folder fits into the overall workflow

Zeffiro Interface starts in `zeffiro_interface.m`, adds the project runtime paths, and then calls into folders like this one as the GUI, examples, plugins, or numerical routines require placeholder folders for optional external solver/toolbox submodules.

## GUI usage

There is no direct GUI entry point here; these folders are dependency locations populated by setup when optional submodules are installed.

## Programmatic usage

From MATLAB, start from the project root and initialize paths with either `zeffiro_interface` or `addpath(genpath(projectRoot))` when you only need utility functions.

This folder has no directly callable MATLAB source files. Use the files here through the surrounding GUI, data import, profile, or documentation workflow.

## Examples

GUI example: use the surrounding Zeffiro workflow that references this folder's assets or configuration files.

MATLAB example: load or inspect these files with standard MATLAB I/O functions such as `load`, `readmatrix`, or `fileread` when appropriate.

## Dependencies and assumptions

- The Zeffiro project root should be available on the MATLAB path before calling source files directly.
- Many routines assume a populated `zef` struct created by `zeffiro_interface` and updated by GUI callbacks.
- Optional dependency folders may be empty until `zeffiro_setup` initializes the configured submodules.

## Notes for developers

- Keep documentation synchronized with behavior when adding or moving files; this repository now expects every folder to have a current `README.md`.
- Preserve numerical algorithms, GUI callback contracts, and `zef` field names unless a coordinated migration updates all callers.
- Prefer package-qualified functions in `+...` folders and avoid adding package directories themselves directly to the MATLAB path.
- Treat `.fig`, `.mlapp`, `.mat`, and sample data files as part of the public workflow: document required fields and formats when they change.
