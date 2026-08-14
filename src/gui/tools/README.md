# GUI tool windows (`src/gui/tools`)

These scripts **create** the main Zeffiro windows and attach every button and menu to a MATLAB callback. They do not implement meshing or inverse mathematics; they instantiate an App Designer export, copy widget handles onto `zef` as `h_*`, and set `ButtonPushedFcn` / `MenuSelectedFcn` / `ValueChangedFcn`.

`zef_start` (`src/core`) calls them in this order: segmentation → figure → mesh → mesh visualization → menu. Closing a tool usually only hides it (`Visible='off'`); `zef_close_all` deletes them.

Layout-only App Designer classes live in `src/gui/apps/` (`*_app_exported.m`). Business logic is here and in `src/gui/callbacks`, `update`, `plot`, `open`.

## Pattern

```matlab
zef_data = zef_mesh_tool_app_exported;   % UIFigure + widgets
zef = zef_assign_data(zef, zef_data);    % copy handles onto zef.h_*
set(zef.h_pushbutton21, 'ButtonPushedFcn', 'zef_create_finite_element_mesh;');
```

String callbacks run in the base workspace, where `zef` lives. After a widget edit, `zef_update_*` or `zef_update` copies values into `zef` fields.

## Windows and what they are for

### Menu bar — `zef_menu_tool.m`

**Script.** Instantiates `zef_menu_tool_app_exported` onto `zef.h_zeffiro_menu`. `DeleteFcn` is `zef_close_all`. Attaches dynamic properties used by waitbar/log (`ZefTool`, `ZefUseWaitbar`, `ZefWaitbarSize`, `ZefTaskId`, …). `zef_window_manager('standalone')` then `'dock_menu'`. Leaf menus append `zef_set_menu_size(...,'minimized')`; parents append `'expanded'`.

Labels from `zef_menu_tool_app_exported` (Import data labels are overwritten in this file):

| Menu | Typical actions (verified) |
|------|----------------------------|
| **Project** | New / Open / Save / Exit (`zef_close_all` on Exit) |
| **Import** | **Import data to a new project** / **Import data to project**, volume data, measurements, reconstruction, current pattern, resection points, **Import electrodes** |
| **Export** | Volume, segmentation, lead field, source space, sensors, reconstruction, FEM mesh |
| **Edit** | Reset lead field / volume / inversion data / reconstruction; merge lead field |
| **Inverse tools** / **Forward tools** / **Multi tools** | Plugin items injected by `zef_plugin` from `profile/<name>/zeffiro_plugins.ini`. **Also hardcoded** on Forward tools: **Find synthetic source** (`find_synthetic_source`), **Generate synthetic EIT data** (`find_synthetic_eit_data`), **Butterfly plot** (`zef_butterfly_plot`). |
| **Window** | Arrange / show tools (`zef_window_manager`, `zef_arrange_windows`) |

**Import → Import electrodes** calls `core.gui.menu_tool.import_electrodes_callback` (see `+core/+io/+electrodes/README.md`). That is not under Edit.

After wiring, `zef_plugin` attaches plugin menus. Accelerators `0–9` then `A–Z` are assigned to forward/inverse/multi tool items in order.

### Segmentation tool — `zef_segmentation_tool.m`

**Script.** Window title **ZEFFIRO Interface: Segmentation tool** (`h_zeffiro_window_main`). Instantiates `zef_segmentation_tool_app_exported`, copies fields onto `zef`, wires tables. **Profile:** dropdown lists subfolders of `profile/`. **Project tag:** / **Project notes:** → `zef_update`. CloseRequest hides; `DeleteFcn` on the window closes all Zeffiro windows and `rmpath`s when not deployed.

Labels from the App Designer export; callbacks from this file + `zef_menu_tool.m` (segmentation menus live on this figure):

