# Settings dialogs (`src/gui/open`)

`zef_open_*` **scripts** instantiate an App Designer options window, copy `h_*` onto `zef`, set `ValueChangedFcn` to the matching `zef_update_*`, and fill dropdowns. They expect workspace `zef`.

Menu labels are `Text=` on `uimenu` in `zef_menu_tool_app_exported`; `MenuSelectedFcn` is wired in `zef_menu_tool.m`.

| Menu item | File | After open |
|-----------|------|------------|
| **Settings → Forward and inverse processing options** | `zef_open_forward_and_inverse_options` | then `zef_update`. Compartment lists via `zef_get_active_compartments` (**Active compartments** plus each tissue name). Labeling-priority menus → `zef_update_labeling_priority` |
| **Settings → Graphics processing options** | `zef_open_graphics_options` | then `zef_update` |
| **Settings → Hierarchical prior options** | `zef_open_gaussian_prior_options` | then `zef_update`. **Plot** → `zef_plot_hyperprior` |
| **Settings → System settings (zeffiro_interface.ini)** | `zef_open_system_settings` | no `zef_update`. **Save** / **Apply** write the INI |
| **Settings → Parameter profile** | `zef_open_parameter_profile` | **Save** / **Apply** write `zeffiro_parameters.ini` |
| **Settings → Segmentation profile** | `zef_open_segmentation_profile` | **Save** writes `zeffiro_segmentation.ini` (what `zef_init_compartments` reads) |
| **Settings → Pre-settings profile** | `zef_open_init_profile` | **Apply** → `zef_apply_init_profile` → `zef_init_init_profile` |
| **Settings → Plugin settings** | `zef_open_plugin_settings` | **Apply** → `zef_save_plugin_settings; zef_plugin` (rebuilds plugin menus) |

Closing a dialog does not by itself write INI files; **system/plugin** (and the profile **Save** buttons) save when their save control is used.

Layout sources: `src/gui/apps/*.mlapp` (and a few non-exported app classes next to them).
