# profile/

## Folder purpose

INI configuration for **session defaults**, **parameter/segmentation presets**, **forward-simulation script tables**, and **plugin menus**. Active profile name comes from root `zeffiro_interface.ini` (`profile_name`, default `multicompartment_head`). These INIs are **not** the CSC/`parcluster` objects used by `utilities.cluster.configure_cluster_profile`.

## Main contents

### Root

| File | Role |
|------|------|
| `zeffiro_interface.ini` | System/session defaults: GPU, logging, paths, font, `profile_name=…` |

System fields are stripped on project save (`zef_remove_system_fields`).

### Profile folders

| Folder | Typical use |
|--------|-------------|
| `multicompartment_head/` | Default head demo menus/parameters |
| `multicompartment_head_legacy/` | Legacy EXP IAS RAMUS–style Inverse tools; some modern entries dropped |
| `multicompartment_head_nse/` | NSE / hemodynamic Multi tools enabled |
| `asteroid_gravity/` | Gravity forward/inverse demos |
| `asteroid_radar/` | Wave/radar pipeline demos |

### Per-folder INI set (usual)

| File | Role |
|------|------|
| `zeffiro_plugins.ini` | CSV `label,parent_tag,callback` for Inverse/Forward/Multi/Settings menus (`zef_plugin`) |
| `zeffiro_parameters.ini` | Physics / inverse parameter defaults |
| `zeffiro_segmentation.ini` | Segmentation profile table |
| `zeffiro_init.ini` | Init-profile table |
| `zeffiro_forward_simulation.ini` | Mesh-tool forward-simulation script table (Run script cells) |

Plugin settings can be written back via `zef_save_plugin_settings` → `profile/<profile_name>/zeffiro_plugins.ini`.

## Code functionality

- Startup reads root INI → sets `zef.profile_name` and system fields.
- `zef_plugin` loads `profile/<name>/zeffiro_plugins.ini` to fill menu parents.
- Parameter/segmentation/init/system dialogs apply the corresponding INI tables.
- Forward-simulation **Script** cells are trusted `eval` code run by `zef_run_forward_simulation`.

**Important:** Segmentation tool **Profile:** dropdown often only sets `zef.profile_name` — it may **not** fully reload menus/INIs until restart / explicit apply. Switching profile does **not** rebuild mesh or `zef.L`.

## Workflow context

```
zeffiro_interface.ini → profile_name
  → profile/<name>/*.ini → menus, defaults, forward scripts
tools/plugins callbacks named in zeffiro_plugins.ini
```

Class inverse ids (`zef_inverse_run`) are registered in `utilities.cluster.inverse_method_registry`, **not** in these INIs.

## Usage instructions

```matlab
% Change default profile: edit profile/zeffiro_interface.ini profile_name=...
% Or set after start (may need menu rebuild / restart for full effect):
zef.profile_name = 'multicompartment_head_nse';
```

Open Edit → parameter / segmentation / system / plugin settings dialogs to Apply table rows from INIs.

## Important notes

- Asteroid profiles drop many head-only tools (Kalman, NSE, DTI, …).
- `_legacy` adds EXP IAS RAMUS-style entries and may omit App Designer Lasso paths.
- Forward Script cells are a trust boundary — treat INI edits like code review.
- No `zeffiro_interface('profile_name',…)` name-value is guaranteed; prefer INI or documented fields.

## Developer guidance

- New menu plugin: add a CSV line to the relevant `zeffiro_plugins.ini` profiles that should see it.
- Keep callback names stable (`zef_*_start` / iteration scripts).
- Pitfall: editing `utilities.cluster.configure_cluster_profile` thinking it reads these INIs — it configures HPC `parcluster`, not Zeffiro GUI profiles.