| Control | Callback |
|---------|----------|
| Compartment / sensors / parameters cell edit | `zef_update` / `zef_update_sensors_name_table` / `zef_update_parameters` |
| Transform cell edit | `zef_update_transform` |
| Table selection | `zef_compartment_table_selection`, `zef_sensors_table_selection`, … |
| **Toggle controls** | `zef_segmentation_tool_toggle` (narrow/wide layout) |
| **Set position** | `zef_set_position` |
| **Add compartment** / **Delete compartment(s)** | `zef_add_compartment` / `zef_delete_compartment` |
| **Import surface mesh → Full mesh (STL file)** | `surface_mesh_type='stl'`; `uigetfile`; `zef_get_surface_mesh` |
| **Points (DAT file)** / **Triangles (DAT file)** | types `'points'` / `'triangles'` |
| **Toggle visible** / **Toggle on** | flip table columns 4 / 2 then `zef_update` |
| **Add sensor set** / **Add sensor** / DAT imports | see `src/sensors/README.md` |

This is where you turn tissues on and set σ before meshing. Column list: `src/compartments/README.md`.

### Mesh tool — `zef_mesh_tool.m`

Window title **ZEFFIRO Interface: Mesh tool**. This is the user-facing mesh and forward-run UI. Button map (from the App Designer export + this file):

| Button / control | Callback |
|------------------|----------|
| Create FEM mesh | `zef_create_finite_element_mesh` |
| Postprocess FEM mesh | `zef_postprocess_finite_element_mesh`; `zef_update` |
| Source interpolation | `zef_source_interpolation` |
| Resample field | `zef_field_downsampling` |
| Resample surfaces | `zef_surface_downsampling` |
| Run script | `zef_run_forward_simulation` |
| Apply transform | `zef_apply_transform` |
| Save profile / Update from profile | write/read `profile/<profile>/zeffiro_forward_simulation.ini` |

Checkboxes **Mesh smoothing**, **Refinement**, **LF source interp.**, **Resample surf.** and the numeric fields (mesh resolution, meshing accuracy, source count, smoothing strength, solver tolerance, surface triangles max., inflate iterations/strength) all call `zef_update_mesh_tool` on change.

The forward-simulation table is trusted MATLAB: **Run script** `eval`s the selected cell. Empty table is filled from the profile INI on first open. Details of the mesh pipeline: `src/mesh/README.md`.

### Figure tool — `zef_figure_tool.m`

**Script.** Not App Designer. Window title **ZEFFIRO Interface: Figure tool**. Builds `figure` + `uiaxes` (`zef.h_axes1`) and `uicontrol` sliders. `assignin('base','zef',zef)` so string callbacks see the session. `DeleteFcn` is `zef_reopen_figure`. `ZefFig` property holds `zef_fig_num`. Context menu **Axes pop-up** → `zef_axes_popup`.

Verified `String=` controls:

| Control | Callback |
|---------|----------|
| **Toggle controls** | `zef_toggle_figure_controls` |
| **Toggle edges** | `zef_toggle_edges` |
| **Time:** slider | `zef_slidding_callback` |
| **Color min/max**, **Distance**, transparencies, **Brightness**, **Contrast**, **Ambience**, **Diffusion**, **Specular exp.** | `zef_update_*` (see `src/gui/update/README.md`) |
| **Colormap:** | `zef_colormap` + contrast refresh |
| Linear/Logarithmic | `zef_update_colorscale` |
| **Lights:** `Default (vertical)`, `Lights off`, `Add x/y/z-lights`, `Add headlight` | `zef_update_lights` |
| **Reset** | `zef_set_figure_tool_sliders(zef,0)` |
| **Play** / **Stop** / **Logo** | `zef_play_cdata` / `zef_callbackstop` / `zef_logoplot` |
| **Compartments:** / **Sensors:** / **Details:** lists | `zef_colored_list` create in this file; fill via `zef_update_fig_details`. Click Compartments/Sensors → `zef_set_compartment_color` / `zef_set_sensor_color` then `zef_update`. Details has no swatches. |

**Window → Figure tool** calls `zef_figure_tool` (rebuild), not only `zef_window_visible`.

### Mesh visualization tool — `zef_mesh_visualization_tool.m`

