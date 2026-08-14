# GUI helpers (`src/gui/helpers`)

Shared utilities the tools call: window docking, showing hidden tools, copying App Designer handles onto `zef`, colormaps, source interpolation, volume import, and a few mesh-adjacent helpers that grew up next to the GUI.

There is no single menu for this folder. Entry points you actually invoke:

| You want to… | Call |
|--------------|------|
| Color-swatch lists (Figure tool, parcellation, strip tool) | `zef_colored_list` — HTML listboxes before R2025a, compact `uihtml` lists after |
| Show a hidden tool next to the menu | `zef_window_visible(zef, zef.h_mesh_tool)` |
| Tile windows | `zef_arrange_windows` in `src/core` (prefer that over `zef_tile_windows` here) |
| Merge an App export into `zef` | `zef_assign_data` (used by Mesh tool; Segmentation copies fields in a loop) |
| Import volume `.mat` | **Import → Import volume data** → `zef_import` |
| Import measurements / recon | **Import → Import measurement data** (etc.) → `zef_inv_import` |

~90 files. Priorities below; colormaps and one-line math helpers are listed at the end.

## Color-swatch lists (`zef_colored_list`)

The Figure tool **Compartments:** / **Sensors:** / **Details:** lists, the Parcellation tool parcel list, and the Strip tool strip list all need a named row plus a colour chip. Before MATLAB R2025a that was an undocumented Java HTML `listbox`. From R2025a those listboxes show the tags as text, so this helper switches backend:

| Backend | When | Widget |
|---------|------|--------|
| `html` | `version('-release')` year < 2025, or `'Backend','html'` | `uicontrol` listbox, HTML `String` |
| `uihtml` | R2025a+ default; `'Backend','uihtml'` | compact HTML page (11 px rows, 9 px chips) |
| `table` | `uihtml` constructor throws | `uitable` fallback |

Callers never parse `String` for names. Plain labels live on `UserData.Names`. Selection is 1-based (`'value'` get/set). `'set'` restores the previous selection when the same labels are rewritten.

**Figure tool** (`zef_figure_tool`): Compartments and Sensors use `'Trigger','buttondown'` so a click runs `zef_set_compartment_color` / `zef_set_sensor_color` then `zef_update`. Details uses `'ShowSwatches', false`. `zef_update_fig_details` fills the three lists after Visualize volume/surfaces.

**Parcellation:** `'Multiselect', true`, `'AllowEmpty', true`. `zef_update_parcellation` passes `'Markers'` `X` (red, not interpolated) or `V` (green = interpolated, orange = points but empty interp).

**Strip tool:** single-select; empty selection is forced back to 1 in the callback.

```matlab
h = zef_colored_list('create', fig, [0.03 0.03 0.20 0.20], 'compartment_visible_color', ...
    'Callback', 'zef_set_compartment_color; zef_update;', 'Trigger', 'buttondown');
zef_colored_list('set', h, {'Scalp','Skull'}, [1 0.5 0.5; 0.9 0.9 0.2]);
idx = zef_colored_list('value', h);
```

Tests: `tests.ColoredListTest`.

## Window management (R2025a+)

`zef_window_manager.m` — function `varargout = zef_window_manager(action, varargin)`.

From R2025a, `figure` defaults to `WindowStyle='docked'`. Setting style to docked *after* `Position` re-docks the window so Zeffiro tools look like they vanished. This helper:

| Action | Effect |
|--------|--------|
| `'init'` | Save groot `defaultFigureWindowStyle`, set it to `'normal'` |
| `'restore'` | Put the factory default back (`zef_close_all`) |
| `'standalone'` | `WindowStyle='normal'` on handle `h`, optional `Position` |
| `'raise'` | Bring `h` forward |
| `'dock_menu'` | Keep the menu bar stacked with the segmentation tool |
| `'is_protected'` | Skip in `zef_arrange_windows` (menu, waitbars, and segmentation for close/minimize) |
| `'sizechanged'` / `'on_size_changed'` | Size-callback adapters |

