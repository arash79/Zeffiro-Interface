# Settings dialogs (`src/gui/open`)

## Folder purpose

**Launchers for Settings dialogs**, plus the shared class-inverter parameter form. Typical `zef_open_*` Settings scripts initialize defaults, construct an App Designer export from `src/gui/apps/*.mlapp`, copy `h_*` onto `zef`, wire `ValueChangedFcn` to `zef_update_*`, and push current `zef` values into widgets. `zef_open_class_inverse` is different: it builds a programmatic `uifigure` from a `spec` struct and runs `zef_inverse_run` on Start.

## Main contents

| Menu item (Settings) | File | Notes |
|----------------------|------|-------|
| Forward and inverse processing options | `zef_open_forward_and_inverse_options` | Then `zef_update`; labeling priority → `zef_update_labeling_priority` |
| Graphics processing options | `zef_open_graphics_options` | Then `zef_update` |
| Hierarchical prior options | `zef_open_gaussian_prior_options` | Plot → `zef_plot_hyperprior` |
| System settings (`zeffiro_interface.ini`) | `zef_open_system_settings` | Save/Apply write root INI |
| Parameter profile | `zef_open_parameter_profile` | Save/Apply → `zeffiro_parameters.ini` |
| Segmentation profile | `zef_open_segmentation_profile` | Save → `zeffiro_segmentation.ini` |
| Pre-settings profile | `zef_open_init_profile` | Apply → `zef_apply_init_profile` |
| Plugin settings | `zef_open_plugin_settings` | Apply → `zef_save_plugin_settings; zef_plugin` |

| Helper | Role |
|--------|------|
| `zef_open_class_inverse.m` | Inverse-tools **(class solver)** dialog. Not a Settings menu item. `plugins/ELORETA` (and UKFNMM / HALpR / GroupLasso) pass a `spec`; **Start** runs `zef_inverse_run`. |
| `zef_about_dialog.m` | About / version dialog |
| `zef_ui_confirm.m` | Shared confirm prompt for destructive or long-running actions |

Menu labels come from the menu app; `MenuSelectedFcn` is set in `zef_menu_tool.m`.

## Code functionality

Typical `zef_open_*` pattern:

1. `zef_init_*` — field defaults  
2. Construct App Designer object  
3. Copy `fieldnames` → `zef.h_*`  
4. Set each control’s `ValueChangedFcn` to `'zef_update_*;'`  
5. Assign current `zef` values into widgets  
6. Optional `zef_ui_polish_window` / theme apply  

Closing a dialog does **not** always write INI files — Save/Apply buttons do.

## Workflow context

```
zef_menu_tool Settings menu → zef_open_* → user edits → zef_update_* → zef fields / INI
Inverse tools (class solver) → zef_*_start → zef_open_class_inverse → zef_inverse_run
```

Layouts: `src/gui/apps/*.mlapp`. Writers: `src/io/zef_save_system_settings`, `zef_save_plugin_settings`.

## Usage instructions

```matlab
zef_open_system_settings;
zef_open_forward_and_inverse_options;
% Confirm helper (from other tools):
% tf = zef_ui_confirm(message, title);
```

## Important notes

- Display required; unsuitable for pure nodisplay batch without replacement.
- Profile Apply may not rebuild menus until `zef_plugin` / restart — see `profile/README.md`.

## Developer guidance

- New settings dialog: add `.mlapp` under `src/gui/apps`, `zef_open_*` here, `zef_update_*` under `src/gui/update`, and a menu wire in `zef_menu_tool`.
- New class-solver Inverse-tools dialog: do **not** add an `.mlapp` here. Put `zef_*_start` / `zef_*_window` under `plugins/` and call `zef_open_class_inverse` with a `spec`. Recipe: [`docs/developer-guide.md`](../../../docs/developer-guide.md).
- Prefer `zef_ui_confirm` over ad-hoc `questdlg` for consistent chrome.
- Pitfall: writing INI on every `ValueChangedFcn` instead of Save/Apply. Class-solver Start does not write INI; it runs `zef_inverse_run`.
