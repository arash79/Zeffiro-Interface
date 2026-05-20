# profile

## Folder purpose

**Startup profiles** for Zeffiro Interface: system-wide defaults, per-domain plugin menus, compartment templates, physical parameters, and mesh-tool forward-simulation scripts. `zeffiro_interface.m` adds `genpath(profile)` to the MATLAB path; INI files are read by explicit paths in `src/core` and `src/gui`.

## Main contents

| Path | Files | Role |
|------|-------|------|
| `zeffiro_interface.ini` | 1 | **Global** system settings (GPU, logging, default profile name, save paths) |
| `multicompartment_head/` | 5 INIs | Default EEG/MEG head profile (richest plugin set) |
| `multicompartment_head_legacy/` | 5 INIs | Pre-seeded 25-compartment segmentation table |
| `multicompartment_head_nse/` | 5 INIs | Head model + NSE viscosity fields |
| `asteroid_gravity/` | 5 INIs | Gravity lead-field profile (2 compartments, `rho`) |
| `asteroid_radar/` | 5 INIs | Radar/wireframe-oriented asteroid profile |

Each sub-profile contains:
- `zeffiro_plugins.ini` — menu label, parent tag, callback
- `zeffiro_init.ini` — initial `zef` fields after `zef_init`
- `zeffiro_segmentation.ini` — default compartment table template
- `zeffiro_parameters.ini` — σ, ρ, compartment activity defaults
- `zeffiro_forward_simulation.ini` — mesh-tool forward script rows

**There is no per-subfolder `zeffiro_interface.ini`** — only the root file.

## Code functionality

**`zef_apply_system_settings`** reads `profile/zeffiro_interface.ini` → sets `zef.profile_name` (default `multicompartment_head`), `save_file_path`, GPU flags, log settings.

**`zef_plugin`** reads `profile/<profile_name>/zeffiro_plugins.ini` and creates `uimenu` items under `inverse_tools`, `forward_tools`, `multi_tools`, `settings`.

**`zef_init_compartments`** loads `zeffiro_segmentation.ini` when non-empty.

**Profile differences (plugins):**
- `multicompartment_head`: SL1, EXP Lasso, dual GMM (SP/JL), DTI tool, synthetic patch — **no** `exp_ias_map_estimation_multires`
- `legacy` / `nse`: adds **EXP IAS RAMUS** multires entry
- `asteroid_*`: **SESAME**, wireframe tool; drops Kalman, NSE, SL1, DTI; gravity-only forward table

## Workflow context

```
zeffiro_interface → zef_start → zef_apply_system_settings (root INI)
  → zef_init + profile parameters INI
  → zef_menu_tool → zef_plugin (profile plugins INI)
```

User can switch profile from segmentation tool dropdown (lists subdirs of `profile/`); changing profile requires reloading INIs through GUI tools.

## Usage instructions

```matlab
% Default profile is multicompartment_head (from zeffiro_interface.ini)
zef = zeffiro_interface;

% Edit plugins, then save from GUI or:
% zef_save_plugin_settings (writes profile/<name>/zeffiro_plugins.ini)

% Use asteroid profile
% Edit profile/zeffiro_interface.ini profile_name field, or switch in GUI
```

## Important notes

- `zef_remove_system_fields.m` treats fields listed in root `zeffiro_interface.ini` as non-persisted system fields on save.
- `data/default_project.mat` is configured but often **missing** in fresh clones.
- Plugin callback strings must name functions on the path (`tools/plugins` + `src`).
- `multicompartment_head_legacy` is the only profile with a **populated** default segmentation table.

## Developer guidance

- New profile: copy an existing subfolder, edit all five INIs, set `profile_name` in root INI or let users select in GUI.
- Keep plugin CSV format: `label, menu_tag, callback` — no spaces in callback unless quoted.
- Forward simulation INI rows are `eval`'d — use valid `zef_*` function names only.
- Document profile-specific plugins in `tools/plugins/README.md`.