`zef_window_visible.m` — show `window_handle`, align its top-right to `h_zeffiro_menu`, `'raise'`, apply `zef.font_size`. If the handle is the segmentation tool, also `'dock_menu'`.

**Window → Segmentation tool / Mesh tool / Mesh visualization tool** in `zef_menu_tool.m` call `zef_window_visible`. **Window → Figure tool** rebuilds via `zef_figure_tool` (not merely unhide).

`zef_reset_windows.m` — **Window → Reset windows**. `zef_tile_windows.m` duplicates `zef_arrange_windows` (the file’s first `function` line is even named `zef_arrange_windows`; MATLAB still calls it `zef_tile_windows`). `zef_tile_figs.m` — figure-only tiling. `zef_closereq.m` — close request helper. `zef_reopen_figure.m` — Figure tool `DeleteFcn` path (`zef_figure_tool` sets `DeleteFcn` to `zef_reopen_figure`).

## Session / table plumbing

| File | Kind | Role |
|------|------|------|
| `zef_assign_data.m` | function | Copy every field of `zef_data` onto `zef`; no-arg mode uses base `zef_data` and `assignin` |
| `zef_get_data_compartment_table.m` | **script** | One table row → `<tag>_on/_name/_visible/_merge/_invert/_sources` via `eval`. Columns: 2 On, 3 Name, 4 Visible, 7 Merge, 8 Invert, 9 Activity (`ColumnFormat{9}` index minus 2). Needs `zef_i`, `zef_j`, `zef.aux_field_1` from `zef_update`. |
| `zef_get_active_compartments.m` | function | Names/indices of `_on` compartments |
| `zef_get_profile_parameters.m` | function | Parameter-profile names for Mesh visualization **Parameter:** list |
| `zef_eval_entry.m` | function | Safe index into groot `ScreenSize` (waitbar width) |
| `zef_exclude_load_fields.m` / `zef_replace_project_fields.m` | load-time field filters | |
| `zef_remove_object_fields.m` | related to handle stripping | |
| `zef_gather_object_handles.m` | collect graphics handles | |

## Import (menu-wired, live here not in `src/io`)

| File | Menu | Notes |
|------|------|--------|
| `zef_import.m` | **Import → Import volume data** | `uigetfile('*.mat')`; returns `nodes, tetrahedra, sigma, brain_ind, surface_triangles`. Builds outer faces from unmatched tetra faces. |
| `zef_inv_import.m` | Import measurement / noise / reconstruction / current pattern | Driven by `zef.inv_import_type` 1–4 |
| `zef_get_surface_mesh.m` | Compartment table → **Import surface mesh** → STL / Points / Triangles DAT | Script; needs `zef.file` already set |
| `zef_get_sensor_points.m` / `zef_get_sensor_directions.m` | Sensors table → **Import sensors → Points/Directions (DAT file)** | Scripts; directions uses `zef_get_mesh` file_type `'triangles'` |
| `zef_merge_lead_field.m` | **Edit → Merge lead field with...** | Menu calls `merge_lead_field` (no first-party file of that name). This script is `zef_merge_lead_field`: load `L` from a `.mat` and `[zef.L; L]` when column counts match. |

## Figure-tool movie / sliders / butterfly

`zef_play_cdata.m`, `zef_store_cdata.m`, `zef_snapshot_movie.m` (**Frame / Movie** on Mesh visualization), `zef_slidding_callback.m` (time slider), `zef_callbackstop.m` (**Stop**), `zef_reset_color_sliders.m`, `zef_axes_popup.m` (context menu **Axes pop-up** / button **Axes pop-up**), `zef_fig_num.m` (unique Figure-tool index), `zef_size_change.m` / `zef_change_size_function.m`.

`zef_make_butterfly_plot` — **Forward tools → Butterfly plot** → **Plot**. Overlays filtered `zef.measurements` on `h_axes1`. Window construction is `src/gui/plot/zef_butterfly_plot*.m`; widget copy is `src/gui/update/zef_update_butterfly_plot`. See `src/gui/plot/README.md`.

## Source interpolation (lead-field / Mesh tool)

