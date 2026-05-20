# Figure and Image Assets (`fig`)

This directory holds **GUI figure templates** and **image assets** used by the Zeffiro Interface application. The contents are loaded at runtime when the application path is set (see `zeffiro_interface.m`, which adds this folder via `addpath(genpath(...))`).

---

## Directory structure

```
fig/
├── README.md                    # This file
├── zeffiro_interface_compass.png
├── zeffiro_logo_compass.png
├── zeffiro_logo.png
├── zeffiro_mesh_symbol.png
├── zeffiro_small_logo.png
├── zeffiro_symbol_compass.png
├── zeffiro_symbol_mesh.png
└── tools/                       # GUI figure templates and tool-specific images
    ├── zef_find_synthetic_eit_data.fig
    ├── zef_find_synthetic_source.fig
    ├── zeffiro_interface_butterfly_plot.fig
    ├── zeffiro_interface_figure_tool.fig
    ├── zeffiro_interface_mesh_tool.fig
    ├── zeffiro_interface_parcellation_tool.fig
    ├── zeffiro_interface_ramus_inversion_tool.fig
    ├── zeffiro_interface_segmentation_tool.fig
    ├── zeffiro_interface.png
    ├── zeffiro_logo.png
    ├── zeffiro_small_logo.png
    └── README.md                # Subdirectory documentation
```

---

## Root-level assets

All files in the root of `fig/` are **PNG images** used for branding, icons, and UI elements across the application.

| File | Description | Typical use |
|------|-------------|-------------|
| `zeffiro_logo.png` | Full Zeffiro Interface logo. | Splash screens, about dialogs, and branding where a large logo is needed. |
| `zeffiro_small_logo.png` | Reduced-size logo variant. | Toolbars, window titles, or compact UI areas. |
| `zeffiro_interface_compass.png` | Compass-style graphic (e.g. orientation or navigation). | UI elements related to orientation or direction. |
| `zeffiro_logo_compass.png` | Logo combined with compass motif. | Branding in orientation/navigation contexts. |
| `zeffiro_symbol_compass.png` | Standalone compass symbol. | Icons or indicators for compass/orientation. |
| `zeffiro_mesh_symbol.png` | Symbol representing a mesh (e.g. FEM or geometry). | Mesh-related tools or menus. |
| `zeffiro_symbol_mesh.png` | Alternate mesh symbol. | Mesh tool or visualization UI elements. |

External code may reference these by path, e.g. `fullfile(folder_name, 'fig', 'zeffiro_logo.png')` (see `+utilities/+brainstorm2zef`).

---

## Default figure path

When opening figure files without a user-specified folder, the application uses this directory as the default location. In `zeffiro_interface.m`, the default `file_path` for opening figures is set to `fullfile(zef.program_path, "fig")`. The function `zef_import_figure` loads `.fig` files from `zef.file_path` and `zef.file` when running in no-display mode or when file and path are provided programmatically.

---

## Subdirectory: `tools/`

The `tools/` subdirectory contains **MATLAB figure files** (`.fig`) and **tool-specific images** (`.png`). The `.fig` files are binary MATLAB figure templates (saved with the MATLAB Figure format) and define layout and controls for legacy or alternate GUI windows.

### Figure templates (`.fig`)

| File | Purpose | Loaded by |
|------|---------|-----------|
| `zef_find_synthetic_eit_data.fig` | GUI for the “Find synthetic EIT data” tool (electrode/source and ROI settings). | `m/zef_find_synthetic_eit_data.m` via `open('zef_find_synthetic_eit_data.fig')`. |
| `zef_find_synthetic_source.fig` | GUI for the “Find synthetic source” tool (synthetic source configuration). | Referenced by name in tools; may be used by Find Synthetic Source–related plugins or legacy code. |
| `zeffiro_interface_butterfly_plot.fig` | Layout for the butterfly-plot visualization window (multi-channel time series). | Legacy/alternate template for the butterfly plot; current UI may be built in code (e.g. `m/zef_butterfly_plot_app.m`). |
| `zeffiro_interface_figure_tool.fig` | Layout for the main figure tool window (plotting and figure options). | Legacy template; current implementation builds the figure in `m/zef_figure_tool.m`. |
| `zeffiro_interface_mesh_tool.fig` | Layout for the mesh tool (meshing, refinement, forward simulation table). | Legacy template; current implementation uses `mlapp/zef_mesh_tool_app_exported.m`. |
| `zeffiro_interface_parcellation_tool.fig` | Layout for the parcellation tool (parcellation names and time-series options). | Legacy template; window is built in `m/zef_parcellation_tool_window.m`. |
| `zeffiro_interface_ramus_inversion_tool.fig` | Layout for the RAMUS inversion tool. | Legacy template; RAMUS plugin uses `plugins/RAMUSInversion/m/zef_ramus_app.m` for the live UI. |
| `zeffiro_interface_segmentation_tool.fig` | Layout for the segmentation tool (compartments and segmentation controls). | Legacy template; when `zef.mlapp == 0`, `m/zef_start.m` opens `zef_segmentation_tool.fig` (may reside on path or be an alias); current default uses the app in `mlapp/`. |

**Note:** Loading is by filename (e.g. `open('zef_find_synthetic_eit_data.fig')`) with the `fig` directory (and thus `fig/tools/` when using `genpath`) on the MATLAB path.

### Images in `tools/`

| File | Description |
|------|-------------|
| `zeffiro_interface.png` | Full interface or splash image for the application. |
| `zeffiro_logo.png` | Logo used inside tool windows or dialogs. |
| `zeffiro_small_logo.png` | Small logo for tool headers or compact areas. |

---

## File formats

- **`.fig`** — MATLAB figure file (binary). Contains a saved figure’s hierarchy, properties, and callbacks. Open or edit in MATLAB with `open`, `openfig`, or GUIDE; do not edit as text.
- **`.png`** — Portable Network Graphics. Standard image format for logos and icons; editable with any image editor.

---

## Maintenance

- **Adding or renaming assets:** Update this README and, if relevant, any code that builds paths to `fig/` or `fig/tools/` (e.g. `zeffiro_interface.m`, `zef_find_synthetic_eit_data.m`, or utilities that reference `fig/`).
- **Replacing a `.fig`:** Replace the file in place and test the corresponding tool (e.g. Find synthetic EIT data) to ensure layout and callbacks still work.
- **Path dependency:** The application expects `fig` to be on the path (via `zeffiro_interface.m`). Do not remove this directory or change its name without updating path setup and this documentation.
