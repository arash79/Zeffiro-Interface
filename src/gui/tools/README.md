## Folder purpose

Scripts that **create** the main Zeffiro windows and attach every button and menu to a MATLAB callback. They do not implement meshing or inverse mathematics; they instantiate an App Designer export (or programmatic UI), copy widget handles onto `zef` as `h_*`, and set `ButtonPushedFcn` / `MenuSelectedFcn` / `ValueChangedFcn`. Layout-only classes live in `src/gui/apps/`.

## Main contents

| File | Role |
|------|------|
| `zef_menu_tool.m` | Menu bar (`h_zeffiro_menu`); `DeleteFcn` = `zef_close_all` |
| `zef_segmentation_tool.m` | Segmentation tool (`h_zeffiro_window_main`) |
| `zef_mesh_tool.m` | Mesh / forward-run UI |
| `zef_figure_tool.m` | Figure tool (not App Designer; `figure` + `uiaxes`; themed via `zef_ui_theme`) |
| `zef_mesh_visualization_tool.m` | Mesh visualization tool |
| `zef_parcellation_tool.m` / `_open` / `_window` | Lazy parcellation UI |
| `zef_tool_start.m` | Raise existing tool or `evalc` create + tag |
| `zef_update_mesh_tool.m` / `zef_update_mesh_visualization_tool.m` | Widget → `zef` scripts |
| `zef_set_figure_tool_sliders.m` | Reset or sync figure sliders |
| `zef_segmentation_tool_toggle.m` | Narrow/wide layout |
| `zef_reopen_menu_tool.m` | Rebuild menu preserving log/task metadata |

## Code functionality

Pattern: instantiate `*_app_exported` → `zef_assign_data` → set string callbacks that run in the base workspace.

**Menu:** Project / Import / Export / Edit; plugin parents filled by `zef_plugin`; hardcoded Forward tools include Find synthetic source, Generate synthetic EIT data, Butterfly plot; Window arrange/show. **Import electrodes** → `core.gui.menu_tool.import_electrodes_callback`.

**Segmentation:** compartment/sensors/parameters/transform tables → `zef_update` / selection callbacks; Add/Delete compartment; surface mesh import (STL/points/triangles); Toggle visible/on; profile dropdown.

**Mesh tool:** Create/Postprocess FEM mesh, Source interpolation, Resample field/surfaces, Run script, Apply transform, Save/Update forward INI. Checkboxes and numeric fields call `zef_update_mesh_tool`. Forward-table Script cells are trusted `eval` code.

**Figure tool:** Script builds `h_zeffiro` with `uiaxes` (`h_axes1`), applies `zef_ui_theme`, and lays out via `zef_figure_tool_layout` (also on `SizeChangedFcn` / Toggle controls). Controls: edges, time slider, color/transparency/lighting via `zef_update_*`; Play/Stop/Logo; compartment/sensor color lists (`zef_colored_list`). `DeleteFcn` = `zef_reopen_figure`. **Window → Figure tool** rebuilds via `zef_figure_tool`. Layout helpers live in `src/gui/chrome`.

**Mesh visualization:** Visualize volume/surfaces, Frame/Movie, Axes pop-up, Plot graph, DTI streamlines, clipping, cones/streamlines/contours, visualization type and distribution mode. Graph list from `graph_bank` help text.

**Parcellation:** not at startup; **Multi-tools → Parcellation tool** → `zef_tool_start` → open/init/window. Button map in `src/parcellation/README.md`.

Class-solver Inverse-tools windows (`zef_eloreta_start`, …) also go through `zef_tool_start`, then `zef_open_class_inverse` in `src/gui/open/`. They are not created here.

## Workflow context

`zef_start` calls tools in order: segmentation → figure → mesh → mesh visualization → menu. Closing usually only hides (`Visible='off'`); `zef_close_all` deletes. After widget edits, `zef_update_*` or `zef_update` copies values into `zef`.

## Usage instructions

Prefer calling the same functions the buttons call (`zef_create_finite_element_mesh`, `zef_lead_field_matrix`, …) instead of poking `h_*`. To show a hidden tool:

```matlab
zef.h_mesh_tool = zef_window_visible(zef, zef.h_mesh_tool);
```

## Important notes

- `start_mode` `nodisplay` still constructs hidden figures.
- Mesh visualization stores `layer_transparency` / `brain_transparency` inverted from the slider.
- Segmentation **Toggle controls** multiplies/divides window width by 0.505.

## Developer guidance

See `src/gui/README.md` for the layer map, `src/app/zef_start.m` for open order, `src/mesh/README.md` for Create FEM mesh computation. Keep App Designer labels as the source of truth for button text.
