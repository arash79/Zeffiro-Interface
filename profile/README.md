# Startup profiles (`profile/`)

A **profile** is the set of INI files that decide which plugins appear on the menu, which tissue parameters exist, which compartment template is empty vs pre-filled, and which forward-simulation scripts sit in the Mesh tool table. It is not a saved project: anatomy, mesh, and `zef.L` still come from import / mesh / **Run script**. The profile only supplies defaults and menus.

`zeffiro_interface` adds `genpath(profile)` to the MATLAB path so plugin start functions resolve. The INI files themselves are read by explicit paths in `src/core` and `src/gui`, not by MATLAB’s path search.

If you have never changed a profile, you are using **`multicompartment_head`**: EEG/MEG/EIT/TES menus, isotropic `sigma`, empty segmentation table. That name is the **Profile name** row in `profile/zeffiro_interface.ini`.

## What a profile is for

Use a head profile when you model EEG/MEG/tES. Use an asteroid profile when the “volume” is a small body with density `rho` and gravity (or wireframe) tools instead of Kalman/DTI/NSE. Use `_legacy` if you want a 25-row default compartment table without importing a `.zef`. Use `_nse` when the NSE tool should be on the menu with head-model defaults.

Switching profile does **not** rebuild the FEM mesh or lead field. It changes which INIs later **Apply** / **Update from profile** / restart will read.

## The five INIs in each subfolder

Every subfolder (`multicompartment_head/`, `asteroid_gravity/`, …) has the same five files:

| File | Loaded by | What it controls |
|------|-----------|------------------|
| `zeffiro_plugins.ini` | script `zef_plugin` | Menu label, parent tag (`inverse_tools` / `forward_tools` / `multi_tools` / `settings`), start callback |
| `zeffiro_init.ini` | `zef_apply_init_profile` (end of `zef_init`) | Extra `zef` fields after the hard-coded defaults in `zef_init` |
| `zeffiro_segmentation.ini` | `zef_init_compartments` | Default compartment table. Empty header in `multicompartment_head`; populated in `_legacy` |
| `zeffiro_parameters.ini` | `zef_apply_parameter_profile` | Which physical parameters are On (`sigma`, `rho`, CEM radii/impedance) and their defaults |
| `zeffiro_forward_simulation.ini` | Mesh tool table | Rows **Name**, **Description**, **Script**. **Run script** `eval`s column 3 |

There is **no** per-subfolder `zeffiro_interface.ini`. The only copy is `profile/zeffiro_interface.ini` (GPU, log, default **Profile name**, save paths). Fields listed there are treated as non-persisted system fields by `zef_remove_system_fields` on save.

## How the GUI names these things

Verified from `zef_menu_tool_app_exported` `Text=` and `zef_segmentation_tool.m`:

| Control | What it actually does |
|---------|------------------------|
| Segmentation tool **Profile:** dropdown (`h_profile_name`) | Lists subdirectories of `profile/` (skips `.` / `..`). `ValueChangedFcn` only sets `zef.profile_name`. It does **not** reload INIs, rebuild plugin menus, or change the Mesh-tool script table. |
| **Project → New project from profile** | `zef_start_new_project` → `zeffiro_interface('zeffiro_restart', true)` then `zef_delete_all_compartments`. Restart builds a fresh `zef` and fills missing fields from **`profile/zeffiro_interface.ini`**, so the default **Profile name** in that INI wins unless you already saved a different name there. The dropdown value from the previous session is not passed through. |
| **Project → New empty project** | Same restart, but `zef.new_empty_project = 1` before `zef_start_new_project`. |
| **Settings → Parameter profile** | Edit / **Save** / **Apply** `zeffiro_parameters.ini` for the *current* `zef.profile_name`. **Apply** runs `zef_apply_parameter_profile`. |
| **Settings → Segmentation profile** | **Save** writes `zeffiro_segmentation.ini` (what `zef_init_compartments` reads on a new project). |
| **Settings → Pre-settings profile** | **Apply** writes `zeffiro_init.ini` then `zef_apply_init_profile`. |
| **Settings → Plugin settings** | **Apply** → `zef_save_plugin_settings; zef_plugin` (rebuilds Inverse/Forward/Multi-tools menus from the INI). |
| Mesh tool **Update from profile** | Reloads `zeffiro_forward_simulation.ini` into the table. |
| Mesh tool **Save profile** | Writes the table back to that INI. |
| **Settings → System settings (zeffiro_interface.ini)** | Edits the *root* INI, including the default **Profile name** used at the next cold start. |

