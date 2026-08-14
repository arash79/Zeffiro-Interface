# App Designer layouts (`src/gui/apps`)

Generated `*_app_exported.m` classes plus `.mlapp` sources. **Layout and `Text=` labels only.** Callbacks are assigned later in `src/gui/tools` and `src/gui/open`.

Do not hand-edit exported `.m` except to read labels. Change the `.mlapp` in App Designer and re-export.

| Export | Window |
|--------|--------|
| `zef_menu_tool_app_exported.m` | Menu bar — **Project, Import, Export, Edit, Inverse tools, Forward tools, Multi-tools, Settings, Window, Help** |
| `zef_segmentation_tool_app_exported.m` | Segmentation tool tables and its local menus (**Add compartment**, **Import surface mesh**, …) |
| `zef_mesh_tool_app_exported.m` | Mesh tool (**Create FEM mesh**, **Run script**, …) |
| `zef_mesh_visualization_tool_app_exported.m` | Mesh visualization (**Visualize volume**, **Visualize surfaces**, …) |

Other `.mlapp` files (system settings, parameter profile, forward/inverse options, …) are instantiated from `src/gui/open` without a `*_exported.m` in this folder (they compile to classes on the path when MATLAB opens them).

Verified label tables: `src/gui/tools/README.md` and `src/gui/open/README.md`.
