# GUI chrome (`src/gui/chrome`)

## Folder purpose

Shared **window chrome**: theme tokens, layout, docking, themed controls, and figure-tool window lifecycle. This is not a dumping ground for mesh, lead-field, or inverse math. Domain algorithms that used to live beside these files now live under `src/mesh`, `src/forward/lead_field`, `src/sensors`, `src/visualization`, and `src/io`.

## Main contents

### Theme and icons

| File | Role |
|------|------|
| `zef_ui_theme.m` | Color/font/spacing tokens. Light default; `zef.ui_color_mode = 'dark'` selects dark. Font size is at least 11 px even when the INI still says 8. |
| `zef_ui_apply_theme.m` | Paint a figure and its controls from tokens. Axes, images, colorbars, legends, and `uihtml` lists are left alone. |
| `zef_ui_broadcast_theme.m` | Restyle every open Zeffiro window after the shell Theme control changes. |
| `zef_ui_icons.m` | Themed PNG CData from `assets/fig/ui` via `which('zeffiro_interface')`. `zef_ui_icons('folder')` returns the icon directory. |

### Shell, layout dispatch, polish

| File | Role |
|------|------|
| `zef_ui_shell.m` | Unified main-window chrome (figure tool hosts the application shell). |
| `zef_ui_is_unified.m` | True when a figure hosts that shell. |
| `zef_ui_ready.m` | After a tool/dialog is built: pick layout by `Name`/`Tag`, then theme + polish. Waitbars (`progress_bar`) and the hidden Menu tool skip generic min-size inflate. |
| `zef_ui_ready_new_windows.m` | Plugin callback suffix: apply `zef_ui_ready` to newly created figures. |
| `zef_ui_polish_window.m` | Rounded chrome on secondary windows. |
| `zef_ui_adopt_app.m` | Name and theme an App Designer figure that skipped `zef_tool_start` (e.g. MUSIC). |
| `zef_ui_place_window.m` | Keep new dialogs on the session monitor; offset if another Zeffiro window occupies the same origin. |
| `zef_ui_apply_size.m` / `zef_ui_bind_min_size.m` | Default size (capped to the work area) and resize floor. SizeChangedFcn always calls `zef_ui_adapt_grid` (GUIDE `ZefGuideForm`, `zef_ui_root` grids, or `ZefPixelResize`). |
| `zef_ui_anchor.m` | Figure used to position secondary windows (unified shell, else menu tool). |
| `zef_ui_hide_orphans.m` | Hide leftover App Designer widgets after a grid rebuild. |
| `zef_ui_adapt_grid.m` | Tune grid proportions from the current window size. |
| `zef_ui_fit_dropdowns.m` / `zef_ui_fit_table.m` | Widen dropdowns / size table columns so text stays readable. |
| `zef_ui_interact.m` | Pointer, hover, and press feedback for traditional chrome. |
| `zef_ui_window_label.m` | Window title helper for themed tools. |
| `zef_ui_tag_handles.m` | Tag widget handles after App export merge. |
| `zef_ui_ensure_visible.m` | Grow a figure when controls overflow the client area (capped to the screen). Not a work-area clamp; that is `zef_ui_clamp_position`. |

### Layout functions (`zef_ui_ready` dispatch)

| File | Window |
|------|--------|
| `zef_figure_tool_layout.m` | Figure tool (axes + sidebar + lists) |
| `zef_layout_mesh_tool.m` | Mesh tool two-column grid |
| `zef_layout_mesh_visualization_tool.m` | Mesh visualization grouped grid |
| `zef_layout_segmentation_tool.m` | Segmentation tool three-column grid |
| `zef_layout_parcellation_tool.m` | Parcellation tool |
| `zef_layout_filter_tool.m` | Filter tool two-column grid |
| `zef_layout_fss.m` | Find synthetic source |
| `zef_layout_fss_roi.m` | Find synthetic extended source (ROI) |
| `zef_layout_strip_tool.m` | Strip tool |
| `zef_layout_data_bank.m` | Data Bank |
| `zef_layout_bank_tool.m` | Lead-field / reconstruction bank tools |
| `zef_layout_lf_bank.m` | Multi lead field tool |
| `zef_layout_dti_tool.m` | DTI conductivity tool |
| `zef_layout_nse_tool.m` | NSE tool |
| `zef_layout_source_tree.m` | Source tree tool |
| `zef_layout_form_dialog.m` | App Designer label-and-field option windows |
| `zef_layout_table_dialog.m` | Settings windows that are mostly a `uitable` |
| `zef_layout_guide_window.m` / `zef_layout_guide_form.m` | Traditional `figure()` tools / compact GUIDE forms |

### Window lifecycle

