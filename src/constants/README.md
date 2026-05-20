# src/constants

## Folder purpose

**Reserved namespace** for shared numerical constants (FEM stencils, default tolerances, UI constants). Currently contains **no `.m` source files** — defaults live in `profile/zeffiro_interface.ini`, `profile/*/zeffiro_parameters.ini`, and `src/core/zef_init.m`.

## Main contents

- `README.md` only (this file)

## Code functionality

No runtime code. `zef_init` and profile loaders set defaults on `zef` at startup. Future constants may be centralized here to avoid magic numbers in mesh/forward code.

## Workflow context

Referenced conceptually by mesh and forward documentation; actual values come from profile INIs when users apply parameter profiles.

## Usage instructions

N/A until `.m` constant files are added.

## Important notes

- Do not confuse with `src/core/zef_start_config.m` (warning toggles + external paths).
- Stencil documentation may appear in `documentation/mesh_generation.tex`.

## Developer guidance

- When extracting magic numbers from `zef_create_fem_mesh` or barycentric operators, add named constants here and document units.
- Keep profile INI as user-overridable layer; use this folder for non-user constants only.