`zef_lead_field_interpolation` (in `src/forward`) dispatches on `core.types.ZefSourceModel`:

| Model | Helper | Extra argument |
|-------|--------|----------------|
| Whitney / ContinuousWhitney | `zef_whitney_interpolation` | `'pbo'` or `'mpo'` (required) |
| Hdiv / ContinuousHdiv | `zef_hdiv_interpolation` | `'pbo'`/`'mpo'`; empty neighbours → nested discrete-local path |
| StVenant / ContinuousStVenant | `zef_st_venant_interpolation` | Tikhonov `p_regparam` (EEG FEM uses `1e-6`) |

All three return `[G, interpolation_positions]` with `G` sparse `n_nodes × 3*n_sources` and positions at tet barycentra. Whitney uses FI dipoles only (`zef_fi_dipoles`); H(div) adds EW (`zef_ew_dipoles`) and `G = G_fi*S_fi + G_ew*S_ew`. PBO is a saddle-point on distances to the barycentre (`zef_pbo_system`); MPO is `lsqminnorm` on scaled moments (`zef_mpo_system`). St. Venant is monopolar least squares on the adjacency stencil (`zef_adjacency_matrix`), then `G = -G`.

Related mesh scripts (caller workspace, not Mesh-tool buttons by themselves): `zef_refinement_step` (surface 8-tet split), `zef_smoothing_step` (Taubin), `zef_get_tetra_to_refine` (adaptive candidates for `zef_mesh_refinement`), `zef_segmentation_counter_step`. Field helpers: `zef_smooth_field`, `zef_simple_smoothing_matrix`, `zef_distance_smoothing`.

## Mesh labeling / quality

`zef_solid_angle_labeling` walks `reuna_p` / `reuna_t` and calls `zef_point_in_compartment`; `zef_mesh_labeling_step` uses the node labels to keep or drop tets, then `zef_choose_domain_labels` picks one candidate per tet from `*_labeling_priority`. `zef_point_in_cluster` is the same solid-angle test used only by `zef_fix_negatives` (inverted tets: `zef_condition_number < 0`). `zef_sigma` still injects `zef_smoothing_step` / `zef_refinement_step` in its workspace; the live lead-field path builds σ in `zef_postprocess_fem_mesh` instead.

## Electrodes / EIT

`zef_electrode_struct.m`, `zef_cem_electrode.m`, `zef_pem2cem.m`, `zef_smooth_electrodes.m`, `zef_compute_eit_data.m`, `zef_transfer_matrix.m`.

## Colormaps

`zef_colormap(k)` evals `zef.colormap_cell{k}(colortune_param, colormap_size)`. Figure-tool **Colormap:** items from `zef_init`: Monterosso, Intensity I–III, Contrast I–V, Blue brain I–III, Parcellation (`src/parcellation/zef_parcellation_colormap`), Easter, Greyscale. `colortune_param` moves piecewise band edges (Intensity/Contrast/Monterosso) or is an exponent (Blue brain II/III, Easter, Greyscale). `zef_brightness_and_contrast` then applies `((x+b)/(1+b))^(1+c)` (function name is the misspelling `zef_brighness_and_contrast`).

## Unused in this tree (help on the file; no first-party callers)

`zef_validate_faces`, `zef_get_fields` (loop copies the empty output struct onto itself), `zef_string_from_source_model` (live names are `ZefSourceModel.to_string`), `zef_pushbutton_switch` (GUIDE compartment buttons), `zef_additional_options` (Settings → Forward and inverse processing options runs `zef_open_forward_and_inverse_options`), `zef_reset_parameter_profile` (Apply uses `zef_apply_parameter_profile`), `zef_get_sensor_boundary`. `zef_read_function_call` is only used by `zef_add_package`, which itself has no callers. `zef_lattice_deviation` is only used from the tES plugin `zef_ES_optimizer_properties_show`.

## Developer notes

- New colormap: add the function, append the name in `zef_init` `colormap_items`, and a branch in `zef_colormap`.
- Do not `addpath` this folder separately; `genpath(src)` already does.
