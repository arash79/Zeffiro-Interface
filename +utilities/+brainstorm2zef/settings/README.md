## Folder purpose

Brainstorm converter default settings scripts. Loaded by name so `zef_bst_get_settings` / the GUI plugin can assign `zef_bst.*` fields before mesh conversion.

## Main contents

| File | Role |
|------|------|
| `zef_bst_default.m` | Factory settings script (not a function) |

## Code functionality

`zef_bst_get_settings('zef_bst_default')` runs `zef_bst_init` first, then this file in the caller workspace so it can assign `zef_bst.*`. `run` and the GUI plugin both load it that way.

Factory values: `mesh_resolution = 3`, `compartment_list` / `refine_surface` (Scalp, OuterSkull, InnerSkull, Cortex, Other, white, subcortical), `refine_surface_mode = 2`, `use_gpu = 1`, `parallel_processes = 10`, `surface_mesh_density = 0.25`, `inflation_on = 0`. Override individual fields with `config.zef_bst` on `run` (merged after the script).

## Workflow context

Used by `utilities.brainstorm2zef` before FEM mesh creation from a Brainstorm protocol. Parent: `../README.md`.

## Usage instructions

- **Programmatic:** `config.settings_file_name = 'zef_bst_default'` (basename, no `.m`). `run` looks under this folder.
- **GUI** (`zef_bst_plugin_start`, figure `ZEFFIRO-Brainstorm plugin`): **Settings file** → `zef_bst_settings_file` (`uigetfile('*.m')`). Chosen **basename** is stored on the figure; **Edit settings** opens that file in the editor.

Copy this file under a new name in this folder for another preset; pass that basename as `config.settings_file_name`.

## Important notes

The plugin popup only lists `zef_bst_*_fem_mesh_create.m` in the parent package (currently `zef_bst_default_fem_mesh_create`), not these settings scripts.

## Developer guidance

Keep settings as scripts that assign into `zef_bst` in the caller workspace. Document new factory fields here and in the parent converter README.
