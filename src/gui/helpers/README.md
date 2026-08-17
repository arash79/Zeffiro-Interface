# GUI helpers (`src/gui/helpers`)

## Folder purpose

Shared utilities used by Zeffiro tools: **UI theme and responsive layout**, window docking, colored listboxes, App Designer handle merging, colormaps, source-model interpolation helpers, volume/measurement import wrappers, and miscellaneous mesh-adjacent helpers (~100+ files). There is no dedicated menu for this folder; tools and `zef_start` call these functions directly.

## Main contents

### UI theme and layout (current figure/tool chrome)

| Entry | Role |
|-------|------|
| `zef_ui_theme` | Shared color/font/spacing tokens (cool gray + teal accent; font ≥ 11 px) |
| `zef_ui_apply_theme` | Paint a figure/app with theme colors |
| `zef_ui_ready` | After create: theme + bind min size + dispatch the right `zef_layout_*` / `zef_figure_tool_layout` |
| `zef_ui_control` / `zef_ui_axes` / `zef_ui_find` / `zef_ui_tag_handles` | Create/find/tag themed controls |
| `zef_ui_adapt_grid` / `zef_ui_apply_size` / `zef_ui_bind_min_size` / `zef_ui_ensure_min_size` | Resize and minimum window size |
| `zef_ui_fit_table` / `zef_ui_hide_orphans` | Table column fit; hide orphaned GUIDE widgets |
| `zef_figure_tool_layout` | Pixel layout for Figure tool (axes + sidebar + bottom lists; `SizeChangedFcn`) |
| `zef_layout_segmentation_tool` / `_mesh_tool` / `_mesh_visualization_tool` / `_menu_tool` / `_parcellation_tool` | Tool-specific layouts |
| `zef_layout_form_dialog` / `_table_dialog` / `_guide_window` | Settings / table / legacy GUIDE dialogs |
| `zef_capture_ui` | Screenshot helper used by QA scripts under `data/log` |

### Long-standing helpers (grouped; ~90 non-theme files)

| Group | Examples | Role |
|-------|----------|------|
| Windows | `zef_window_visible`, `zef_window_manager`, `zef_closereq`, `zef_reopen_figure`, `zef_change_size_function`, `zef_size_change` | Show/hide, close, reopen figure tool |
| App merge / lists | `zef_assign_data`, `zef_colored_list`, `zef_gather_object_handles`, `zef_remove_object_fields` | App Designer ↔ `zef`; color lists |
| Import | `zef_import`, `zef_inv_import` | Volume / measurement / reconstruction dialogs |
| Colormaps | `zef_colormap`, `zef_*_colormap` (~15) | Figure-tool colormap menus |
| Source interpolation | `zef_whitney_interpolation`, `zef_hdiv_interpolation`, `zef_st_venant_interpolation` | Lead-field source models |
| FEM / electrodes | `zef_transfer_matrix`, `zef_cem_electrode`, `zef_pem2cem`, `zef_electrode_struct`, `zef_smooth_electrodes`, `zef_mpo_system`, `zef_pbo_system` | EEG transfer & CEM helpers |
| Mesh / sigma utils | `zef_get_mesh`, `zef_sigma`, `zef_adjacency_matrix`, `zef_refinement_step`, `zef_fix_negatives`, `zef_validate_faces`, `zef_solid_angle_labeling`, `zef_simple_smoothing_matrix`, `zef_smoothing_step`, `zef_smooth_field`, `zef_distance_smoothing` | Geometry & conductivity helpers used across mesh/forward |
| Segmentation tables | `zef_get_data_compartment_table`, `zef_get_active_compartments`, `zef_get_fields`, `zef_choose_domain_labels`, `zef_segmentation_counter_step` | Table ↔ dynamic `<tag>_*` fields |
| Sensors | `zef_get_sensor_points`, `zef_get_sensor_directions`, `zef_get_sensor_boundary`, `zef_get_surface_mesh` | Sensor geometry queries |
| Plot / movie | `zef_play_cdata`, `zef_store_cdata`, `zef_snapshot_movie`, `zef_make_butterfly_plot`, `zef_axes_popup`, `zef_brightness_and_contrast`, `zef_reset_color_sliders` | Figure playback & butterfly |
| Project / profile | `zef_exclude_load_fields`, `zef_replace_project_fields`, `zef_get_profile_parameters`, `zef_reset_parameter_profile`, `zef_string_from_source_model` | Load filters & profile helpers |
| Misc numerics / UI | `zef_merge_lead_field`, `zef_compute_eit_data`, `zef_condition_number`, `zef_determinant`, `zef_L2_norm`, `zef_nearest_points`, `zef_point_in_cluster`, `zef_lattice_deviation`, `zef_decompose_dof_space`, `zef_gamma_gpu`, `zef_eval_entry`, `zef_read_function_call`, `zef_pushbutton_switch`, `zef_slidding_callback`, `zef_callbackstop`, `zef_additional_options`, `zef_fig_num`, `zef_get_relative_size`, `zef_get_tetra_to_refine` | Shared utilities |

