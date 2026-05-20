# tools

## Folder purpose

Hosts **Zeffiro plugins** and other tooling that extends the interface beyond `src/`. At startup, `zeffiro_interface.m` runs `addpath(genpath(fullfile(program_path, 'tools', 'plugins')))`, making all plugin functions callable from menu callbacks.

## Main contents

| Path | Role |
|------|------|
| `plugins/` | 39 top-level plugin packages (inverse GUIs, data bank, Kalman, SESAME, ES workbench, …) |
| *(future)* | Additional non-plugin tooling could live alongside `plugins/` |

Each plugin typically contains:
- A **start** script (`zef_*_start.m`, `*_app_start.m`) opened from `zeffiro_plugins.ini`
- An **App Designer** `.mlapp` or legacy `.fig` window
- An **`m/`** folder with iteration/solver functions
- Optional `fig/`, `Scripts/`, `clusterScripts/`

## Code functionality

**Registration:** `src/core/zef_plugin.m` reads CSV rows from `profile/<profile_name>/zeffiro_plugins.ini`:
```
Menu label, parent_menu_tag, callback_script
```
Parent tags: `inverse_tools`, `forward_tools`, `multi_tools`, `settings`.

**Inverse plugins** usually implement `zef_*_iteration(zef)` that:
1. Calls `zef_processLeadfields`
2. Loops frames with `zef_getFilteredData` / `zef_getTimeStep`
3. Writes `zef.reconstruction` and `reconstruction_information`

**Modern class inverses** (`+inverse`) are invoked via `zef_inverse_run` — most GUI buttons still call **legacy** plugin iterations. Registry mapping: `+utilities/+cluster/inverse_method_registry.m`.

## Workflow context

```
zef_menu_tool → zef_plugin → uimenu(callback → plugin_start → plugin_window)
  → user clicks Start → *_iteration(zef) → zef.reconstruction
```

`+tests/ClassVsLegacyTest` compares class dispatch vs legacy for selected methods.

## Usage instructions

Enable plugins by choosing a **profile** (`zef.profile_name` from `profile/zeffiro_interface.ini`). Switch profile in segmentation tool dropdown; re-run `zef_plugin` after `zef_load`.

Plugins **not** in any profile INI (manual only): CreateDipolarPair, DBS_tool, EITSensitivityTool, StripTool, RAP-MUSIC, PlotMeshesProto, etc.

## Important notes

- Plugin callback names in INI must match an on-path function (e.g. `ias_map_estimation_roi` vs function name `ias_map_estimation` in IASROIInversion — verify before relying on menu entry).
- Duplicate algorithm code exists in `+plugins` (ClassKF, ClassGMM) vs `tools/plugins` (Kalman, GMMClustering).
- `tools/plugins` is on the path as **flat functions**, not as a MATLAB package.

## Developer guidance

- New plugin: create folder under `plugins/`, add start + window + iteration, register in **every** profile INI that should expose it.
- Prefer migrating solvers to `+inverse` + `zef_inverse_run` over copying frame loops.
- See `tools/plugins/README.md` for the full per-plugin catalog.
- Keep plugin callbacks ending with `zef_update` when they change shared tables (menu tool adds this automatically for INI entries).