| File | Role |
|------|------|
| `zef_window_manager.m` | R2025a+ standalone/dock adapter (`init` / `restore` / `standalone` / `raise` / `dock_menu`). |
| `zef_window_visible.m` | Show a hidden tool figure. |
| `zef_reset_windows.m` | **Window → Reset windows**: recreate the five default tools. |
| `zef_closereq.m` | `DeleteFcn` helper (`zef_tool_start` sets this). |
| `zef_reopen_figure.m` | Figure-tool `DeleteFcn`: rebuild if the closed fig was `h_zeffiro`. |

### Widgets and Figure-tool glue

| File | Role |
|------|------|
| `zef_colored_list.m` | Named list with per-row color swatches (HTML pre-R2025a; `uihtml` from R2025a). |
| `zef_ui_card.m` / `zef_ui_card_corners.m` / `zef_ui_roundrect.m` / `zef_ui_round_button.m` | Card / rounded-rect chrome. |
| `zef_ui_control.m` / `zef_ui_find.m` / `zef_ui_axes.m` | Find tagged controls / axes after sidebar reparenting and `cla('reset')`. |
| `zef_assign_data.m` | Copy every field of an App-export struct onto `zef`. |
| `zef_fig_num.m` | Next unused Figure-tool `ZefFig` index. |
| `zef_axes_popup.m` | Copy Figure-tool axes1 (and colorbar) into a standalone figure. |
| `zef_callbackstop.m` | Figure-tool **Stop** toggle (`zef.stop_movie`). |
| `zef_slidding_callback.m` | Figure-tool **Time:** slider (legacy spelling). |
| `zef_size_change.m` | **Script.** Figure-tool `SizeChangedFcn` installer. |
| `zef_change_size_function.m` / `zef_get_relative_size.m` | Scale child `Position`/`FontSize` with the figure. |

## Code functionality

**Theme pipeline:** `zef_ui_theme(zef)` → tokens → `zef_ui_apply_theme` / layout functions. `zef_ui_ready(h)` selects layout by figure `Tag` / name.

**Icons:** `zef_ui_icons` resolves PNGs from `assets/fig/ui` using `which('zeffiro_interface')` (not a hard-coded parent-folder count).

**Window manager:** R2025a+ standalone/dock adapter. `zeffiro_interface` adds this folder early so `zef_close_all` can call `zef_window_manager('restore')` on restart.

## Workflow context

```
zef_start → src/gui/tools
              ↓
         chrome: theme + layout + colored_list
              ↓
         plot / mesh / forward callbacks (domain code lives elsewhere)
```

## Usage instructions

```matlab
theme = zef_ui_theme(zef);
zef_ui_apply_theme(zef.h_zeffiro, theme);
zef_figure_tool_layout(zef.h_zeffiro);
zef_window_visible(zef, zef.h_mesh_tool);
cdata = zef_ui_icons('forward', 20);
zef_window_manager('init');    % standalone figures (R2025a+ factory is docked)
```

`zef_ui_ready(h)` picks a layout from figure `Name` / `Tag` (Figure tool, Mesh visualization, Mesh tool, Segmentation, Parcellation, DTI, lead-field banks, Data Bank, strip/filter/NSE/source-tree, FSS/ROI, settings/profile/options dialogs, then a generic GUIDE form). Theme is always applied afterward. Waitbars (`Tag` `progress_bar`) and the hidden Menu tool skip the generic min-size inflate.

## Important notes

- R2025a+ `figure` defaults to `WindowStyle='docked'`. Setting `'docked'` **after** `Position` re-tabs the window so tools look like they vanished. Always go through `zef_window_manager('standalone', h)` (or `'init'` at session start). `zeffiro_interface` adds this folder early so restart can `zef_window_manager('restore')`.
- `zef_ui_theme`: light is default; `zef.ui_color_mode = 'dark'` selects the dark palette. Font size is **at least 11 px** even when the INI still says 8.
- Icons: `zef_ui_icons` loads PNGs from `assets/fig/ui` via `which('zeffiro_interface')` (not a hard-coded `fileparts` count). SVGs in `assets/fig/ui/Zeffiro_Modern_Icons/` are not runtime.
- `zef_colored_list` has HTML / `uihtml` backends; `tests.unit.ColoredListTest` and `tests.unit.UiThemeTest` cover tokens and lists. `tests.smoke.WindowManagementTest` covers docking.
- Layout functions match **window title strings**. Renaming a tool in App Designer without updating `zef_ui_ready` falls through to `zef_layout_guide_window`.

## Developer guidance

- New shared UI primitive: add here only if two or more tools need it.
- New tool window: implement `zef_layout_<tool>` and register it in `zef_ui_ready`.
- New toolbar icons: PNG under `assets/fig/ui/` (+ SVG master) and call `zef_ui_icons`.
- Do **not** put FEM, interpolation, or inverse math in this folder.
