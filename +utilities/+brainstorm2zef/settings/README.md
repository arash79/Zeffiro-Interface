# `settings/` — Brainstorm converter defaults

`zef_bst_default.m` is a **script** (not a function). `zef_bst_get_settings('zef_bst_default')` runs `zef_bst_init` first, then this file in the caller workspace so it can assign `zef_bst.*`. `run` and the GUI plugin both load it that way.

## How a user picks it

- **Programmatic:** `config.settings_file_name = 'zef_bst_default'` (basename, no `.m`). `run` looks under this folder.
- **GUI** (`zef_bst_plugin_start`, figure `ZEFFIRO-Brainstorm plugin`): **Settings file** → `zef_bst_settings_file` (`uigetfile('*.m')`). The chosen **basename** is stored on the figure; **Edit settings** opens that file in the MATLAB editor.

Copy this file under a new name in this folder to make another preset; pass that basename as `config.settings_file_name`. The plugin popup only lists `zef_bst_*_fem_mesh_create.m` in the parent package (currently `zef_bst_default_fem_mesh_create`), not these settings scripts.

## Factory values (from this file)

`mesh_resolution = 3`, `compartment_list` / `refine_surface` (Scalp, OuterSkull, InnerSkull, Cortex, Other, white, subcortical), `refine_surface_mode = 2`, `use_gpu = 1`, `parallel_processes = 10`, `surface_mesh_density = 0.25`, `inflation_on = 0`. Override individual fields with `config.zef_bst` on `run` (merged after the script). Parent: [`../README.md`](../README.md).