`zef_update` copies `zef.profile_name` back onto the dropdown, so an unsaved dropdown change can be overwritten if something else calls `zef_update` before you Apply INIs.

## How to switch profile in practice

**To make a profile the default at every launch**

1. **Settings → System settings (zeffiro_interface.ini)**.
2. Set **Profile name** to a subfolder name (`asteroid_gravity`, `multicompartment_head_nse`, …).
3. **Save** / **Apply**, then restart Zeffiro (`zef_close_all` then `zeffiro_interface`, or **Project → New project from profile** after the INI is saved).

**To use another profile in the current session without changing the default**

1. Segmentation tool **Profile:** → choose the folder.
2. **Settings → Plugin settings → Apply** (menus).
3. **Settings → Parameter profile → Apply** (σ / ρ / CEM).
4. **Settings → Pre-settings profile → Apply** if you need that INI’s `zef` fields.
5. Mesh tool **Update from profile** (forward-script table).
6. Import anatomy / create a new project as usual. Segmentation INI is applied on `zef_init_compartments` (new project), not by the dropdown alone.

Scripted default:

```matlab
% After editing profile/zeffiro_interface.ini Profile name, or:
zef = zeffiro_interface;   % uses INI profile_name (default multicompartment_head)
```

There is no `zeffiro_interface('profile_name', …)` name-value in `zeffiro_interface.m`. To start another profile from MATLAB, change the INI first or set `zef.profile_name` after start and Apply the dialogs above.

## Shipped profiles

| Folder | Typical use | Forward table | Plugins (high level) |
|--------|-------------|---------------|----------------------|
| `multicompartment_head/` | Default EEG/MEG/EIT/TES head | `zef_*_lead_field_*` isotropic and anisotropic | Kalman, NSE, DTI, SL1, EXP Lasso, dual GMM. **No** EXP IAS RAMUS multires |
| `multicompartment_head_legacy/` | Same physics, **pre-filled** 25-compartment table | Same family | Adds EXP IAS RAMUS |
| `multicompartment_head_nse/` | Head + NSE viscosity fields | Same family | NSE-oriented; EXP IAS RAMUS |
| `asteroid_gravity/` | Gravity / density on a two-compartment body | `zef_gravity_*` only | SESAME, wireframe; drops Kalman, NSE, SL1, DTI |
| `asteroid_radar/` | Same INIs as gravity in this tree; radar **example project** + Itokawa surfaces | Same gravity scripts | Same plugin list as gravity |

Child READMEs list the exact INI rows. Example projects: `data/example_projects/`. Itokawa surfaces: `data/itokawa_model/`. Head anatomy to import: `data/segmentations/`.

## Startup sequence

```
zeffiro_interface
  → zef_start
       → zef_apply_system_settings   (root zeffiro_interface.ini → missing zef fields, including profile_name)
       → open segmentation / figure / mesh / menu
       → zef_init
            → zef_apply_init_profile, zef_init_compartments, zef_apply_parameter_profile
       → zef_menu_tool → zef_plugin (profile/<name>/zeffiro_plugins.ini)
```

`zef_start` overlays the caller’s `zef` fields *after* system settings, so name-value arguments to `zeffiro_interface` win over the INI when both set the same field. `profile_name` is not such an argument; it comes from the INI unless already present on `zef`.

## Adding a profile

Copy an existing subfolder, edit all five INIs, and either set **Profile name** in the root INI or let users pick the folder in **Profile:** and Apply as above. Plugin CSV format is `label,menu_tag,callback` with no spaces in the callback unless you quote it. Forward-simulation Script cells are `eval`’d: only trusted `zef_*` names.

Plugin inventory for the default profile: [`tools/plugins/README.md`](../tools/plugins/README.md).
