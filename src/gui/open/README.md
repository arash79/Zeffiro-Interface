# Settings dialogs (`src/gui/open`)

## Folder purpose

**Launchers for modal / secondary App Designer dialogs**. Each `zef_open_*` script initializes defaults, constructs the app, copies `h_*` onto `zef`, wires `ValueChangedFcn` to `zef_update_*`, and pushes current `zef` values into widgets.

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

Menu labels come from `zef_menu_tool_app_exported`; `MenuSelectedFcn` is set in `zef_menu_tool.m`.

## Code functionality

Typical pattern:

1. `zef_init_*` — field defaults  
2. Construct App Designer object / export  
3. Copy `fieldnames` → `zef.h_*`  
4. Set each control’s `ValueChangedFcn` to `'zef_update_*;'`  
5. Assign current `zef` values into widgets  

Closing a dialog does **not** always write INI files — Save/Apply buttons do.

## Workflow context

```
zef_menu_tool Settings menu → zef_open_* → user edits → zef_update_* → zef fields / INI
```

Layouts: `src/gui/apps/*.mlapp`. Writers: `src/io/zef_save_system_settings`, `zef_save_plugin_settings`.

## Usage instructions

```matlab
zef_open_forward_and_inverse_options;
zef_open_system_settings;
```

Or use **Settings** in the menu bar after `zeffiro_interface`.

## Important notes

- Scripts expect `zef` in the workspace.
- Plugin settings Apply rebuilds Inverse/Forward/Multi tool menus via `zef_plugin`.
- Segmentation profile Save changes what `zef_init_compartments` loads next time.

## Developer guidance

- New settings dialog: add `.mlapp`, `zef_init_*`, `zef_open_*`, `zef_update_*`, menu entry in `zef_menu_tool.m`.
- Keep Save vs Apply semantics consistent with existing dialogs.
- Document new INI keys in `profile/README.md`.