**Script.** Instantiates `zef_mesh_visualization_tool_app_exported`. Every widget with `ValueChangedFcn` is set to `zef_update_mesh_visualization_tool`. Close hides the window.

| Button (App Designer `Text=`) | Callback |
|-------------------------------|----------|
| **Visualize volume** | `zef_visualize_volume` |
| **Visualize surfaces** | `zef_visualize_surfaces` |
| **Frame / Movie** | `zef_snapshot_movie` |
| **Axes pop-up** | `zef_axes_popup` |
| **Plot graph** | `zef_plot_graph` |
| **Visualize DTI streamlines** | `zef_visualize_dti_streamlines` |
| **Attach electrodes** / **Axes box** | `zef.attach_electrodes` / `zef.axes_visible` |
| **Clipping plane 1/2/3** | `zef.cp_on`, `cp2_on`, `cp3_on` + plane coefficients |
| **Cone field** / **Streamlines** / **Contour array** / **Contour labels** | matching `zef.*` flags |
| **Use inflated surfaces** | `zef.use_inflated_surfaces` |
| **Visualization type:** | `Domain labels`, `Distribution (volume)`, `Distribution (surface)`, `Parcellation`, `Topography` |
| **Distribution mode:** | `Reconstruction`, `Parameter real`, `Parameter imaginary` |

**Graph:** items are `help` of files in `src/visualization/graph_bank`. **Parameter:** from `zef_get_profile_parameters`.

### Parcellation — `zef_parcellation_tool.m`

**Function** `zef = zef_parcellation_tool(zef)`. Lazy: **Multi-tools → Parcellation tool** → `zef_tool_start(...,'zef_parcellation_tool_open',…)`. Not opened at startup.

`zef_parcellation_tool_open` runs `zef_init_parcellation` then `zef_parcellation_tool_window` (programmatic `figure`, title **ZEFFIRO Interface: Parcellation tool**). Button map: `src/parcellation/README.md`. `nargout==0` → `assignin('base','zef',zef)`.

## Other files

- `zef_tool_start.m` — **function**. If `findall(groot,'ZefTool',tool_script)` finds a figure, `'raise'` it. Else `evalc` `zef = <tool_script>(zef)`, tag new figures, record new numeric fields in `zef.zeffiro_variable_data` (reloaded from the project MAT on later opens). Sets `zef_closereq` and `zef_set_size_change_function`.
- `zef_parcellation_tool_open.m` / `zef_parcellation_tool_window.m` — init + UIFigure (see Parcellation above).
- `zef_update_mesh_tool.m` — **script**. When `zef.mlapp==1`, copies Mesh-tool checkboxes/edits into `zef` and writes the selected forward-table cell from the script box. Else enables clipping-plane edits (legacy).
- `zef_update_mesh_visualization_tool.m` — **script**. Copies contour, clipping, transparency (`1 - widget`), colormap, camera, frames, cone/streamline flags. `layer_transparency` / `brain_transparency` are stored inverted from the slider.
- `zef_set_figure_tool_sliders.m` — **function**. `set_mode==0` (**Reset**) writes factory slider values; else copies `zef.update_*` onto widgets.
- `zef_segmentation_tool_toggle.m` — **function**. **Toggle controls**: multiply/divide window width by 0.505.
- `zef_reopen_menu_tool.m` — **script**. Saves `ZefCurrentLogFile` / `ZefTaskId` / `ZefRestartTime`, deletes the menu, `zef_menu_tool`, `zef_update`.

## Scripting

You rarely call these from a batch script (`start_mode` `nodisplay` still constructs hidden figures). Call the same functions the buttons call (`zef_create_finite_element_mesh`, `zef_lead_field_matrix`, …) instead of poking `h_*` handles.

To show a hidden tool after startup:

```matlab
zef.h_mesh_tool = zef_window_visible(zef, zef.h_mesh_tool);
```

## See also

- `src/gui/README.md` — GUI layer map
- `src/core/zef_start.m` — who opens what
- `src/mesh/README.md` — what Create FEM mesh actually computes