Prefer `src/core/zef_arrange_windows` over `zef_tile_windows` here.

## Code functionality

**Theme pipeline:** `zef_ui_theme(zef)` → tokens → `zef_ui_apply_theme` / layout functions read `theme.color.*` and `theme.space.*`. Figure tool creation (`zef_figure_tool`) sets background from the theme and uses `zef_figure_tool_layout` on create and resize; **Toggle controls** calls the layout again (`zef_toggle_figure_controls`).

**`zef_ui_ready(h)`** selects layout by figure `Tag` / app identity (figure, mesh, mesh-viz, segmentation, menu, parcellation, table/form dialogs, GUIDE windows).

**`zef_colored_list` backends:** `html` (pre-2025), `uihtml` (R2025a+), `table` fallback.

**Transfer matrix:** builds electrode Schur system for `lead_field_eeg_fem` (not `pcg_iteration.m`).

## Workflow context

```
zef_start → tools (src/gui/tools)
                ↓
         helpers: theme + layout + assign_data + colored_list
                ↓
         plot / mesh / forward callbacks
```

Lead-field FEM depends on `zef_transfer_matrix` and Whitney/H(div)/St.Venant interpolators. Segmentation sync depends on `zef_get_data_compartment_table`. UI QA screenshots under `data/log` call `zef_capture_ui`.

## Usage instructions

```matlab
theme = zef_ui_theme(zef);
zef_ui_apply_theme(zef.h_zeffiro, theme);
zef_figure_tool_layout(zef.h_zeffiro);

h = zef_colored_list('create', fig, [0.03 0.03 0.20 0.20], 'compartment_visible_color', ...
    'Callback', 'zef_set_compartment_color; zef_update;', 'Trigger', 'buttondown');
zef_window_visible(zef, zef.h_mesh_tool);
```

Import: **Import → Import volume data** / **Import measurement data**.

## Important notes

- Theme font size is clamped to at least 11 even if INI still says 8.
- macOS Java sliders need `theme.space.sliderH` ≥ 16 or arrows clip.
- `zef_figure_tool_layout` uses `ZefLayoutBusy` appdata to avoid re-entrant resize loops.
- R2025a broke HTML listbox rendering — `zef_colored_list` abstracts that.
- Many helpers assume base-workspace `zef`.

## Developer guidance

- New shared UI primitive: add here only if ≥2 tools need it.
- When adding a tool window, implement `zef_layout_<tool>` and register it in `zef_ui_ready` — do not hard-code pixel positions only inside the create script.
- Keep colormap filenames/functions stable for figure-tool menus.
- Document transfer-matrix preconditioner choices next to `src/forward/lead_field` when changing PCG.
- Pitfall: calling layout functions without theme (colors drift from waitbar / menu).
